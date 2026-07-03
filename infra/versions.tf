# 진행자 전용 — 배포 대상 Azure "인프라"를 코드로 고정한다(재현/확장).
# 컴퓨트는 VM이 아니라 Azure Container Apps(서버리스 컨테이너, scale-to-zero).
# 아이덴티티(OIDC 앱·federated credential)는 이 테넌트가 provider 경유 Graph 쓰기를
# 막으므로 scripts/bootstrap-identity.sh(az)로 분리한다. TF는 RG/ACR/Log Analytics/ACA 만 관리.
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.116" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}
