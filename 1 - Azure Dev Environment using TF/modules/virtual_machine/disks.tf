resource "azurerm_managed_disk" "terraform-disk" {
  for_each             = var.need-additional-disks ? var.virtual-machine-names : []
  name                 = "${each.key}-${data.external.get_date.result.date}-data-disk"
  location             = var.location
  resource_group_name  = var.resource-group-name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "15"

  tags = {
    owner = "terraform"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-disk-atatchment" {
  for_each           = var.need-additional-disks ? var.virtual-machine-names : []
  managed_disk_id    = azurerm_managed_disk.terraform-disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.terraform-vm[each.key].id
  lun                = "0"
  caching            = "None"
}