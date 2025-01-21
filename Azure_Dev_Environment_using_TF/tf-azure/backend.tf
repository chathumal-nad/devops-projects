terraform {

  # which providers we are going to use with terraform
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.47.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.36.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
  }

  backend "azurerm" {

    # credentials to connect with azure storage account
    subscription_id         = "xxxxxxxx"
    client_id               = "xxxxxxxx"
    client_certificate_path = "../client-creds/client.pfx"
    tenant_id               = "xxxxxxxx"

    # backend configs
    resource_group_name  = "chathumal-resource-group"
    storage_account_name = "chathumalstorageaccount"
    container_name       = "tfstate"
    key                  = "tf-azure/terraform.tfstate"
  }
}