
# how will connect with azure Resource Manager provider with credentials

provider "azurerm" {
  subscription_id         = "xxxxxxxx"
  client_id               = "xxxxxxxxxxxxxxxx"
  client_certificate_path = "../client-creds/client.pfx"
  tenant_id               = "xxxxxxxxxxxxxxxx"
  features {}

}

provider "azuread" {
  client_id               = "xxxxxxxxxxxxxxxx"
  client_certificate_path = "../client-creds/client.pfx"
  tenant_id               = "xxxxxxxxxxxxxxxx"
}

provider "external" {
  # Configuration options
}

data "azurerm_client_config" "current" {
}