# 1) Referenciar el Resource Group ya existente
data "azurerm_resource_group" "rg" {
  name = var.rg-cloud-lab
}

# 2) (Opcional) Generar sufijo aleatorio por si reutilizas nombres
resource "random_pet" "suffix" {
  length = 2
}

# 3) Crear la VNet en el RG existente
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_e08
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  address_space = var.vnet_e8_address_space
  dns_servers   = [] # deja vacío si usarás DNS por defecto

  tags = var.tags
}

# 4) Crear una Subnet dentro de la VNet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_e08
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_e8_prefix]
}

# 5) (Opcional) Network Security Group y asociación
#    Si quieres reglas básicas, descomenta este bloque y la asociación

# resource "azurerm_network_security_group" "nsg" {
#   name                = "nsg-${var.subnet_name}-${random_pet.suffix.id}"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#
#   security_rule {
#     name                       = "Allow-SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#
#   tags = var.tags
# }
#
# resource "azurerm_subnet_network_security_group_association" "assoc" {
#   subnet_id                 = azurerm_subnet.subnet.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }