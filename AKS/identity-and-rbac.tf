# Identidad administrada de usuario para el AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.aks-e08}-uami"
  resource_group_name = var.rg-cloud-lab
  location            = var.location
}




# Asignación de rol Network Contributor sobre la SUBNET
# Requisito para AKS con Azure CNI
#resource "azurerm_role_assignment" "uami_netcontrib_on_subnet" {
#  scope                = data.azurerm_subnet.aks.id
#  role_definition_name = "Network Contributor"
#  principal_id         = azurerm_user_assigned_identity.aks.principal_id
#}
