output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "subnet_prefix" {
  value = azurerm_subnet.subnet.address_prefixes
}