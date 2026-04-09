# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "security" {
  source              = "./modules/security"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  admin_ip            = var.admin_ip
  public_subnet_id    = module.network.public_subnet_id
  private_subnet_id   = module.network.private_subnet_id
  db_subnet_id        = module.network.db_subnet_id

}

module "compute" {
  source                  = "./modules/compute"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  vm_size                 = var.vm_size
  admin_username          = var.admin_username
  public_subnet_id        = module.network.public_subnet_id
  private_subnet_id       = module.network.private_subnet_id
  db_subnet_id            = module.network.db_subnet_id
  bastion_public_key_path = "C:/Users/user/.ssh/bastion-vm_key.pem.pub"
  web_public_key_path     = "C:/Users/user/.ssh/web-vm_key.pem.pub"
  db_public_key_path      = "C:/Users/user/.ssh/db-vm_key.pem.pub"
}