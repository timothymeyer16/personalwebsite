# Personal Website — Azure Cloud & DevOps TODO List

> **Generated:** January 30, 2026  
> **Purpose:** Complete checklist for connecting to Azure Cloud and Azure DevOps

---

## 🎯 Target Architecture: GitOps Deployment

**Core Principle:** All deployments happen through Azure DevOps pipelines - never locally.

```
┌──────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌────────────┐
│  Push    │───▶│  Security   │───▶│   Build &   │───▶│   Manual    │───▶│   Deploy   │
│  Code    │    │   Scans     │    │    Plan     │    │  Approval   │    │  to Azure  │
└──────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └────────────┘
                 • GitLeaks         • Terraform Plan    • Review changes   • Terraform Apply
                 • tfsec            • Show diff         • Approve/Reject   • App Deploy
                 • Checkov          • Build artifacts
```

### Pipeline Responsibilities

| Pipeline | Trigger | What It Does |
|----------|---------|--------------|
| `azure-pipelines-infra.yml` | Changes to `infra/**` | Scans → Plans → Approves → Deploys infrastructure |
| `azure-pipelines-app.yml` | Changes to `src/**` | Builds → Tests → Approves → Deploys web app |
| `azure-pipelines-db.yml` | Manual trigger | Approves → Runs database migrations |

### Key Rules
1. ❌ **No local `terraform apply`** - all infrastructure via pipeline
2. ❌ **No direct Azure deployments** - all via service principal
3. ✅ **All secrets in Key Vault** - repo is public-safe
4. ✅ **Manual approval required** - review before any production change

---

## 📋 Status Legend

- ⬜ Not Started
- 🔲 In Progress
- ✅ Completed
- ⚠️ Blocked/Needs Review

---

## Phase 1: Azure Prerequisites & Account Setup

### 1.1 Azure Subscription Setup
- ✅ Verify Azure subscription is active (`16e19706-c60e-4dcf-a24c-050487191622`)
- ✅ Install Azure CLI locally (v2.80.0)
  ```powershell
  winget install Microsoft.AzureCLI
  ```
- ✅ Login to Azure CLI (completed Jan 30, 2026)
  ```powershell
  az login --tenant 77611c66-c07b-476d-b6d9-9b68489d9220 --use-device-code
  ```
- ✅ Verify subscription access and permissions
  - **Role:** Owner on subscription
  - **Tenant ID:** `77611c66-c07b-476d-b6d9-9b68489d9220`

### 1.2 Azure DevOps Organization Setup
- ✅ Access Azure DevOps organization: https://dev.azure.com/drayblaster/Personal%20Website
- ✅ Project exists and is accessible
- ⬜ Configure project visibility (Public/Private)
- ⬜ Set up project permissions and team members (if any)

### 1.3 Azure Cost Management & Budget Alerts
- ✅ Create budget with $50/month limit
- ✅ Configure email notifications to timothymeyer16@gmail.com
- ✅ Set alert thresholds:
  - **Actual:** 50%, 80%, 100%
  - **Forecasted:** 80%, 100%

---

## Phase 2: Terraform Remote State Setup

### 2.1 Create Storage Account for Terraform State
- ✅ Create Resource Group for Terraform state: `rg-terraform-state`
- ✅ Create Storage Account: `stpaborwebsitetfstate`
- ✅ Create blob container: `tfstate`

### 2.2 Enable Terraform Backend
- ✅ Updated backend configuration in `infra/backend.tf`
- ✅ Updated pipeline variable in `pipelines/azure-pipelines-infra.yml`
- ✅ Installed Terraform v1.14.4
- ✅ Ran `terraform init` - backend initialized
- ✅ Verified state file exists: `personalwebsite.terraform.tfstate`

---

## Phase 3: Azure DevOps Service Connections

### 3.1 Create Azure Resource Manager Service Connection
- ✅ Created App Registration: `AzureDevOps-ServiceConnection`
- ✅ Created Service Principal with Contributor role
- ✅ Created manual service connection in Azure DevOps
- ✅ Service connection name: `Azure-ServiceConnection`
- ✅ Verified connection successful

### 3.2 Create GitHub Service Connection (if using GitHub)
- ⬜ Go to Project Settings → Service connections
- ⬜ Click "New service connection" → "GitHub"
- ⬜ Authorize with GitHub OAuth or PAT
- ⬜ Service connection name: `GitHub-Connection`
- ⏭️ *Skipped for now - can add later if needed*

