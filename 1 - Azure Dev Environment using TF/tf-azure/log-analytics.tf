resource "azurerm_log_analytics_workspace" "azure_insights" {
  name                = "chathumal-logs"
  location            = module.project_vars.default_location
  resource_group_name = module.project_vars.chathumal_default_resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    owner = "terraform"
  }
}