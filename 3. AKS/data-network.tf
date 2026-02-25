data "azurerm_resource_group" "rg" {
  name = var.rg-cloud-lab
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet-e08
  resource_group_name = var.rg-cloud-lab
}

data "azurerm_subnet" "aks" {
  name                 = var.snet-e08
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg-cloud-lab
}