variable "resource_group_name" {
  default = "rg-pfe-cloud"
}

variable "location" {
  default = "francecentral"
}

variable "vnet_name" {
  default = "vnet-pfe"
}

variable "admin_username" {
  default = "azureuser"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "admin_ip" {
  description = "IP publique de l'administrateur"
  default     = "0.0.0.0/0"
}

# AJOUTE CES 3 VARIABLES ICI :
variable "bastion_public_key_path" {
  default = "./keys/bastion-vm_key.pem.pub"
}

variable "web_public_key_path" {
  default = "./keys/web-vm_key.pem.pub"
}

variable "db_public_key_path" {
  default = "./keys/db-vm_key.pem.pub"
}