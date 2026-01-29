<#
.SYNOPSIS
    Deploys database migrations to LocalDB for development.

.DESCRIPTION
    This script runs Entity Framework Core migrations against the local development database.
    It ensures the database exists and applies all pending migrations.

.PARAMETER CreateDatabase
    If specified, creates the database using the SQL script before running migrations.

.PARAMETER SeedData
    If specified, runs the seed data script after migrations.

.EXAMPLE
    .\Deploy-Local.ps1
    
.EXAMPLE
    .\Deploy-Local.ps1 -CreateDatabase -SeedData
#>

param(
    [switch]$CreateDatabase,
    [switch]$SeedData
)

$ErrorActionPreference = "Stop"

# Configuration
$ProjectPath = Join-Path $PSScriptRoot "..\src\PersonalWebsite.Api\PersonalWebsite.Api.csproj"
$ScriptsPath = Join-Path $PSScriptRoot "scripts"
$ConnectionString = "Server=(localdb)\MSSQLLocalDB;Database=PersonalWebsiteDb;Trusted_Connection=True;MultipleActiveResultSets=true"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Local Database Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if dotnet-ef tool is installed
$efTool = dotnet tool list --global | Select-String "dotnet-ef"
if (-not $efTool) {
    Write-Host "Installing dotnet-ef tool..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-ef
}

# Create database if requested
if ($CreateDatabase) {
    Write-Host "Creating local database..." -ForegroundColor Yellow
    $createDbScript = Join-Path $ScriptsPath "create-local-db.sql"
    
    if (Test-Path $createDbScript) {
        sqlcmd -S "(localdb)\MSSQLLocalDB" -i $createDbScript
        Write-Host "Database created successfully." -ForegroundColor Green
    }
    else {
        Write-Warning "Create database script not found at: $createDbScript"
    }
}

# Run EF Core migrations
Write-Host ""
Write-Host "Running EF Core migrations..." -ForegroundColor Yellow

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

# Run seed data if requested
if ($SeedData) {
    Write-Host ""
    Write-Host "Applying seed data..." -ForegroundColor Yellow
    $seedScript = Join-Path $ScriptsPath "seed-data.sql"
    
    if (Test-Path $seedScript) {
        sqlcmd -S "(localdb)\MSSQLLocalDB" -d "PersonalWebsiteDb" -i $seedScript
        Write-Host "Seed data applied successfully." -ForegroundColor Green
    }
    else {
        Write-Warning "Seed data script not found at: $seedScript"
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Connection String:" -ForegroundColor Yellow
Write-Host $ConnectionString
