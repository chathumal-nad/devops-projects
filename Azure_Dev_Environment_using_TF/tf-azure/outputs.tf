output "external-secrets-client-id" {
  value = azuread_application.external-secrets.application_id
}

output "grafana-client-id" {
  value = azuread_application.grafana.application_id
}

# output "public_ip_address" {
#   value = azurerm_public_ip.terraform-public-ip-1.ip_address
# }