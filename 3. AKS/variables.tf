// Variables para el despliegue de AKS (módulo 3. AKS)

variable "resource_group_name" {
  description = "Resource Group donde existe la VNet/Subnet"
  type        = string
}

variable "vnet_name" {
  description = "Nombre de la Virtual Network"
  type        = string
  default     = "vnet-e08"
}

variable "subnet_name" {
  description = "Nombre de la Subnet donde se conectará AKS (Azure CNI)"
  type        = string
  default     = "snet-e08"
}

variable "aks_name" {
  description = "Nombre del cluster AKS"
  type        = string
  default     = "aks-e08"
}

variable "location" {
  description = "Región donde desplegar AKS"
  type        = string
  default     = "eastus"
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