locals {
  repo_list           = ["azure-tf"]
  organization_name   = "chathumal-nad"
  default_main_branch = "master"
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "primary" {
}

# create app registration
resource "azuread_application" "github_application" {
  display_name = "github"
  owners       = [data.azuread_client_config.current.object_id, data.azuread_user.me.object_id]
}

# create service principal
resource "azuread_service_principal" "github_application_sp" {
  application_id = azuread_application.github_application.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

# granting roles to the app registration
resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_application_sp.id
}

resource "azuread_application_federated_identity_credential" "azure-tf-credentials" {
  for_each              = toset(local.repo_list)
  display_name          = "${each.key}-repo"
  application_object_id = azuread_application.github_application.object_id
  description           = "Deployments for ${local.organization_name}/${each.key} repo"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${local.organization_name}/${each.key}:ref:refs/heads/${local.default_main_branch}"

}

