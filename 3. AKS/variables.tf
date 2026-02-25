variable "rg-cloud-lab" {
  description = "Nombre del Resource Group existente en Azure donde se desplegarán los recursos."
  type        = string
}

variable "vnet-e08" {
  description = "Nombre de la VNet existente."
  type        = string
}

variable "snet-e08" {
  description = "Nombre de la Subnet existente para los nodos AKS."
  type        = string
}

variable "aks-e08" {
  description = "Nombre del clúster AKS a crear."
  type        = string
}

variable "location" {
  description = "Región del AKS (debe coincidir con la VNet/Subnet)."
  type        = string
}