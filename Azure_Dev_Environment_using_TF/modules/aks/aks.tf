#resource "azurerm_subnet" "aks-gw-subnet"{
#
#  address_prefixes     = var.vn-subnet-prefix
#  name                 = "aks-gw-subnet"
#  resource_group_name  = var.resource-group-name
#  virtual_network_name = var.vn-name
#}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster-name
  resource_group_name = var.resource-group-name
  location            = var.location
  dns_prefix          = var.cluster-name
  oidc_issuer_enabled = true
  #  kubernetes_version  = "1.23.12"

  local_account_disabled = true

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "basic" # standard
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  sku_tier = "Free"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = var.vm_size
    enable_auto_scaling = true
    max_count           = 5
    min_count           = 1
    max_pods            = 50
    type                = "VirtualMachineScaleSets"
    os_disk_type        = "Managed"
    os_disk_size_gb     = 30
    #    vnet_subnet_id =
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_insights.id
  }

  tags = {
    owner = "terraform"
  }

  #  ingress_application_gateway {
  #    subnet_id = azurerm_subnet.aks-gw-subnet.id
  #  }


  # since we are using auto scaling
  lifecycle {
    ignore_changes = [default_node_pool.0.node_count]
  }
}



# if you need this you need a Standard SKU Load balancer

#resource "azurerm_kubernetes_cluster_node_pool" "standard_16_ephemeral" {
#  name                  = "stand16ephem"
#  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
#  vm_size               = var.vm_size
#  os_type               = "Linux"
#  os_disk_type          = "Managed"
#  enable_auto_scaling   = true
#  max_count             = 3
#  min_count             = 0
#  max_pods              = 50
#
#  lifecycle {
#    ignore_changes = [node_count]
#  }
#
#  tags = {
#    owner = "terraform"
#  }
#}
