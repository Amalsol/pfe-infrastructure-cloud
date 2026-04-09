output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

output "web_vm_private_ip" {
  value = azurerm_linux_virtual_machine.web.private_ip_address
}
output "db_vm_private_ip" {
  value = azurerm_linux_virtual_machine.db.private_ip_address
}
