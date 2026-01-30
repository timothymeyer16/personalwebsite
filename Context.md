# Personal Website — Project Context

> **Last Updated:** January 30, 2026  
> **Status:** Phase 5 - Infrastructure Deployment via DevOps

## Overview

A personal website with a React frontend and .NET Core backend, deployed to Azure with full CI/CD through Azure DevOps.

## Repositories & Services

| Service | URL |
|---------|-----|
| GitHub | https://github.com/timothymeyer16/personalwebsite |
| Azure DevOps | https://dev.azure.com/drayblaster/Personal%20Website |
| Azure Subscription | `16e19706-c60e-4dcf-a24c-050487191622` |
| Azure Tenant ID | `77611c66-c07b-476d-b6d9-9b68489d9220` |
| Terraform State Storage | `stpaborwebsitetfstate` (rg-terraform-state) |

## Azure DevOps Service Connection

| Property | Value |
|----------|-------|
| Service Connection Name | `Azure-ServiceConnection` |
| Service Principal (App) ID | `cc3acb81-e79a-41e0-bbf0-abaec0514bff` |
| App Registration Name | `AzureDevOps-ServiceConnection` |
| Role Assignment | Contributor (Subscription scope) |
| Created | January 30, 2026 |

> **Note:** Client secret stored securely in Azure DevOps. Expires January 2028.

## DevOps Deployment Architecture

### Core Principle: GitOps
**All deployments happen through Azure DevOps pipelines - never locally.**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEPLOYMENT WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Developer          Azure DevOps Pipeline              Azure Cloud          │
│   ─────────          ─────────────────────              ───────────          │
│                                                                              │
│   ┌─────────┐       ┌──────────────────────┐       ┌──────────────────┐     │
│   │  Push   │──────▶│  1. Security Scans   │       │                  │     │
│   │  Code   │       │     - GitLeaks       │       │   App Service    │     │
│   └─────────┘       │     - tfsec          │       │   SQL Database   │     │
│                     │     - Checkov        │       │   Key Vault      │     │
│                     └──────────┬───────────┘       │                  │     │
│                                │                    └────────▲─────────┘     │
│                                ▼                             │               │
│                     ┌──────────────────────┐                 │               │
│                     │  2. Build & Plan     │                 │               │
│                     │     - Terraform Plan │                 │               │
│                     │     - Show Changes   │                 │               │
│                     └──────────┬───────────┘                 │               │
│                                │                             │               │
│   ┌─────────┐                  ▼                             │               │
│   │ Review  │       ┌──────────────────────┐                 │               │
│   │ Changes │◀──────│  3. Manual Approval  │                 │               │
│   └────┬────┘       │     - Review Plan    │                 │               │
│        │            │     - Approve/Reject │                 │               │
│        ▼            └──────────┬───────────┘                 │               │
│   ┌─────────┐                  │                             │               │
│   │ Approve │                  ▼                             │               │
│   └────┬────┘       ┌──────────────────────┐                 │               │
│        │            │  4. Deploy           │─────────────────┘               │
│        └───────────▶│     - Terraform Apply│                                 │
│                     │     - App Deployment │                                 │
│                     └──────────────────────┘                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Pipeline Triggers

| Change Type | Pipeline | Trigger | Action |
|-------------|----------|---------|--------|
| `infra/**` changes | `azure-pipelines-infra.yml` | Push to main | Security scan → Plan → Approval → Apply |
| `src/**` changes | `azure-pipelines-app.yml` | Push to main | Build → Test → Approval → Deploy |
| Database migrations | `azure-pipelines-db.yml` | Manual | Approval → Run migrations |

### Security Scanning (All FREE)

| Tool | Purpose | Runs On |
|------|---------|---------|
| **GitLeaks** | Detect secrets in code | Every commit |
| **tfsec** | Terraform security issues | Infrastructure changes |
| **Checkov** | IaC compliance | Infrastructure changes |
| **OWASP Dependency Check** | Vulnerable packages | App builds |
| **npm audit** | JS dependency vulnerabilities | App builds |

### Manual Approval Gates

| Environment | Approvers | Required For |
|-------------|-----------|--------------|
| `infrastructure-prod` | Project Owner | Terraform apply |
| `production` | Project Owner | App deployment |
| `database-prod` | Project Owner | Database migrations |

## Secrets Management

All sensitive information is stored in **Azure Key Vault** - this repository is safe for public access.

| Secret Name | Location | Purpose |
|-------------|----------|---------|
| `SqlAdminUsername` | Key Vault | SQL Server admin username |
| `SqlAdminPassword` | Key Vault | SQL Server admin password |
| Service Principal Secret | Azure DevOps | Pipeline authentication |

