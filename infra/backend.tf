# Terraform Backend Configuration
# Remote state storage configured on January 30, 2026

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stpaborwebsitetfstate"
    container_name       = "tfstate"
    key                  = "personalwebsite.terraform.tfstate"
  }
}

# Storage account created with these commands:
# az group create --name rg-terraform-state --location "East US"
# az storage account create --name stpaborwebsitetfstate --resource-group rg-terraform-state --location "East US" --sku Standard_LRS
# az storage container create --name tfstate --account-name stpaborwebsitetfstate
