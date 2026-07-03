output "container_app_fqdn" {
  description = "Container App 외부 ingress FQDN(스모크 테스트/데모 접속)."
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "container_app_name" {
  value = azurerm_container_app.app.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

# 아이덴티티(AZURE_CLIENT_ID)는 scripts/bootstrap-identity.sh 가 출력한다.
