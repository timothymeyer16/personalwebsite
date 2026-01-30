# =============================================================================
# Import Existing Azure Resources into Terraform State
# =============================================================================
# This script imports resources that were manually created into Terraform state
# Run this ONCE before the first Terraform apply to avoid "resource exists" errors
#
# Prerequisites:
#   - Azure CLI logged in with appropriate permissions
#   - Terraform initialized with backend configuration
# =============================================================================

param(
    [string]$SubscriptionId = "16e19706-c60e-4dcf-a24c-050487191622",
    [string]$ResourceGroupName = "rg-personalwebsite-prod",
    [string]$KeyVaultName = "kv-personalwebsite-prod"
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================="
Write-Host "Importing Existing Resources into Terraform"
Write-Host "=============================================="
Write-Host ""

# Set subscription
Write-Host "Setting subscription to: $SubscriptionId"
az account set --subscription $SubscriptionId

# Change to infra directory
Push-Location $PSScriptRoot

try {
    # Initialize Terraform (if not already done)
    Write-Host ""
    Write-Host "Initializing Terraform..."
    terraform init

    # Import Resource Group
    Write-Host ""
    Write-Host "Importing Resource Group: $ResourceGroupName"
    $rgId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
    terraform import "azurerm_resource_group.main" $rgId 2>&1 | ForEach-Object {
        if ($_ -match "Resource already managed|Cannot import") {
            Write-Host "  Resource Group already in state or cannot import: $_" -ForegroundColor Yellow
        } else {
            Write-Host $_
        }
    }

    # Import Key Vault
    Write-Host ""
    Write-Host "Importing Key Vault: $KeyVaultName"
    $kvId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.KeyVault/vaults/$KeyVaultName"
    terraform import "module.key_vault.azurerm_key_vault.main" $kvId 2>&1 | ForEach-Object {
        if ($_ -match "Resource already managed|Cannot import") {
            Write-Host "  Key Vault already in state or cannot import: $_" -ForegroundColor Yellow
        } else {
            Write-Host $_
        }
    }

    Write-Host ""
    Write-Host "=============================================="
    Write-Host "Import Complete!"
    Write-Host "=============================================="
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Run 'terraform plan' to verify state"
    Write-Host "2. Commit and push to trigger the pipeline"
    Write-Host ""

} finally {
    Pop-Location
}