---

## Phase 4: Secrets Management (Key Vault)

> ✅ **PUBLIC REPO SAFE:** All secrets stored in Azure Key Vault

### 4.1 Key Vault Setup
- ✅ Created Key Vault: `kv-personalwebsite-prod`
- ✅ Stored `SqlAdminUsername` in Key Vault
- ✅ Stored `SqlAdminPassword` in Key Vault
- ✅ Granted Azure DevOps service principal access to Key Vault

### 4.2 Pipeline Updates
- ✅ Updated `azure-pipelines-infra.yml` to fetch secrets from Key Vault
- ✅ Removed secrets from `terraform.tfvars` (now safe to commit)
- ✅ Created comprehensive `.gitignore`

### 4.3 Local Development
> ⚠️ **Note:** Local Terraform is for planning/testing only. All applies go through DevOps.

---

## Phase 5: Deploy Infrastructure via DevOps Pipeline

> 🎯 **GitOps Approach:** All infrastructure deployment happens through Azure DevOps, not locally.

### 5.1 Update Infrastructure Pipeline
- ✅ Add security scanning stage (GitLeaks, tfsec, Checkov)
- ✅ Add human-readable plan output to approval
- ✅ Configure plan artifact for apply stage
- ✅ Fix Terraform module issues (Key Vault secrets now managed externally)

### 5.2 Setup Environment Approval Gates
- ⬜ Create `infrastructure-prod` environment in Azure DevOps
  1. Go to: Pipelines → Environments → New environment
  2. Name: `infrastructure-prod`
  3. Resource: None (managed by pipeline)
- ⬜ Add manual approval check (yourself as approver)
  1. Click on the environment → "..." menu → Approvals and checks
  2. Add "Approvals" → Add yourself as approver
- ⬜ Configure exclusive lock (prevent concurrent deployments)
  1. Add "Exclusive Lock" check

### 5.3 Import Existing Resources into Terraform State
> Since we created Key Vault and Resource Group manually, we need to import them.

- ⬜ Run import script: `.\infra\import-existing-resources.ps1`
  ```powershell
  cd c:\Website\infra
  .\import-existing-resources.ps1
  ```
- ⬜ Verify state with `terraform plan` (should show minimal changes)

### 5.4 First Deployment via Pipeline
- ⬜ Commit all changes and push to main
- ⬜ Pipeline triggers automatically
- ⬜ Review security scan results (GitLeaks, tfsec, Checkov)
- ⬜ Review Terraform plan output (shows ADD/CHANGE/DESTROY)
- ⬜ Approve deployment in Azure DevOps environment
- ⬜ Verify resources created:
  - App Service Plan: `asp-personalwebsite-prod` (F1 Free)
  - App Service: `app-personalwebsite-prod`
  - SQL Server: `sql-personalwebsite-prod`
  - SQL Database: `sqldb-personalwebsite-prod` (Serverless)

### 5.2 Verify Azure Resources Created
- ⬜ Resource Group: `rg-personalwebsite-prod`
- ⬜ App Service Plan: `asp-personalwebsite-prod` (F1 Free tier)
- ⬜ App Service: `app-personalwebsite-prod`
- ⬜ SQL Server: `sql-personalwebsite-prod`
- ⬜ SQL Database: `sqldb-personalwebsite-prod` (Serverless)
- ⬜ Key Vault: `kv-personalwebsite-prod`

---

## ~~Phase 5b: DevOps Security & Quality Scanning~~ (Merged into Phase 5.1)

> ✅ **COMPLETED:** Security scanning is now part of the infrastructure pipeline

### 5b.1 Secret Scanning (Prevent accidental commits)
- ✅ GitLeaks added to pipeline (scans for secrets in code)
- ⬜ Add **Microsoft Security DevOps** extension (optional enhancement)
- ⬜ Configure pre-commit hooks (optional, local)

### 5b.2 Infrastructure Security Scanning
- ✅ tfsec added to pipeline (Terraform security scanner)
- ✅ Checkov added to pipeline (IaC compliance)
- ⬜ Review and fix any security findings (after first run)

### 5b.3 Dependency Vulnerability Scanning
- ⬜ Add **OWASP Dependency Check** for .NET packages
- ⬜ Add **npm audit** for React packages
- ⬜ Configure **Snyk** integration (free tier: 200 tests/month)

