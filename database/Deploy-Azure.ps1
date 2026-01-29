<#
.SYNOPSIS
    Deploys database migrations to Azure SQL Database.

.DESCRIPTION
    This script runs Entity Framework Core migrations against the Azure SQL Database.
    It requires the connection string to be provided or retrieved from Azure Key Vault.

.PARAMETER ConnectionString
    The Azure SQL connection string. If not provided, attempts to retrieve from Key Vault.

.PARAMETER KeyVaultName
    The name of the Azure Key Vault containing the connection string secret.

.PARAMETER SecretName
    The name of the secret in Key Vault containing the connection string.
    Default: "SqlConnectionString"

.PARAMETER Environment
    The target environment (prod, staging). Default: prod

.EXAMPLE
    .\Deploy-Azure.ps1 -ConnectionString "Server=tcp:sql-personalwebsite-prod.database.windows.net..."
    
.EXAMPLE
    .\Deploy-Azure.ps1 -KeyVaultName "kv-personalwebsite-prod"
#>

param(
    [string]$ConnectionString,
    [string]$KeyVaultName = "kv-personalwebsite-prod",
    [string]$SecretName = "SqlConnectionString",
    [string]$Environment = "prod"
)

$ErrorActionPreference = "Stop"

# Configuration
$ProjectPath = Join-Path $PSScriptRoot "..\src\PersonalWebsite.Api\PersonalWebsite.Api.csproj"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Azure Database Deployment Script" -ForegroundColor Cyan
Write-Host "  Environment: $Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if dotnet-ef tool is installed
$efTool = dotnet tool list --global | Select-String "dotnet-ef"
if (-not $efTool) {
    Write-Host "Installing dotnet-ef tool..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-ef
}

# Get connection string from Key Vault if not provided
if (-not $ConnectionString) {
    Write-Host "Retrieving connection string from Key Vault: $KeyVaultName" -ForegroundColor Yellow
    
    try {
        # Ensure Azure CLI is logged in
        $account = az account show 2>$null | ConvertFrom-Json
        if (-not $account) {
            Write-Host "Please log in to Azure CLI..." -ForegroundColor Yellow
            az login
        }
        
        # Get secret from Key Vault
        $ConnectionString = az keyvault secret show --vault-name $KeyVaultName --name $SecretName --query "value" -o tsv
        
        if (-not $ConnectionString) {
            throw "Could not retrieve connection string from Key Vault"
        }
        
        Write-Host "Connection string retrieved successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to retrieve connection string from Key Vault: $_"
        Write-Host ""
        Write-Host "You can also provide the connection string directly:" -ForegroundColor Yellow
        Write-Host '.\Deploy-Azure.ps1 -ConnectionString "Server=tcp:..."' -ForegroundColor Yellow
        exit 1
    }
}

# Confirm deployment
Write-Host ""
Write-Host "WARNING: You are about to apply migrations to Azure SQL Database!" -ForegroundColor Red
Write-Host "Environment: $Environment" -ForegroundColor Yellow
$confirmation = Read-Host "Are you sure you want to continue? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Run EF Core migrations
Write-Host ""
Write-Host "Running EF Core migrations against Azure SQL..." -ForegroundColor Yellow

try {
    Push-Location (Split-Path $ProjectPath -Parent)
    dotnet ef database update --project $ProjectPath --connection $ConnectionString
    Write-Host "Migrations applied successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to apply migrations: $_"
    exit 1
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Azure Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
