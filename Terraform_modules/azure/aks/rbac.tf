data "azuread_user" "users" {
  for_each            = toset(var.admin-users)
  user_principal_name = each.key
}

resource "azurerm_role_assignment" "access-to-aks" {
  for_each             = toset(var.admin-users)
  principal_id         = data.azuread_user.users[each.key].object_id
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
}