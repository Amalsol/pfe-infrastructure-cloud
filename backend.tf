terraform {
  backend "azurerm" {
    resource_group_name  = "rg-pfe-cloud"
    storage_account_name = "tfstatepfe2026"
    container_name       = "tfstate"
    key                  = "pfe.terraform.tfstate"
  }
}