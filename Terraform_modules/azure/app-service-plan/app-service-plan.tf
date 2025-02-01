resource "azurerm_service_plan" "asp" {
  name                   = var.asp-name
  resource_group_name    = var.resource_group_name
  location               = var.location
  os_type                = var.os_type
  sku_name               = var.sku_name               #"B1"
  worker_count           = var.worker_count           #1
  zone_balancing_enabled = var.zone_balancing_enabled #false
}