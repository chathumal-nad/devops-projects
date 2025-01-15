import {
  to = azurerm_virtual_network.chathu_virtual_network
  id = "/subscriptions/xxxxxxxx/resourceGroups/chathumal-resource-group/providers/Microsoft.Network/virtualNetworks/ChathuVirtualNetwork"
}

resource "azurerm_virtual_network" "chathu_virtual_network" {
  name                = "ChathuVirtualNetwork"
  location            = "centralindia"
  address_space       = ["10.1.0.0/16"]
  resource_group_name = module.project_vars.chathumal_default_resource_group
  tags = {
    "owner" = "nadeesha"
  }
}


import {
  to = azurerm_resource_group.chathumal-resource-group
  id = "/subscriptions/xxxxxxxx/resourceGroups/chathumal-resource-group"
}

resource "azurerm_resource_group" "chathumal-resource-group" {
  name     = "chathumal-resource-group"
  location = module.project_vars.default_location
}
