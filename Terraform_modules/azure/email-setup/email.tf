
resource "azurerm_email_communication_service" "email_comm_service" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
}

resource "azurerm_email_communication_service_domain" "email_comm_service_domain" {
  name              = var.email_domain
  email_service_id  = azurerm_email_communication_service.email_comm_service.id
  domain_management = "CustomerManaged"
}

resource "azurerm_communication_service" "comm_service" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
}


resource "azapi_update_resource" "join_email_domain_with_comm_service" {
  count = var.domain_validation_done ? 1 : 0

  type        = "Microsoft.Communication/communicationServices@2022-07-01-preview"
  resource_id = azurerm_communication_service.comm_service.id

  body = jsonencode({
    properties = {
      linkedDomains = [
        azurerm_email_communication_service_domain.email_comm_service_domain.id
      ]
    }
  })
}