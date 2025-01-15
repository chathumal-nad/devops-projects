# resource "azurerm_service_plan" "chathu-linux-asp" {
#   name                = "chathu-linux-asp-b1"
#   resource_group_name = azurerm_resource_group.chathumal-resource-group.name
#   location            = module.project_vars.default_location
#   os_type             = "Linux"
#   sku_name            = "B1"
#   worker_count        = 1
# }