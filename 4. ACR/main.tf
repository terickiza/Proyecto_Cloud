# ========================================
# DATA SOURCES (Recursos existentes)
# ========================================

# Obtener el Resource Group existente
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Obtener el AKS existente
data "azurerm_kubernetes_cluster" "existing" {
  name                = var.aks_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

# ========================================
# CREAR ACR (Azure Container Registry)
# ========================================

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  # Configuración de red pública
  public_network_access_enabled = true

  # Deshabilitar características premium (no necesarias para Basic)
  anonymous_pull_enabled = false

  # Configuración de retención (solo para Premium)
  # retention_policy {
  #   days    = 7
  #   enabled = false
  # }

  tags = var.tags
}

# ========================================
# INTEGRAR AKS con ACR
# ========================================

# Dar permisos a AKS para que pueda descargar imágenes del ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = data.azurerm_kubernetes_cluster.existing.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Asignación adicional para el identity del AKS (si usa managed identity)
resource "azurerm_role_assignment" "aks_acr_pull_identity" {
  count                            = data.azurerm_kubernetes_cluster.existing.identity[0].type == "SystemAssigned" ? 1 : 0
  principal_id                     = data.azurerm_kubernetes_cluster.existing.identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}