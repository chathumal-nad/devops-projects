locals {
  include_cors = length(var.cors) > 0
}

resource "azurerm_linux_web_app" "linux_web_app" {
  name                = "${var.prefix}-${var.app_name}-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.app_service_plan_id

  site_config {

    dynamic "application_stack" {
      for_each = var.stack_type == "dotnet" ? [1] : []
      content {
        dotnet_version = var.dotnet_version
      }
    }

    dynamic "application_stack" {
      for_each = var.stack_type == "node" ? [1] : []
      content {
        node_version = var.node_version
      }
    }

    dynamic "application_stack" {
      for_each = var.stack_type == "python" ? [1] : []
      content {
        python_version = var.python_version
      }
    }

    vnet_route_all_enabled = true

    # unmatched rule action
    ip_restriction_default_action = var.block_public_access ? "Deny" : "Allow"

    dynamic "ip_restriction" {
      for_each = var.block_public_access ? [1, 2] : []

      content {
        action      = ip_restriction.value == 1 ? "Allow" : "Allow"
        description = ip_restriction.value == 1 ? "Allow traffic only from AppGw subnet" : "Allow traffic from Azure DevOps Agents"
        priority    = ip_restriction.value == 1 ? 300 : 200
        name        = ip_restriction.value == 1 ? "AllowAppGw" : "AllowAzureDevOps"

        virtual_network_subnet_id = ip_restriction.value == 1 ? var.app_gw_subnet_id : var.az_devops_agent_subnet_id
      }
    }

    dynamic "cors" {
      for_each = local.include_cors ? [1] : []
      content {
        allowed_origins     = var.cors
        support_credentials = false
      }
    }

    scm_ip_restriction_default_action = var.block_public_access ? "Deny" : "Allow"
    scm_use_main_ip_restriction       = true
  }

  virtual_network_subnet_id = var.subnet_id

  lifecycle {
    ignore_changes = [app_settings, sticky_settings, logs, site_config[0].app_command_line, auth_settings_v2]
  }
}