### 5b.4 Code Quality Analysis
- ⬜ Set up **SonarCloud** (free for public repos)
- ⬜ Configure quality gates (bugs, vulnerabilities, code smells)
- ⬜ Add code coverage reporting

---

## Phase 5c: Branch Policies & Environment Approvals

### 5c.1 Branch Policies (Azure DevOps)
- ⬜ Configure `main` branch protection:
  - Require pull request before merging
  - Require at least 1 reviewer (or self-approve for solo dev)
  - Require build validation (pipeline must pass)
  - Require comment resolution
- ⬜ Configure `develop` branch protection:
  - Require pull request
  - Require build validation

### 5c.2 Environment Approvals
- ⬜ Create environment: `production`
  - Add approval gate (yourself as approver)
  - Add exclusive lock (prevent concurrent deployments)
- ⬜ Create environment: `infrastructure-prod`
  - Add approval gate for Terraform apply
- ⬜ Create environment: `database-prod`
  - Add approval gate for migration runs

### 5c.3 Pipeline Security
- ⬜ Review pipeline permissions
- ⬜ Enable artifact signing (optional)
- ⬜ Generate SBOM (Software Bill of Materials)

---

## Phase 6: Azure AD B2C Setup (Manual)

> ⚠️ **Note:** B2C cannot be fully automated with Terraform

### 6.1 Create Azure AD B2C Tenant
- ⬜ Go to Azure Portal → Create a resource
- ⬜ Search for "Azure Active Directory B2C"
- ⬜ Select "Create a new Azure AD B2C Tenant"
- ⬜ Organization name: `Personal Website`
- ⬜ Initial domain name: `personalwebsiteb2c`
- ⬜ Country/Region: `United States`
- ⬜ Link to subscription and resource group

### 6.2 Register API Application
- ⬜ Switch to B2C tenant directory
- ⬜ Go to App registrations → New registration
- ⬜ Name: `PersonalWebsite-API`
- ⬜ Supported account types: Accounts in any identity provider
- ⬜ Expose an API → Set Application ID URI
- ⬜ Add scopes: `access_as_user`
- ⬜ Note down: Application (client) ID

### 6.3 Register SPA Application
- ⬜ Go to App registrations → New registration
- ⬜ Name: `PersonalWebsite-Web`
- ⬜ Redirect URIs (SPA): 
  - `http://localhost:5173` (dev)
  - `https://app-personalwebsite-prod.azurewebsites.net` (prod)
- ⬜ API permissions → Add permission → My APIs → PersonalWebsite-API
- ⬜ Note down: Application (client) ID

### 6.4 Create User Flows
- ⬜ Go to User flows → New user flow
- ⬜ Create "Sign up and sign in" flow:
  - Name: `B2C_1_SignUpSignIn`
  - Identity providers: Email signup, Google, Microsoft
  - User attributes: Email, Display Name
  - Application claims: Select all needed claims
- ⬜ Create "Password reset" flow:
  - Name: `B2C_1_PasswordReset`

### 6.5 Configure Google Identity Provider (Optional)
- ⬜ Create Google OAuth credentials at https://console.developers.google.com
- ⬜ In B2C → Identity providers → Google
- ⬜ Enter Client ID and Client Secret

### 6.6 Update Application Configuration
- ⬜ Update `appsettings.json` with B2C details:
  ```json
  "AzureAdB2C": {
    "Instance": "https://personalwebsiteb2c.b2clogin.com",
    "Domain": "personalwebsiteb2c.onmicrosoft.com",
    "TenantId": "<tenant-id>",
    "ClientId": "<api-client-id>",
    "SignUpSignInPolicyId": "B2C_1_SignUpSignIn"
  }
  ```

---

## Phase 7: Key Vault Configuration

### 7.1 Add Secrets to Key Vault
- ⬜ SQL Connection String (auto-created by Terraform)
- ⬜ Verify App Service has Key Vault reference configured
- ⬜ Add B2C secrets (if needed):
  ```powershell
  az keyvault secret set `
    --vault-name kv-personalwebsite-prod `
    --name "AzureAdB2C--ClientSecret" `
    --value "<client-secret>"
  ```

### 7.2 Configure App Service Key Vault Access
- ⬜ Enable System Assigned Managed Identity on App Service
  ```powershell
  az webapp identity assign `
    --resource-group rg-personalwebsite-prod `
    --name app-personalwebsite-prod
  ```
- ⬜ Grant Key Vault access to App Service identity
  ```powershell
  $identity = az webapp identity show --name app-personalwebsite-prod --resource-group rg-personalwebsite-prod --query principalId -o tsv
  az keyvault set-policy `
    --name kv-personalwebsite-prod `
    --object-id $identity `
    --secret-permissions get list
  ```
