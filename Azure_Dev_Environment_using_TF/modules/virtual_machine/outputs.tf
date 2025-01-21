output "public_ips" {
  value = { for ip in azurerm_public_ip.terraform-public-ip : ip.name => ip.ip_address }
}
