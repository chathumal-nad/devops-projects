# resource to create the container for storing tf state
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = module.project_vars.chathumal_storage_account
  container_access_type = "private"
}

# availability set for tf
resource "azurerm_availability_set" "tf-availability-set" {
  name                         = "tf-availability-set"
  location                     = module.project_vars.default_location
  resource_group_name          = module.project_vars.chathumal_default_resource_group
  platform_update_domain_count = 2
  platform_fault_domain_count  = 2

  tags = {
    owner = "terraform"
  }
}