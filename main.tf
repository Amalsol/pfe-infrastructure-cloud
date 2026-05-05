# ─────────────────────────────────────────────────────
# PFE — Infrastructure Cloud Sécurisée avec Terraform
# Fichier : main.tf
# Description : Orchestration des modules network,
#               security et compute sur Microsoft Azure
# ─────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────
# Resource Group — Conteneur de toutes les ressources
# ─────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────
# PFE — Infrastructure Cloud Sécurisée avec Terraform
# ─────────────────────────────────────────────────────

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]
}

module "security" {
  source              = "./modules/security"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  admin_ip            = var.admin_ip
  public_subnet_id    = module.network.public_subnet_id
  private_subnet_id   = module.network.private_subnet_id
  db_subnet_id        = module.network.db_subnet_id
  depends_on          = [module.network]
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
  bastion_public_key_path = var.bastion_public_key_path
  web_public_key_path     = var.web_public_key_path
  db_public_key_path      = var.db_public_key_path
  depends_on              = [module.security]
}