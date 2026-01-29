variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# NOTE: Azure AD B2C tenant creation cannot be fully automated via Terraform.
# This module provides documentation and outputs placeholder values.
# You must manually create the B2C tenant in the Azure Portal.

# Manual Steps Required:
# 1. Go to Azure Portal > Create a resource > Azure Active Directory B2C
# 2. Select "Create a new Azure AD B2C Tenant"
# 3. Organization name: Personal Website
# 4. Initial domain name: personalwebsiteb2c
# 5. Country/Region: United States
# 6. Subscription: Select your subscription
# 7. Resource group: rg-personalwebsite-prod

# After B2C tenant creation:
# 1. Register an application for your API
# 2. Register an application for your SPA (React)
# 3. Create user flows (Sign up and sign in, Password reset)
# 4. Configure identity providers (Google, Microsoft, etc.)

# Placeholder outputs - update these after manual B2C setup
output "b2c_tenant_name" {
  description = "Name of the B2C tenant (set after manual creation)"
  value       = "${var.project_name}b2c"
}

output "b2c_domain" {
  description = "B2C tenant domain"
  value       = "${var.project_name}b2c.onmicrosoft.com"
}

output "manual_setup_instructions" {
  description = "Instructions for manual B2C setup"
  value       = <<-EOT
    Azure AD B2C Manual Setup Required:
    
    1. Create B2C Tenant:
       - Azure Portal > Create a resource > Azure Active Directory B2C
       - Domain: ${var.project_name}b2c.onmicrosoft.com
    
    2. Register API Application:
       - Name: PersonalWebsite-API
       - Supported account types: Accounts in any identity provider
       - Expose an API with scope: api://personalwebsite/access
    
    3. Register SPA Application:
       - Name: PersonalWebsite-SPA
       - Redirect URI: http://localhost:5173 (dev), https://app-${var.project_name}-${var.environment}.azurewebsites.net (prod)
       - Enable implicit grant for Access tokens and ID tokens
    
    4. Create User Flows:
       - B2C_1_signup_signin (Sign up and sign in)
       - B2C_1_password_reset (Password reset)
    
    5. Add Identity Providers (optional):
       - Google: Requires Google Cloud Console OAuth credentials
       - Microsoft: Configure in B2C Identity providers
  EOT
}
