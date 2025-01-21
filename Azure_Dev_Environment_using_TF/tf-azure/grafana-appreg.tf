# create app registration

locals {
  grafana_domain = "http://localhost:3000"
}
resource "azuread_application" "grafana" {
  display_name = "grafana"
  owners       = [data.azuread_client_config.current.object_id, data.azuread_user.me.object_id]

  app_role {
    allowed_member_types = [
      "User",
    ]
    description  = "Grafana Editor Users"
    display_name = "Grafana Editor"
    enabled      = true
    id           = "0a529709-3dd3-4bc2-96ff-6c0ec2c68760"
    value        = "Editor"
  }

  app_role {
    allowed_member_types = [
      "User",
    ]
    description  = "Grafana org admin Users"
    display_name = "Grafana Org Admin"
    enabled      = true
    id           = "c5cf4099-eb8e-4e6f-bcac-295d7c06b811"
    value        = "Admin"
  }

  app_role {
    allowed_member_types = [
      "User",
    ]
    description  = "Grafana read only Users"
    display_name = "Grafana Viewer"
    enabled      = true
    id           = "685107f4-86f2-4445-bb7c-ca6beebdf908"
    value        = "Viewer"
  }

  web {
    redirect_uris = ["${local.grafana_domain}/login/azuread", "${local.grafana_domain}/"]
  }

}

# create service principal
resource "azuread_service_principal" "grafana-sp" {
  application_id = azuread_application.grafana.application_id
  owners         = [data.azuread_client_config.current.object_id, data.azuread_user.me.object_id]
}

# create password for the app
resource "azuread_application_password" "grafana-pasword" {
  application_object_id = azuread_application.grafana.object_id
  display_name          = "Grafana OAuth"
}

# store secret
resource "azurerm_key_vault_secret" "grafana-client-secret" {
  key_vault_id = data.azurerm_key_vault.chathumal-kv.id
  name         = "${azuread_application.grafana.display_name}-client-secret"
  value        = azuread_application_password.grafana-pasword.value
}

resource "azurerm_key_vault_secret" "grafana-client-id" {
  key_vault_id = data.azurerm_key_vault.chathumal-kv.id
  name         = "${azuread_application.grafana.display_name}-client-id"
  value        = azuread_application.grafana.application_id
}