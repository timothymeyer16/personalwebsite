# Terraform Variables - Personal Website
# Created: January 30, 2026
# 
# NOTE: This file contains NO SECRETS - safe for public repos
# Secrets are stored in Azure Key Vault: kv-personalwebsite-prod
#
# For local development, set these environment variables:
#   $env:TF_VAR_sql_admin_username = "sqladmin"
#   $env:TF_VAR_sql_admin_password = (az keyvault secret show --vault-name kv-personalwebsite-prod --name SqlAdminPassword --query value -o tsv)

subscription_id = "16e19706-c60e-4dcf-a24c-050487191622"
project_name    = "personalwebsite"
environment     = "prod"
location        = "East US"

# sql_admin_username - Retrieved from Key Vault (SqlAdminUsername)
# sql_admin_password - Retrieved from Key Vault (SqlAdminPassword)
