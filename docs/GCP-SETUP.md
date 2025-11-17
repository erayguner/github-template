# GCP Terraform CI/CD Setup Guide

This guide helps you set up a complete CI/CD pipeline for your GCP infrastructure using Terraform and GitHub Actions.

## Table of Contents
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [GCP Project Setup](#gcp-project-setup)
- [Required APIs](#required-apis)
- [GitHub Secrets Configuration](#github-secrets-configuration)
- [Terraform Backend Setup](#terraform-backend-setup)
- [Running the Pipeline](#running-the-pipeline)
- [Troubleshooting](#troubleshooting)

## Quick Start

Get started in 3 steps:

```bash
# 1. Clone or use this template
git clone https://github.com/erayguner/github-template.git
cd github-template

# 2. Run the automated setup script
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID

# 3. Push to trigger CI/CD
git push origin main
```

## Prerequisites

Before you begin, ensure you have:

- **GCP Account**: Active Google Cloud account with billing enabled
- **gcloud CLI**: [Install gcloud](https://cloud.google.com/sdk/docs/install)
- **Terraform**: Version 1.10+ [Install Terraform](https://www.terraform.io/downloads)
- **GitHub Repository**: Access to configure secrets
- **Git**: Version control client

### Verify Prerequisites

```bash
# Check gcloud installation
gcloud version

# Check terraform installation
terraform version

# Check git installation
git --version

# Authenticate with GCP
gcloud auth login
gcloud auth application-default login
```

## GCP Project Setup

### Step 1: Create or Select a GCP Project

```bash
# Create a new project
export GCP_PROJECT_ID="my-terraform-project-12345"
gcloud projects create $GCP_PROJECT_ID --name="My Terraform Project"

# Or list existing projects
gcloud projects list

# Set the project
gcloud config set project $GCP_PROJECT_ID
```

**Note**: GCP Project IDs must be:
- 6-30 characters long
- Start with a lowercase letter
- Contain only lowercase letters, numbers, and hyphens
- Be globally unique across all of Google Cloud

### Step 2: Enable Billing

```bash
# List billing accounts
gcloud billing accounts list

# Link billing account to project
gcloud billing projects link $GCP_PROJECT_ID \
  --billing-account=BILLING_ACCOUNT_ID
```

## Required APIs

Enable all required APIs for Terraform and CI/CD:

```bash
# Core APIs for Terraform
gcloud services enable \
  compute.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  serviceusage.googleapis.com \
  storage-api.googleapis.com \
  storage.googleapis.com

# Optional: Additional APIs based on your resources
gcloud services enable \
  container.googleapis.com \
  sqladmin.googleapis.com \
  dns.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  secretmanager.googleapis.com

# For Cloud Build (if using)
gcloud services enable cloudbuild.googleapis.com
```

### Verify API Enablement

```bash
# Check if APIs are enabled
gcloud services list --enabled --project=$GCP_PROJECT_ID
```

## GitHub Workload Identity Federation Setup

### Why Workload Identity Federation?

Workload Identity Federation is the **secure, modern way** to authenticate GitHub Actions to GCP:
- ✅ **No service account keys** to manage or rotate
- ✅ **Short-lived tokens** that expire automatically
- ✅ **Better security posture** - no long-lived credentials
- ✅ **Automatic token management** by GitHub and GCP

### Step 1: Create Service Account

```bash
# Create service account for GitHub Actions
export SA_NAME="github-actions-terraform"
gcloud iam service-accounts create $SA_NAME \
  --display-name="GitHub Actions Terraform" \
  --description="Service account for GitHub Actions CI/CD via Workload Identity"

# Grant necessary permissions
export SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"
```

### Step 2: Create Workload Identity Pool

```bash
# Enable IAM Credentials API
gcloud services enable iamcredentials.googleapis.com

# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Create Workload Identity Provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner == 'YOUR_GITHUB_USERNAME'" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Note: Replace YOUR_GITHUB_USERNAME with your actual GitHub username
```

### Step 3: Grant Service Account Access

```bash
# Get your GitHub repository details
export GITHUB_REPO="YOUR_GITHUB_USERNAME/github-template"

# Allow GitHub Actions to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${GCP_PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe ${GCP_PROJECT_ID} --format='value(projectNumber)')/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```

### Step 4: Get Workload Identity Provider Name

```bash
# Get the full workload identity provider resource name
export PROJECT_NUMBER=$(gcloud projects describe ${GCP_PROJECT_ID} --format='value(projectNumber)')
export WORKLOAD_IDENTITY_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"

echo "Workload Identity Provider: ${WORKLOAD_IDENTITY_PROVIDER}"
echo "Service Account Email: ${SA_EMAIL}"
```

### Step 5: Configure GitHub Repository Variables

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **Variables** tab, then **New repository variable**
4. Add the following variables:

| Variable Name                   | Value                                    | Description                    |
|---------------------------------|------------------------------------------|--------------------------------|
| `GCP_PROJECT_ID`                | Your GCP project ID                      | GCP project                    |
| `GCP_WORKLOAD_IDENTITY_PROVIDER`| Full workload identity provider path     | From step 4 above              |
| `GCP_SERVICE_ACCOUNT`           | Service account email                    | From step 1 above              |
| `TF_VAR_gcp_project_id`         | Your GCP project ID                      | Terraform variable             |

**Example values:**
```
GCP_PROJECT_ID: my-terraform-project-12345
GCP_WORKLOAD_IDENTITY_PROVIDER: projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider
GCP_SERVICE_ACCOUNT: github-actions-terraform@my-terraform-project-12345.iam.gserviceaccount.com
TF_VAR_gcp_project_id: my-terraform-project-12345
```

## Terraform Backend Setup

### Create GCS Bucket for Terraform State

```bash
# Create unique bucket name
export TF_STATE_BUCKET="${GCP_PROJECT_ID}-terraform-state"
export GCP_REGION="us-central1"

# Create bucket
gcloud storage buckets create gs://$TF_STATE_BUCKET \
  --project=$GCP_PROJECT_ID \
  --location=$GCP_REGION \
  --uniform-bucket-level-access

# Enable versioning for state file protection
gcloud storage buckets update gs://$TF_STATE_BUCKET \
  --versioning

# Add lifecycle policy to keep old versions for 30 days
cat > lifecycle.json <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 5,
          "daysSinceNoncurrentTime": 30
        }
      }
    ]
  }
}
EOF

gcloud storage buckets update gs://$TF_STATE_BUCKET \
  --lifecycle-file=lifecycle.json

rm lifecycle.json
```

### Configure Terraform Backend

Update `terraform/main.tf` to use the GCS backend:

```hcl
terraform {
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-terraform-state"
    prefix = "terraform/state"
  }

  required_version = ">= 1.10.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
```

## Running the Pipeline

### Update Terraform Variables

Create `terraform/terraform.tfvars`:

```hcl
# GCP Configuration
gcp_project_id = "YOUR_PROJECT_ID"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# Enable GCP resources
enable_gcp = true
enable_aws = false

# Project Configuration
project_name = "my-terraform-project"
environment  = "dev"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Additional tags
tags = {
  Team        = "DevOps"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
```

### Test Locally

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure (review output)
terraform plan

# Apply changes (when ready)
terraform apply
```

### Trigger GitHub Actions Pipeline

```bash
# Commit your changes
git add .
git commit -m "feat: configure GCP project for CI/CD"

# Push to trigger CI/CD
git push origin main
```

The CI/CD pipeline will automatically:
1. Detect Terraform files
2. Check formatting (`terraform fmt`)
3. Validate configuration (`terraform validate`)
4. Run security scans (tfsec, checkov)
5. Upload results to GitHub Security tab

## Troubleshooting

### Common Issues

#### 1. "Project not found" Error

**Solution**:
```bash
# Verify project exists and is active
gcloud projects describe $GCP_PROJECT_ID

# Set the correct project
gcloud config set project $GCP_PROJECT_ID
```

#### 2. "API not enabled" Error

**Solution**:
```bash
# Enable the specific API mentioned in the error
gcloud services enable SERVICE_NAME.googleapis.com

# Example for Compute Engine
gcloud services enable compute.googleapis.com
```

#### 3. "Permission denied" Error

**Solution**:
```bash
# Check service account permissions
gcloud projects get-iam-policy $GCP_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${SA_EMAIL}"

# Add missing role
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/REQUIRED_ROLE"
```

#### 4. GitHub Actions Workload Identity Authentication Fails

**Solution**:
1. Verify all GitHub repository variables are set correctly
2. Check workload identity pool and provider exist
3. Ensure service account has proper IAM bindings

```bash
# Verify workload identity pool exists
gcloud iam workload-identity-pools describe github-pool \
  --location=global \
  --project=$GCP_PROJECT_ID

# Verify provider exists
gcloud iam workload-identity-pools providers describe github-provider \
  --location=global \
  --workload-identity-pool=github-pool \
  --project=$GCP_PROJECT_ID

# Check service account IAM policy
gcloud iam service-accounts get-iam-policy $SA_EMAIL \
  --project=$GCP_PROJECT_ID

# Re-add workload identity user binding if missing
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${GCP_PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```

#### 5. Terraform State Locking Issues

**Solution**:
```bash
# List locks on state bucket
gsutil ls gs://$TF_STATE_BUCKET/**/*.lock

# Remove stale lock (use with caution)
gsutil rm gs://$TF_STATE_BUCKET/terraform/state/default.tflock
```

### Getting Help

- **GCP Documentation**: https://cloud.google.com/docs
- **Terraform GCP Provider**: https://registry.terraform.io/providers/hashicorp/google/latest/docs
- **GitHub Issues**: Report issues at [repository issues page]

## Next Steps

1. **Review Security**: Check [SECURITY.md](../SECURITY.md) for best practices
2. **Set Up Monitoring**: Configure Cloud Monitoring and Logging
3. **Cost Management**: Set up billing alerts and budgets
4. **Environment Separation**: Create separate projects for dev/staging/prod
5. **Cloud Build Integration**: See [CLOUD-BUILD.md](CLOUD-BUILD.md) for advanced CI/CD

## Security Best Practices

1. **Use Workload Identity Federation** instead of service account keys (no long-lived credentials)
2. **Use least-privilege IAM roles** for service accounts
3. **Enable VPC Service Controls** for production environments
4. **Restrict workload identity pools** to specific repositories/branches using attribute conditions
5. **Enable audit logging** for all API calls
6. **Use separate projects** for different environments
7. **Implement billing alerts** to avoid unexpected costs
8. **Monitor workload identity usage** via Cloud Logging

## Cost Optimization

```bash
# Set up billing budget alert
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget Alert" \
  --budget-amount=100USD \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100
```

## Additional Resources

- [GCP Free Tier](https://cloud.google.com/free)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
