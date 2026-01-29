variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# App Service Plan - Free tier (F1)
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "F1"

  tags = var.tags
}

# App Service
resource "azurerm_windows_web_app" "main" {
  name                = "app-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "v7.0"
      current_stack  = "dotnet"
    }

    always_on = false # Not available on F1 tier
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = var.environment == "prod" ? "Production" : "Development"
  }

  tags = var.tags
}

output "app_service_url" {
  value = "https://${azurerm_windows_web_app.main.default_hostname}"
}

output "app_service_name" {
  value = azurerm_windows_web_app.main.name
}

output "app_service_id" {
  value = azurerm_windows_web_app.main.id
}
