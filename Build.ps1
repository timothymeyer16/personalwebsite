<#
.SYNOPSIS
    Cleans and builds both the React frontend and .NET API projects.

.DESCRIPTION
    This script performs a clean build of the Personal Website solution:
    1. Cleans previous build artifacts
    2. Builds the React frontend (npm run build)
    3. Builds the .NET API (dotnet publish)
    4. Optionally copies React dist to API's wwwroot for combined deployment

.PARAMETER Configuration
    Build configuration: Debug or Release. Default is Release.

.PARAMETER SkipNpmInstall
    Skip npm install step if node_modules already exists.

.PARAMETER CombinedOutput
    Copy React build output to API's wwwroot for single-server deployment.

.EXAMPLE
    .\Build.ps1
    .\Build.ps1 -Configuration Debug
    .\Build.ps1 -CombinedOutput
#>

param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    
    [switch]$SkipNpmInstall,
    
    [switch]$CombinedOutput
)

$ErrorActionPreference = "Stop"
$RootPath = $PSScriptRoot
$ApiPath = Join-Path $RootPath "src\PersonalWebsite.Api"
$WebPath = Join-Path $RootPath "src\PersonalWebsite.Web"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Personal Website - Build Script" -ForegroundColor Cyan
Write-Host "  Configuration: $Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean
Write-Host "[1/4] Cleaning previous builds..." -ForegroundColor Yellow

# Clean .NET
if (Test-Path (Join-Path $ApiPath "bin")) {
    Remove-Item -Path (Join-Path $ApiPath "bin") -Recurse -Force
    Write-Host "  Cleaned: API bin folder" -ForegroundColor Gray
}
if (Test-Path (Join-Path $ApiPath "obj")) {
    Remove-Item -Path (Join-Path $ApiPath "obj") -Recurse -Force
    Write-Host "  Cleaned: API obj folder" -ForegroundColor Gray
}
if (Test-Path (Join-Path $ApiPath "wwwroot")) {
    Remove-Item -Path (Join-Path $ApiPath "wwwroot") -Recurse -Force
    Write-Host "  Cleaned: API wwwroot folder" -ForegroundColor Gray
}

# Clean React
if (Test-Path (Join-Path $WebPath "dist")) {
    Remove-Item -Path (Join-Path $WebPath "dist") -Recurse -Force
    Write-Host "  Cleaned: Web dist folder" -ForegroundColor Gray
}

Write-Host "  Clean complete!" -ForegroundColor Green
Write-Host ""

# Step 2: Install npm packages
Write-Host "[2/4] Installing npm packages..." -ForegroundColor Yellow
Push-Location $WebPath

if ($SkipNpmInstall -and (Test-Path "node_modules")) {
    Write-Host "  Skipping npm install (node_modules exists)" -ForegroundColor Gray
} else {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Pop-Location
        throw "npm install failed with exit code $LASTEXITCODE"
    }
    Write-Host "  npm install complete!" -ForegroundColor Green
}
Pop-Location
Write-Host ""

# Step 3: Build React frontend
Write-Host "[3/4] Building React frontend..." -ForegroundColor Yellow
Push-Location $WebPath

npm run build
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    throw "React build failed with exit code $LASTEXITCODE"
}

Pop-Location
Write-Host "  React build complete!" -ForegroundColor Green
Write-Host ""

# Step 4: Build .NET API
Write-Host "[4/4] Building .NET API..." -ForegroundColor Yellow
Push-Location $ApiPath

dotnet restore
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    throw "dotnet restore failed with exit code $LASTEXITCODE"
}

dotnet build --configuration $Configuration --no-restore
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    throw "dotnet build failed with exit code $LASTEXITCODE"
}

Pop-Location
Write-Host "  .NET build complete!" -ForegroundColor Green
Write-Host ""

# Optional: Copy React output to API wwwroot
if ($CombinedOutput) {
    Write-Host "[+] Copying React build to API wwwroot..." -ForegroundColor Yellow
    
    $SourcePath = Join-Path $WebPath "dist\*"
    $DestPath = Join-Path $ApiPath "wwwroot"
    
    if (-not (Test-Path $DestPath)) {
        New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
    }
    
    Copy-Item -Path $SourcePath -Destination $DestPath -Recurse -Force
    Write-Host "  Copied React build to wwwroot!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  To run combined app:" -ForegroundColor Cyan
    Write-Host "    cd $ApiPath" -ForegroundColor White
    Write-Host "    dotnet run" -ForegroundColor White
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output locations:" -ForegroundColor Cyan
Write-Host "  React: $WebPath\dist" -ForegroundColor White
Write-Host "  API:   $ApiPath\bin\$Configuration\net7.0" -ForegroundColor White
Write-Host ""
