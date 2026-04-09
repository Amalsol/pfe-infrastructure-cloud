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
  default = "Standard_B1s"
}
variable "admin_ip" {
  description = "IP publique de l'administrateur"
}