**Key Vault:** `kv-personalwebsite-prod`

## Technology Stack

### Frontend
- **Framework:** React 18+ with TypeScript
- **Build Tool:** Vite
- **Styling:** Tailwind CSS
- **Hosting:** Served from .NET backend (single App Service)

### Backend
- **Framework:** .NET 8 LTS (Web API)
- **API Style:** REST with Swagger/OpenAPI documentation
- **Authentication:** Azure AD B2C (supports Google, Microsoft, email/password)
- **ORM:** Entity Framework Core 8

### Database
- **Production:** Azure SQL Database (Serverless tier, auto-pause)
- **Local:** SQL Server LocalDB
- **Migrations:** EF Core Code-First migrations

### Infrastructure
- **IaC Tool:** Terraform
- **Key Vault:** Yes (connection strings, secrets)
- **Storage Account:** No (not needed)
- **App Insights:** No (future consideration)

### DevOps
- **Pipelines:** Azure DevOps YAML
- **Branching:** main (production) / develop (integration)
- **PR Validation:** Yes

## Folder Structure

```
C:\Website\
├── src\
│   ├── PersonalWebsite.Api\         # .NET 8 Web API
│   │   ├── Controllers\
│   │   ├── Models\
│   │   ├── Data\                    # EF Core DbContext
│   │   ├── Services\
│   │   └── Program.cs
│   └── PersonalWebsite.Web\         # React + Vite + TypeScript
│       ├── src\
│       │   ├── components\
│       │   ├── pages\
│       │   ├── hooks\
│       │   ├── services\            # API client
│       │   └── App.tsx
│       ├── public\
│       ├── index.html
│       ├── vite.config.ts
│       ├── tailwind.config.js
│       └── tsconfig.json
├── infra\                           # Terraform
│   ├── main.tf                      # Root module
│   ├── variables.tf                 # Input variables
│   ├── outputs.tf                   # Output values
│   ├── terraform.tfvars             # Variable values (git-ignored)
│   ├── backend.tf                   # Remote state config
│   └── modules\
│       ├── app-service\
│       ├── sql-database\
│       ├── key-vault\
│       └── ad-b2c\
├── database\                        # Database scaffolding
│   ├── migrations\                  # EF Core migrations (generated)
│   ├── scripts\
│   │   ├── seed-data.sql
│   │   └── create-local-db.sql
│   ├── Deploy-Local.ps1             # Apply migrations to LocalDB
│   └── Deploy-Azure.ps1             # Apply migrations to Azure SQL
├── pipelines\                       # Azure DevOps YAML
│   ├── azure-pipelines-app.yml      # Build & deploy React + API
│   ├── azure-pipelines-infra.yml    # Terraform plan/apply
│   ├── azure-pipelines-db.yml       # Database migrations
│   └── templates\
│       ├── build-api.yml
│       ├── build-web.yml
│       └── deploy-app-service.yml
├── .gitignore
├── README.md
├── Context.md                       # This file
└── PersonalWebsite.sln              # Solution file
```

## Azure Resources (Terraform-managed)

| Resource | Name Pattern | SKU/Tier | Notes |
|----------|--------------|----------|-------|
| Resource Group | `rg-personalwebsite-prod` | — | Contains all resources |
| App Service Plan | `asp-personalwebsite-prod` | F1 (Free) | Upgrade to B1 for custom domain |
| App Service | `app-personalwebsite-prod` | — | Hosts API + React |
| Azure SQL Server | `sql-personalwebsite-prod` | — | Logical server |
| Azure SQL Database | `sqldb-personalwebsite-prod` | Serverless (Gen5, 1 vCore) | Auto-pause after 1 hour |
| Key Vault | `kv-personalwebsite-prod` | Standard | Stores connection strings |
| Azure AD B2C | `personalwebsiteb2c` | Free tier (50k MAU) | External identity provider |

## Authentication Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   React     │────▶│  Azure AD    │────▶│   .NET API  │
│   Frontend  │◀────│     B2C      │◀────│   Backend   │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                    ┌──────┴──────┐
                    │  Identity   │
                    │  Providers  │
                    │ (Google,    │
                    │  Microsoft, │
                    │  Email)     │
                    └─────────────┘
```

- **Public pages:** No auth required
- **Admin pages:** Require authenticated user with "Admin" role
- **Protected API endpoints:** Validate JWT tokens from B2C

## Environment Configuration

### Local Development
- **API URL:** `https://localhost:7001`
- **React Dev Server:** `http://localhost:5173` (proxies to API)
- **Database:** `(localdb)\MSSQLLocalDB` → `PersonalWebsiteDb`
- **Secrets:** .NET User Secrets (`secrets.json`)

