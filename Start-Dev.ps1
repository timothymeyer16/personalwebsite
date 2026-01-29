<#
.SYNOPSIS
    Starts both the .NET API and React dev server for local development.

.DESCRIPTION
    Launches both servers in separate processes with hot reload enabled:
    - .NET API: dotnet watch run (https://localhost:7001)
    - React: npm run dev (http://localhost:5173)
    
    The Vite dev server proxies /api/* requests to the .NET backend.

.EXAMPLE
    .\Start-Dev.ps1
#>

$ErrorActionPreference = "Stop"
$RootPath = $PSScriptRoot
$ApiPath = Join-Path $RootPath "src\PersonalWebsite.Api"
$WebPath = Join-Path $RootPath "src\PersonalWebsite.Web"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Personal Website - Dev Mode" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting servers with hot reload..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  API:      https://localhost:7001" -ForegroundColor White
Write-Host "  Frontend: http://localhost:5173  (use this URL)" -ForegroundColor Green
Write-Host "  Swagger:  https://localhost:7001/swagger" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C in each window to stop." -ForegroundColor Gray
Write-Host ""

# Start .NET API in a new window with watch mode
$apiProcess = Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$ApiPath'; Write-Host 'Starting .NET API with hot reload...' -ForegroundColor Cyan; dotnet watch run" -PassThru

# Give the API a moment to start
Start-Sleep -Seconds 2

# Start React dev server in a new window
$webProcess = Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$WebPath'; Write-Host 'Starting React dev server...' -ForegroundColor Cyan; npm run dev" -PassThru

Write-Host "Both servers started!" -ForegroundColor Green
Write-Host ""
Write-Host "Open http://localhost:5173 in your browser." -ForegroundColor Cyan
Write-Host ""