- ⬜ Configure App Service to use Key Vault references:
  ```
  @Microsoft.KeyVault(SecretUri=https://kv-personalwebsite-prod.vault.azure.net/secrets/SqlConnectionString/)
  ```

---

## Phase 8: Azure DevOps Pipeline Variables

### 8.1 Create Variable Groups
- ⬜ Go to Pipelines → Library → Variable groups
- ⬜ Create group: `PersonalWebsite-Production`
  - `AzureSubscription`: `Azure-ServiceConnection`
  - `AppServiceName`: `app-personalwebsite-prod`
  - `ResourceGroupName`: `rg-personalwebsite-prod`
  - `KeyVaultName`: `kv-personalwebsite-prod`

### 8.2 Link Variable Group to Pipelines
- ⬜ Update pipeline YAML files to use variable groups
- ⬜ Grant pipeline permissions to access variable groups

---

## Phase 9: Create Azure DevOps Pipelines

### 9.1 Application Pipeline (azure-pipelines-app.yml)
- ⬜ Go to Pipelines → Create Pipeline
- ⬜ Select repository source (GitHub/Azure Repos)
- ⬜ Choose "Existing Azure Pipelines YAML file"
- ⬜ Select `/pipelines/azure-pipelines-app.yml`
- ⬜ Run the pipeline (validate build stage)
- ⬜ Verify deployment to App Service

### 9.2 Infrastructure Pipeline (azure-pipelines-infra.yml)
- ⬜ Create new pipeline for infrastructure
- ⬜ Select `/pipelines/azure-pipelines-infra.yml`
- ⬜ Create environment: `infrastructure-prod`
- ⬜ Add manual approval gate for Apply stage
- ⬜ Run pipeline and verify Terraform plan

### 9.3 Database Pipeline (azure-pipelines-db.yml)
- ⬜ Create new pipeline for database migrations
- ⬜ Select `/pipelines/azure-pipelines-db.yml`
- ⬜ Create environment: `database-prod`
- ⬜ Add manual approval gate (recommended)

---

## Phase 10: Configure Pipeline Environments

### 10.1 Create Environments
- ⬜ Go to Pipelines → Environments
- ⬜ Create environment: `production`
  - Add approval gate (yourself as approver)
  - Add exclusive lock (prevent concurrent deployments)
- ⬜ Create environment: `infrastructure-prod`
  - Add approval gate for Terraform apply
- ⬜ Create environment: `database-prod`
  - Add approval gate for migration runs

---

## Phase 11: Branch Policies

### 11.1 Azure DevOps Branch Policies (if using Azure Repos)
- ⬜ Go to Repos → Branches
- ⬜ Configure `main` branch policies:
  - Require pull request
  - Require at least 1 reviewer
  - Build validation (app pipeline)
  - Comment resolution
- ⬜ Configure `develop` branch policies:
  - Require pull request
  - Build validation

### 11.2 GitHub Branch Protection (if using GitHub)
- ⬜ Go to repository Settings → Branches
- ⬜ Add rule for `main`:
  - Require pull request before merging
  - Require status checks (Azure Pipeline)
  - Require linear history

---

## Phase 12: Database Setup

### 12.1 Run Initial Migration Locally
- ⬜ Ensure LocalDB is running
  ```powershell
  sqllocaldb start MSSQLLocalDB
  ```
- ⬜ Run local deployment script
  ```powershell
  cd C:\Website\database
  .\Deploy-Local.ps1 -CreateDatabase -SeedData
  ```
- ⬜ Verify local database created with tables

