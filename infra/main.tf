data "azurerm_subscription" "current" {}

# =========================================================================
# 인프라 — 전용 RG 안의 Azure Container Apps 스택(서버리스 컨테이너).
#   Log Analytics → Container Apps Environment → Container App(+ 시스템 아이덴티티)
#   이미지 레지스트리 = ACR(진행자 OIDC 로 az acr build). 앱은 AcrPull 로 당겨온다.
# 아이덴티티(OIDC 앱·SP·federated credential·역할부여)는 scripts/bootstrap-identity.sh 참조.
# =========================================================================
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ACR 이름은 전역 유일·소문자 영숫자여야 하므로 접미사를 붙인다.
resource "random_string" "acr_suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.name_prefix}acr${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = false # 관리자 자격증명 대신 앱의 관리 아이덴티티 + AcrPull(장수 시크릿 없음).
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.name_prefix}-logs"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "env" {
  name                       = "${var.name_prefix}-aca-env"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  tags                       = var.tags
}

resource "azurerm_container_app" "app" {
  name                         = var.container_app_name
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"
  tags                         = var.tags

  # 관리 아이덴티티로 ACR pull(레지스트리 비밀번호 저장 안 함).
  # 주의: ACR registry 는 여기서 붙이지 않는다. 생성 시점엔 앱의 시스템 아이덴티티에
  # AcrPull 이 아직 없어(역할부여가 앱 생성 뒤에 일어남) ACA 가 registry 검증에서 멈춘다.
  # 대신 최초엔 공개 placeholder(MCR)로 뜨고, deploy-azure.yml 이 배포 시점에
  # `az containerapp registry set --identity system` 으로 ACR 를 붙인다(그땐 AcrPull 이 이미 유효).
  identity {
    type = "SystemAssigned"
  }

  # 외부 HTTPS ingress.
  # 최초 apply 는 자리표시 이미지(k8se/quickstart, 80 포트)로 뜨므로 생성 시 target_port 도 80 으로 둔다.
  # 실배포(deploy-azure.yml)가 실제 앱 포트(8000)로 바꾸며, 잘못 바꾸면(의도된 버그: 8080) 502 가 난다.
  # target_port 는 아래 lifecycle.ignore_changes 대상이라 이후 deploy 가 바꾼 값을 TF 가 되돌리지 않는다.
  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 0 # scale-to-zero — 유휴 시 과금 없음(VM 대비 경량).
    max_replicas = 1

    container {
      name   = var.name_prefix
      image  = var.placeholder_image # 최초엔 공개 자리표시 이미지. 실배포는 deploy-azure 가 ACR 이미지로 교체.
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  # 최초 apply 는 자리표시 이미지를 쓰므로, 이후 deploy 가 바꾼 image/ingress 를 TF 가 되돌리지 않게 한다.
  lifecycle {
    ignore_changes = [template[0].container[0].image, ingress[0].target_port]
  }
}

# 앱의 시스템 아이덴티티에 ACR pull 권한(최소권한).
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.app.identity[0].principal_id
}
