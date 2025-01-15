data "azurerm_virtual_network" "ChathumalVirtualNetwork" {
  name                = "ChathuVirtualNetwork"
  resource_group_name = module.project_vars.chathumal_default_resource_group
}

data "azurerm_subnet" "subnet00" {
  name                 = "subnet00"
  virtual_network_name = data.azurerm_virtual_network.ChathumalVirtualNetwork.name
  resource_group_name  = module.project_vars.chathumal_default_resource_group
}

data "azurerm_network_security_group" "chathumal-subnet-nsg" {
  name                = "chathumal-subnet-nsg"
  resource_group_name = module.project_vars.chathumal_default_resource_group
}

