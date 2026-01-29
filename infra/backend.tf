# Terraform Backend Configuration
# Uncomment and configure after creating the storage account for remote state

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "stpersonalwebsitetfstate"
#     container_name       = "tfstate"
#     key                  = "personalwebsite.terraform.tfstate"
#   }
# }

# To set up remote state storage, run these commands first:
# az group create --name rg-terraform-state --location "East US"
# az storage account create --name stpersonalwebsitetfstate --resource-group rg-terraform-state --location "East US" --sku Standard_LRS
# az storage container create --name tfstate --account-name stpersonalwebsitetfstate
