locals {
  # not used right now
  key_vault_list = ["chathumal-kv"]
}

# for creating as owner
data "azuread_user" "me" {
  user_principal_name = "chathumal1994_outlook.com#EXT#@chathumal1994outlook.onmicrosoft.com"
}

# reading key-vault details
data "azurerm_key_vault" "chathumal-kv" {
  name                = "chathumal-kv"
  resource_group_name = module.project_vars.chathumal_default_resource_group
}

# create app registration
resource "azuread_application" "external-secrets" {
  display_name = "external-secrets"
  owners       = [data.azuread_client_config.current.object_id, data.azuread_user.me.object_id]
}

# create service principal
resource "azuread_service_principal" "external-secrets-sp" {
  application_id = azuread_application.external-secrets.application_id
  owners         = [data.azuread_client_config.current.object_id, data.azuread_user.me.object_id]
}

# create password for the app
resource "azuread_application_password" "external-secrets-client-secret" {
  application_object_id = azuread_application.external-secrets.object_id
}

# Allow external-secrets to read the vault.
resource "azurerm_key_vault_access_policy" "external-secrets-vault-access-policy" {
  key_vault_id = data.azurerm_key_vault.chathumal-kv.id
  tenant_id    = data.azurerm_subscription.primary.tenant_id
  object_id    = azuread_service_principal.external-secrets-sp.object_id

  secret_permissions = [
    "Get",
    "List",
  ]

  #  key_permissions = [
  #    "Get",
  #    "List",
  #  ]
}

resource "azurerm_key_vault_secret" "client-secret" {
  key_vault_id = data.azurerm_key_vault.chathumal-kv.id
  name         = "${azuread_application.external-secrets.display_name}-client-secret"
  value        = azuread_application_password.external-secrets-client-secret.value
}