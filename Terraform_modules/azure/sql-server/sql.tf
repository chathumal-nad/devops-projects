data "azuread_user" "sql-admin" {
  user_principal_name = var.db_admin
}

resource "random_password" "admin_password" {
  length           = 12
  special          = true
  override_special = "!#@"
}

data "azurerm_key_vault" "common-kv" {
  name                = "xxxx"
  resource_group_name = "xxxxx"
}

# store admin password in kv
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.prefix}-sql-server-${var.suffix}-01-admin-pw"
  value        = random_password.admin_password.result
  key_vault_id = data.azurerm_key_vault.common-kv.id
}

resource "azurerm_mssql_server" "sql-server" {
  name                         = "${var.prefix}-sql-server-${var.suffix}-01"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_login_username
  administrator_login_password = random_password.admin_password.result
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = data.azuread_user.sql-admin.user_principal_name
    object_id      = data.azuread_user.sql-admin.object_id
  }
  depends_on = [azurerm_key_vault_secret.admin_password]
}


resource "azurerm_mssql_database" "sql-db" {
  name                        = "${var.prefix}-sql-db-${var.suffix}-01"
  server_id                   = azurerm_mssql_server.sql-server.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = var.max_size_gb
  read_scale                  = false
  sku_name                    = var.db_sku
  zone_redundant              = false
  min_capacity                = var.min_capacity
  storage_account_type        = "Local"
  auto_pause_delay_in_minutes = var.auto_pause_delay_in_minutes
  # prevent the possibility of accidental data loss
  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

module "common" {
  source = "../../modules/common"
}

resource "azurerm_mssql_firewall_rule" "allow-3rive-vpn" {
  for_each         = toset(module.common.org-vpn-ips)
  name             = "allow-3rive-vpn-${each.value}"
  server_id        = azurerm_mssql_server.sql-server.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

resource "azurerm_mssql_virtual_network_rule" "allow-subnet" {
  name      = "allow-subnet-1"
  server_id = azurerm_mssql_server.sql-server.id
  subnet_id = var.subnet_id
}