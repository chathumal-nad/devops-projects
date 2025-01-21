locals {
  # this method won't work
  custom_data = <<CUSTOM_DATA
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl enable apache2
    sudo systemctl start apache2
  CUSTOM_DATA
}

data "azurerm_ssh_public_key" "chathumal-ssh-keys" {
  name                = "chathumal-ssh-keys"
  resource_group_name = module.project_vars.chathumal_default_resource_group
}

data "external" "get_date" {
  program = ["${path.module}/get_date.sh"]
}

resource "azurerm_linux_virtual_machine" "terraform-vm" {
  for_each            = var.virtual-machine-names
  name                = "${each.key}-${data.external.get_date.result.date}"
  location            = var.location
  resource_group_name = var.resource-group-name
  size                = var.vm-size
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.terraform-nic[each.key].id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = data.azurerm_ssh_public_key.chathumal-ssh-keys.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  # az vm image list --publisher Canonical  --offer 0001-com-ubuntu-server-focal --all --output table
  # https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "22.04.202204200"
  }

  # provisioners will not be picked up by the state

  provisioner "local-exec" {
    command    = "echo private ip address : ${self.private_ip_address} >> provisioner_details.txt"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "echo ${self.private_ip_address} VM destroyed >> provisioner_details.txt"
    on_failure = continue
  }

  # boot_diagnostics {
  #   storage_account_uri = "${var.azure-storage-account-blob-uri}"
  # }

  #   custom_data = base64encode(local.custom_data)
  custom_data = filebase64("~/repositories/private/devops-learning/terraform/tf_samples/azure-terraform/modules/virtual_machine/${var.script-name}")

  availability_set_id = var.availability-set-id

  tags = {
    owner = "terraform"
  }

}

# az vm extension image list --location westus -o table

#resource "azurerm_virtual_machine_extension" "terraform-custom-script-1" {
#  for_each             = var.virtual-machine-names
#  name                 = "terraform-custom-script-1"
#  virtual_machine_id   = azurerm_linux_virtual_machine.terraform-vm[each.key].id
#  publisher            = "Microsoft.Azure.Extensions"
#  type                 = "CustomScript"
#  type_handler_version = "2.1"
#  settings             = <<SETTINGS
# {
#
#     "fileUris": ["blob-file-URI"],
#     "commandToExecute": "sh vm_script.sh",
#     "skipDos2Unix": false
#     }
#  SETTINGS
#
#  tags = {
#    owner = "terraform"
#  }
#
#}