resource "azurerm_public_ip" "terraform-public-ip" {
  for_each            = var.need-public-ip ? var.virtual-machine-names : []
  name                = "${each.key}-${data.external.get_date.result.date}"
  resource_group_name = module.project_vars.chathumal_default_resource_group
  location            = module.project_vars.default_location
  allocation_method   = "Dynamic"

  tags = {
    owner = "terraform"
  }
}

resource "azurerm_network_interface" "terraform-nic" {
  for_each            = var.virtual-machine-names
  name                = "${each.key}-${data.external.get_date.result.date}"
  location            = var.location
  resource_group_name = var.resource-group-name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet-id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.need-public-ip ? azurerm_public_ip.terraform-public-ip[each.key].id : ""
  }

  tags = {
    owner = "terraform"
  }

}