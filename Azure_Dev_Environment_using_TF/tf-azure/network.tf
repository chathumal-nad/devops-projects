locals {
  virtual_network_address_space          = ["10.2.0.0/16"]
  subnet_address_prefixes                = ["10.2.0.0/24"]
  vpn_gateway_subnet                     = ["10.2.9.0/24"]
  firewall_subnet                        = ["10.2.8.0/24"]
  firewall_management_subnet             = ["10.2.7.0/24"]
  security_group_priority                = 500
  security_group_destination_port_ranges = [xx, xx, xxx, xxx]

}

resource "azurerm_virtual_network" "terraform-virtual-network-1" {
  name                = "terraform-virtual-network-1"
  location            = module.project_vars.default_location
  resource_group_name = module.project_vars.chathumal_default_resource_group
  address_space       = toset(local.virtual_network_address_space)

  tags = {
    owner = "terraform"
  }
}

resource "azurerm_network_security_group" "terraform-security-group-1" {
  name                = "terraform-security-group-1"
  location            = module.project_vars.default_location
  resource_group_name = module.project_vars.chathumal_default_resource_group

  tags = {
    owner = "terraform"
  }
}

data "external" "public_ip" {
  program = ["${path.module}/get_public_ip.sh"]
}


resource "azurerm_network_security_rule" "terraform-security-rule-1" {
  name                        = "terraform-security-rule-1"
  priority                    = local.security_group_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = local.security_group_destination_port_ranges
  source_address_prefix       = data.external.public_ip.result.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = module.project_vars.chathumal_default_resource_group
  network_security_group_name = azurerm_network_security_group.terraform-security-group-1.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association_1_1" {
  subnet_id                 = azurerm_subnet.terraform-subnet-1.id
  network_security_group_id = azurerm_network_security_group.terraform-security-group-1.id
}


############
# Public IPs
############
# resource "azurerm_public_ip" "terraform-public-ip-1" {
#   name                = "terraform-public-ip-1"
#   resource_group_name = module.project_vars.chathumal_default_resource_group
#   location            = module.project_vars.default_location
#   allocation_method   = "Dynamic"

#   tags = {
#     owner = "terraform"
#   }
# }

#########
# SUBNETS
#########

resource "azurerm_subnet" "terraform-subnet-1" {
  name                 = "terraform-subnet-1"
  resource_group_name  = module.project_vars.chathumal_default_resource_group
  virtual_network_name = azurerm_virtual_network.terraform-virtual-network-1.name
  address_prefixes     = toset(local.subnet_address_prefixes)
}

# vpn gateway subnet
# resource "azurerm_subnet" "GatewaySubnet" {
#   name                 = "GatewaySubnet"
#   resource_group_name  = module.project_vars.chathumal_default_resource_group
#   virtual_network_name = azurerm_virtual_network.terraform-virtual-network-1.name
#   address_prefixes     = toset(local.vpn_gateway_subnet)
# }

# # firewall subnet
# resource "azurerm_subnet" "FirewallSubnet" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = module.project_vars.chathumal_default_resource_group
#   virtual_network_name = azurerm_virtual_network.terraform-virtual-network-1.name
#   address_prefixes     = toset(local.firewall_subnet)
# }

# # firewall-management subnet
# resource "azurerm_subnet" "FirewallManagementSubnet" {
#   name                 = "AzureFirewallManagementSubnet"
#   resource_group_name  = module.project_vars.chathumal_default_resource_group
#   virtual_network_name = azurerm_virtual_network.terraform-virtual-network-1.name
#   address_prefixes     = toset(local.firewall_management_subnet)
# }