### 12.2 Run Azure Migration
- ⬜ Add your IP to SQL Server firewall
  ```powershell
  az sql server firewall-rule create `
    --resource-group rg-personalwebsite-prod `
    --server sql-personalwebsite-prod `
    --name AllowMyIP `
    --start-ip-address <your-ip> `
    --end-ip-address <your-ip>
  ```
- ⬜ Run Azure deployment script
  ```powershell
  .\Deploy-Azure.ps1 -KeyVaultName kv-personalwebsite-prod
  ```
- ⬜ Or trigger database pipeline in Azure DevOps

---

## Phase 13: Application Updates

### 13.1 Update .NET Version
> ⚠️ Project currently targets .NET 7 but should use .NET 8 LTS per Context.md

- ⬜ Update `PersonalWebsite.Api.csproj` to target `net8.0`
- ⬜ Update `app-service/main.tf` to use `v8.0`
- ⬜ Update `azure-pipelines-app.yml` dotnet version to `8.x`
- ⬜ Update `azure-pipelines-db.yml` dotnet version to `8.x`

### 13.2 Add Health Check Endpoint
- ⬜ Add `/health` endpoint to API for deployment verification
- ⬜ Verify deployment verification script works

### 13.3 Configure CORS
- ⬜ Add CORS configuration in `Program.cs` for B2C auth

---

## Phase 14: Verification & Testing

### 14.1 Local Development Verification
- ⬜ Run API locally: `dotnet run`
- ⬜ Run React dev server: `npm run dev`
- ⬜ Verify proxy working (API calls from React)
- ⬜ Verify Swagger UI at `https://localhost:7001/swagger`

### 14.2 Azure Deployment Verification
- ⬜ Access App Service URL: `https://app-personalwebsite-prod.azurewebsites.net`
- ⬜ Verify React app loads
- ⬜ Verify API endpoints work
- ⬜ Verify database connectivity

### 14.3 Pipeline Verification
- ⬜ Push a change to `develop` branch → Build validation runs
- ⬜ Create PR from `develop` to `main` → Build validation runs
- ⬜ Merge PR to `main` → Full deploy to production
- ⬜ Verify deployment succeeded

---

## Phase 15: Security & Compliance

### 15.1 Security Best Practices
- ⬜ Verify sensitive values are not in source control
- ⬜ Verify Key Vault is properly configured
- ⬜ Verify SQL Server firewall rules are minimal
- ⬜ Verify HTTPS is enforced on App Service
- ⬜ Review App Service authentication settings

### 15.2 Backup & Recovery
- ⬜ Document Terraform state backup procedure
- ⬜ Configure SQL Database backup retention
- ⬜ Document disaster recovery plan

---

## 📊 Quick Reference

### Important URLs
| Resource | URL |
|----------|-----|
| Azure Portal | https://portal.azure.com |
| Azure DevOps | https://dev.azure.com/drayblaster/Personal%20Website |
| App Service | https://app-personalwebsite-prod.azurewebsites.net |
| GitHub Repo | https://github.com/timothymeyer16/personalwebsite |

### Important Azure Resource Names
| Resource Type | Name |
|---------------|------|
| Resource Group | `rg-personalwebsite-prod` |
| App Service Plan | `asp-personalwebsite-prod` |
| App Service | `app-personalwebsite-prod` |
| SQL Server | `sql-personalwebsite-prod` |
| SQL Database | `sqldb-personalwebsite-prod` |
| Key Vault | `kv-personalwebsite-prod` |
| B2C Tenant | `personalwebsiteb2c.onmicrosoft.com` |

### Pipeline Service Connection
- Name: `Azure-ServiceConnection`
- Type: Azure Resource Manager
- Scope: Subscription

---

## 📝 Notes & Known Issues

1. **Terraform B2C Limitation**: Azure AD B2C tenant creation cannot be fully automated. Manual portal setup required.

2. **.NET Version Mismatch**: Code currently targets .NET 7, but Context.md specifies .NET 8 LTS. Update needed.

3. **F1 Limitations**: Free tier doesn't support:
   - Always On
   - Custom domains with SSL
   - Deployment slots
   - Upgrade to B1 when needed

4. **SQL Serverless Cold Start**: First connection after auto-pause may be slow (~1 minute).

5. **Key Vault References**: Requires managed identity configuration on App Service.

---

## ✅ Completion Checklist

- [ ] All Azure prerequisites configured
- [ ] Terraform state storage set up
- [ ] Azure DevOps service connections created
- [ ] Infrastructure deployed via Terraform
- [ ] Azure AD B2C configured
- [ ] Key Vault secrets populated
- [ ] All three pipelines created and tested
- [ ] Branch policies configured
- [ ] Database migrations applied
- [ ] Application verified working in Azure
- [ ] Security review completed

---

*Last updated: January 30, 2026*
