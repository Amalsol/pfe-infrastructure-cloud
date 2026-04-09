output "nsg_public_id" {
  value = azurerm_network_security_group.nsg_public.id
}

output "nsg_private_id" {
  value = azurerm_network_security_group.nsg_private.id
}
output "nsg_db_id" {
  value = azurerm_network_security_group.nsg_db.id
}
