terraform {
  required_version = ">= 1.5.0"

  # Test PR workflow - this comment triggers the infrastructure pipeline
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

provider "azuread" {}

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = var.tags
}

# App Service Module
module "app_service" {
  source = "./modules/app-service"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# SQL Database Module
module "sql_database" {
  source = "./modules/sql-database"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
  tags                = var.tags
}

# Key Vault Module
# Note: Secrets are managed externally via Azure CLI/Portal for security
# This module only creates the Key Vault infrastructure
module "key_vault" {
  source = "./modules/key-vault"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = var.tags

  # Secrets are managed externally in Key Vault (not in Terraform)
  # This keeps sensitive values out of state files and git history
  secrets = {}
}

# Azure AD B2C Module (Note: B2C tenant creation has limitations in Terraform)
module "ad_b2c" {
  source = "./modules/ad-b2c"

  project_name = var.project_name
  environment  = var.environment
}
