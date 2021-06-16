locals {
  docker_auth      = base64encode(join(":", [azuread_service_principal.acr.application_id, random_password.acr.result]))
  docker_auth_json = <<EOF
{
    "auths": {
        "${azurerm_container_registry.acr.login_server}": {
            "auth": "${local.docker_auth}"
        }
    }
}
EOF
}

resource "github_actions_secret" "registry" {
  repository      = var.repository
  secret_name     = "CI_REGISTRY"
  plaintext_value = azurerm_container_registry.acr.login_server
}

resource "github_actions_secret" "registry_user" {
  repository      = var.repository
  secret_name     = "CI_REGISTRY_USER"
  plaintext_value = azuread_service_principal.acr.application_id
}

resource "github_actions_secret" "registry_password" {
  repository      = var.repository
  secret_name     = "CI_REGISTRY_PASSWORD"
  plaintext_value = random_password.acr.result
}

resource "github_actions_secret" "docker_auth" {
  repository      = var.repository
  secret_name     = "DOCKER_AUTH_CONFIG"
  plaintext_value = local.docker_auth_json
}

resource "github_actions_secret" "storage_key" {
  repository      = var.repository
  secret_name     = "ARM_ACCESS_KEY"
  plaintext_value = azurerm_storage_account.ci.primary_access_key
}

resource "github_actions_secret" "sub_id" {
  repository      = var.repository
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}

resource "github_actions_secret" "tenant_id" {
  repository      = var.repository
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}