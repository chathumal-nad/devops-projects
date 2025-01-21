resource "azurerm_log_analytics_workspace" "aks_insights" {
  name                = "log-analytics-${var.cluster-name}"
  location            = var.location
  resource_group_name = var.resource-group-name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    owner = "terraform"
  }
}