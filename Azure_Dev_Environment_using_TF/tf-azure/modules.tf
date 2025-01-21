module "project_vars" {
  source = "../modules/project_vars"
}

module "virtual_machines-1" {
  source = "../modules/virtual_machine"

  location              = module.project_vars.default_location
  resource-group-name   = module.project_vars.chathumal_default_resource_group
  subnet-id             = azurerm_subnet.terraform-subnet-1.id
  virtual-machine-names = ["vm1"]
  availability-set-id   = azurerm_availability_set.tf-availability-set.id
  need-additional-disks = false
  script-name           = "script-default.sh"
  need-public-ip        = true
  vm-size               = "Standard_B1ls"
}

module "virtual_machines-2" {
  source = "../modules/virtual_machine"

  location              = module.project_vars.default_location
  resource-group-name   = module.project_vars.chathumal_default_resource_group
  subnet-id             = azurerm_subnet.terraform-subnet-1.id
  virtual-machine-names = ["buildpacks"]
  availability-set-id   = azurerm_availability_set.tf-availability-set.id
  need-additional-disks = false
  script-name           = "script-default.sh"
  need-public-ip        = true
  vm-size               = "Standard_B2s"
}


module "aks" {
  source              = "../modules/aks"
  cluster-name        = "chathumal-aks"
  location            = module.project_vars.default_location
  resource-group-name = module.project_vars.chathumal_default_resource_group
  vn-name             = azurerm_virtual_network.terraform-virtual-network-1.name
  vn-subnet-prefix    = ["10.2.5.0/24"]
}
