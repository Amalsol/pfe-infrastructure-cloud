output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
output "db_subnet_id" {
  value = azurerm_subnet.db.id
}
