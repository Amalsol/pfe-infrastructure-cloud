terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-pfe-cloud"
    storage_account_name = "tfstatepfe2026"
    container_name       = "tfstate"
    key                  = "pfe.terraform.tfstate"
    use_azuread_auth     = true
    # Credentials are now handled securely via shell variables
  }
}