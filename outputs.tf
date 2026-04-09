output "bastion_public_ip" {
  value = module.compute.bastion_public_ip
}

output "web_vm_private_ip" {
  value = module.compute.web_vm_private_ip
}

output "db_vm_private_ip" {
  value = module.compute.db_vm_private_ip
}