### Production (Azure)
- **App Service URL:** `https://app-personalwebsite-prod.azurewebsites.net`
- **Custom Domain:** TBD (requires B1+ tier)
- **Database:** Azure SQL Serverless
- **Secrets:** Azure Key Vault references

## DevOps Pipeline Strategy

### Branching & Triggers

| Branch | Trigger | Action |
|--------|---------|--------|
| `develop` | Push/PR | Build + Test (validation only) |
| `main` | Push | Build + Test + Deploy to Production |
| `feature/*` | PR to develop | Build + Test (validation) |

### Pipeline Breakdown

1. **azure-pipelines-app.yml**
   - Builds React app (`npm run build`)
   - Builds .NET API (`dotnet publish`)
   - Copies React dist to API's `wwwroot`
   - Deploys combined artifact to App Service

2. **azure-pipelines-infra.yml**
   - Runs `terraform plan` on PR
   - Runs `terraform apply` on merge to main
   - Manual approval gate for production

3. **azure-pipelines-db.yml**
   - Runs EF Core migrations against Azure SQL
   - Triggered manually or by main branch

## Implementation Phases

### Phase 1: Foundation
- [ ] Initialize Git repo structure
- [ ] Create .NET 8 Web API project with EF Core
- [ ] Create React + Vite + TypeScript project
- [ ] Configure local development (User Secrets, LocalDB)
- [ ] Set up basic Swagger documentation

### Phase 2: Infrastructure
- [ ] Write Terraform modules for all Azure resources
- [ ] Configure Terraform remote state (Azure Storage)
- [ ] Set up Azure AD B2C tenant and app registrations
- [ ] Create Key Vault and seed initial secrets

### Phase 3: Database
- [ ] Design initial EF Core entities (User, Role, etc.)
- [ ] Create and test migrations locally
- [ ] Write PowerShell deployment scripts
- [ ] Seed development data

### Phase 4: Authentication
- [ ] Integrate Azure AD B2C with .NET API
- [ ] Configure MSAL in React frontend
- [ ] Implement protected routes and API endpoints
- [ ] Add Google identity provider in B2C

### Phase 5: DevOps
- [ ] Create Azure DevOps service connections
- [ ] Write YAML pipeline for app deployment
- [ ] Write YAML pipeline for infrastructure
- [ ] Write YAML pipeline for database migrations
- [ ] Configure PR validation policies

### Phase 6: Polish
- [ ] Add custom error handling
- [ ] Configure CORS properly
- [ ] Add health check endpoints
- [ ] Document API with Swagger annotations

## Known Limitations & Future Upgrades

| Current State | Future Upgrade | Trigger |
|---------------|----------------|---------|
| F1 App Service | B1+ Basic | Need custom domain with SSL |
| No staging slot | Add staging slot | Need zero-downtime deployments |
| No App Insights | Add monitoring | Need performance/error tracking |
| No CDN | Add Azure CDN | Need global performance |

## Manual Steps Required

> These cannot be fully automated with Terraform:

1. **Azure AD B2C Setup**
   - Create B2C tenant (Terraform)
   - Configure user flows (Portal: Sign-up/Sign-in flow)
   - Add Google identity provider (Portal: requires Google OAuth credentials)

2. **Azure DevOps**
   - Create service connection to Azure (Portal)
   - Create service connection to GitHub (Portal)
   - Configure branch policies (Portal)

3. **GitHub**
   - Protect `main` branch (require PR)
   - Link to Azure DevOps for pipeline status

## Quick Commands Reference

```powershell
# Local Development
cd C:\Website\src\PersonalWebsite.Api
dotnet run                              # Start API on https://localhost:7001

cd C:\Website\src\PersonalWebsite.Web
npm run dev                             # Start React on http://localhost:5173

# Database
cd C:\Website\database
.\Deploy-Local.ps1                      # Apply migrations to LocalDB
.\Deploy-Azure.ps1 -Environment prod    # Apply migrations to Azure

# Terraform
cd C:\Website\infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Troubleshooting

### Common Issues

1. **LocalDB not found**
   ```powershell
   sqllocaldb create MSSQLLocalDB
   sqllocaldb start MSSQLLocalDB
   ```

2. **EF Core migrations fail**
   ```powershell
   dotnet tool install --global dotnet-ef
   dotnet ef database update --project src/PersonalWebsite.Api
   ```

3. **React proxy not working**
   - Ensure API is running on https://localhost:7001
   - Check vite.config.ts proxy settings

4. **Terraform state lock**
   ```powershell
   terraform force-unlock <lock-id>
   ```
