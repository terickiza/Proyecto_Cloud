variable "resource_group_name" {
  description = "Nombre del Resource Group existente donde está el AKS"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus"
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry (debe ser único globalmente, solo letras y números)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "El nombre del ACR debe tener entre 5 y 50 caracteres, solo letras minúsculas y números."
  }
}

variable "acr_sku" {
  description = "SKU del ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "El SKU debe ser Basic, Standard o Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Habilitar usuario administrador del ACR"
  type        = bool
  default     = true
}

variable "aks_name" {
  description = "Nombre del cluster AKS existente (para integración)"
  type        = string
}

variable "tags" {
  description = "Tags comunes para los recursos."
  type        = map(string)
  default = {
    owner      = "erick.iza"
    managed-by = "terraform"
    env        = "lab"
  }
}