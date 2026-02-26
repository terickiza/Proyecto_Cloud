# ========================================
# OUTPUTS - Información del ACR
# ========================================

output "acr_id" {
  description = "ID del Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "Nombre del ACR"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "URL del servidor de login del ACR"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuario administrador del ACR"
  value       = var.acr_admin_enabled ? azurerm_container_registry.acr.admin_username : "Admin no habilitado"
  sensitive   = true
}

output "acr_admin_password" {
  description = "Contraseña del usuario administrador del ACR"
  value       = var.acr_admin_enabled ? azurerm_container_registry.acr.admin_password : "Admin no habilitado"
  sensitive   = true
}

output "docker_login_command" {
  description = "Comando para hacer login con Docker"
  value       = "docker login ${azurerm_container_registry.acr.login_server}"
}

output "integration_status" {
  description = "Estado de la integración AKS-ACR"
  value       = "AKS '${var.aks_name}' tiene permisos AcrPull sobre '${azurerm_container_registry.acr.name}'"
}