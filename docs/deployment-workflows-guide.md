# GitHub Actions Deployment Workflows Guide

## Overview

This repository includes comprehensive GitHub Actions workflows for deploying infrastructure and applications to AWS and GCP. The workflows follow cloud best practices for security, automation, and reliability.

## Table of Contents

1. [Workflow Files](#workflow-files)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Workflow Features](#workflow-features)
5. [Usage Examples](#usage-examples)
6. [Security Configuration](#security-configuration)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Workflow Files

### 1. AWS Deployment (`aws-deploy.yml`)

Comprehensive workflow for deploying infrastructure and applications to AWS.

**Key Features:**
- Multi-environment support (dev, staging, prod)
- OIDC authentication (no long-lived credentials)
- Terraform-based infrastructure management
- Automated security scanning (tfsec, Checkov, Trufflehog)
- Environment-specific deployments
- Automated rollback capabilities
- Post-deployment validation
- Slack notifications

**Triggers:**
- Push to `main`, `develop`, or `release/**` branches
- Pull requests
- Manual workflow dispatch

### 2. GCP Deployment (`gcp-deploy.yml`)

Comprehensive workflow for deploying infrastructure and applications to GCP.

**Key Features:**
- Workload Identity Federation for secure authentication
- Multi-project support
- Terraform state management with GCS
- Security scanning and validation
- Cloud Functions, Cloud Run, and GKE deployment support
- Automated health checks
- Rollback mechanisms

**Triggers:**
- Push to `main`, `develop`, or `release/**` branches
- Pull requests
- Manual workflow dispatch

### 3. Multi-Cloud Deployment (`multi-cloud-deploy.yml`)

Orchestrates deployments across both AWS and GCP.

**Key Features:**
- Unified deployment strategy
- Cross-cloud validation
- Cost analysis with Infracost
- Compliance checking
- Reusable workflow composition
- Deployment summaries

**Triggers:**
- Push to `main`, `develop` branches
- Pull requests
- Manual workflow dispatch with cloud selection

---

## Prerequisites

### General Requirements

1. **Terraform**
   - Version 1.6.0 or compatible
   - Directory structure:
     ```
     terraform/
     ├── aws/
     │   ├── environments/
     │   │   ├── dev.tfvars
     │   │   ├── staging.tfvars
     │   │   └── prod.tfvars
     │   └── main.tf
     └── gcp/
         ├── environments/
         │   ├── dev.tfvars
         │   ├── staging.tfvars
         │   └── prod.tfvars
         └── main.tf
     ```

2. **GitHub Environments**
   - Create environments: `dev`, `staging`, `prod`
   - Configure environment protection rules
   - Set environment-specific secrets

3. **Required GitHub Permissions**
   - `contents: read`
   - `id-token: write` (for OIDC)
   - `security-events: write` (for SARIF uploads)
   - `pull-requests: write` (for PR comments)

### AWS-Specific Requirements

1. **AWS IAM Configuration**
   - Create OIDC provider for GitHub Actions
   - Create IAM roles with appropriate policies
   - Set up S3 backend for Terraform state
   - Create DynamoDB table for state locking

2. **Required AWS Services**
   - S3 (for Terraform state storage)
   - DynamoDB (for state locking)
   - IAM (for authentication)
   - Services you're deploying (Lambda, ECS, etc.)

### GCP-Specific Requirements

1. **GCP IAM Configuration**
   - Enable Workload Identity Federation
   - Create service accounts with appropriate roles
   - Set up GCS bucket for Terraform state
   - Configure project-level permissions

2. **Required GCP Services**
   - Cloud Storage (for Terraform state)
   - IAM & Admin (for authentication)
   - Services you're deploying (Cloud Functions, Cloud Run, GKE, etc.)

---

## Environment Setup

### Step 1: Configure GitHub Secrets

#### AWS Secrets (per environment: dev, staging, prod)

```yaml
# Format: SECRET_NAME_ENVIRONMENT
AWS_ROLE_ARN_dev: arn:aws:iam::123456789012:role/github-actions-dev
AWS_ROLE_ARN_staging: arn:aws:iam::123456789012:role/github-actions-staging
AWS_ROLE_ARN_prod: arn:aws:iam::123456789012:role/github-actions-prod

AWS_TFSTATE_BUCKET_dev: my-terraform-state-dev
AWS_TFSTATE_BUCKET_staging: my-terraform-state-staging
AWS_TFSTATE_BUCKET_prod: my-terraform-state-prod

AWS_TFSTATE_LOCK_TABLE_dev: terraform-state-lock-dev
AWS_TFSTATE_LOCK_TABLE_staging: terraform-state-lock-staging
AWS_TFSTATE_LOCK_TABLE_prod: terraform-state-lock-prod
```

#### GCP Secrets (per environment: dev, staging, prod)

```yaml
GCP_WORKLOAD_IDENTITY_PROVIDER_dev: projects/123/locations/global/workloadIdentityPools/pool/providers/provider
GCP_WORKLOAD_IDENTITY_PROVIDER_staging: projects/456/locations/global/workloadIdentityPools/pool/providers/provider
GCP_WORKLOAD_IDENTITY_PROVIDER_prod: projects/789/locations/global/workloadIdentityPools/pool/providers/provider

GCP_SERVICE_ACCOUNT_dev: github-actions@project-dev.iam.gserviceaccount.com
GCP_SERVICE_ACCOUNT_staging: github-actions@project-staging.iam.gserviceaccount.com
GCP_SERVICE_ACCOUNT_prod: github-actions@project-prod.iam.gserviceaccount.com

GCP_PROJECT_ID_dev: my-project-dev
GCP_PROJECT_ID_staging: my-project-staging
GCP_PROJECT_ID_prod: my-project-prod

GCP_TFSTATE_BUCKET_dev: my-terraform-state-dev
GCP_TFSTATE_BUCKET_staging: my-terraform-state-staging
GCP_TFSTATE_BUCKET_prod: my-terraform-state-prod
```

#### Optional Secrets

```yaml
# For cost analysis
INFRACOST_API_KEY: your-infracost-api-key

# For notifications
SLACK_WEBHOOK_URL: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### Step 2: Set Up AWS OIDC

```bash
# 1. Create OIDC provider in AWS
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# 2. Create IAM role with trust policy
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
  --role-name github-actions-terraform \
  --assume-role-policy-document file://trust-policy.json

# 3. Attach permissions policy
aws iam attach-role-policy \
  --role-name github-actions-terraform \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# 4. Create S3 bucket for state
aws s3api create-bucket \
  --bucket my-terraform-state-dev \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket my-terraform-state-dev \
  --versioning-configuration Status=Enabled

# 5. Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Step 3: Set Up GCP Workload Identity

```bash
# 1. Enable required APIs
gcloud services enable iamcredentials.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable sts.googleapis.com

# 2. Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --location="global" \
  --description="Pool for GitHub Actions" \
  --display-name="GitHub Actions Pool"

# 3. Create Workload Identity Provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# 4. Create Service Account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions"

# 5. Grant permissions to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:github-actions@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# 6. Allow GitHub to impersonate service account
gcloud iam service-accounts add-iam-policy-binding \
  github-actions@PROJECT_ID.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_ORG/YOUR_REPO"

# 7. Create GCS bucket for state
gsutil mb -p PROJECT_ID -l us-central1 gs://my-terraform-state-dev
gsutil versioning set on gs://my-terraform-state-dev
```

### Step 4: Create Environment-Specific tfvars

**AWS Example** (`terraform/aws/environments/dev.tfvars`):
```hcl
environment = "dev"
aws_region  = "us-west-2"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Application Configuration
instance_type = "t3.micro"
min_size      = 1
max_size      = 3

# Tags
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "my-project"
}
```

**GCP Example** (`terraform/gcp/environments/dev.tfvars`):
```hcl
environment = "dev"
gcp_region  = "us-west1"

# Network Configuration
network_cidr = "10.0.0.0/16"

# Compute Configuration
machine_type = "e2-micro"
min_replicas = 1
max_replicas = 3

# Labels
labels = {
  environment = "dev"
  managed_by  = "terraform"
  project     = "my-project"
}
```

---

## Workflow Features

### Security Features

1. **OIDC Authentication**
   - No long-lived credentials stored in GitHub
   - Short-lived tokens with minimal permissions
   - Automatic credential rotation

2. **Security Scanning**
   - **tfsec**: Terraform static analysis
   - **Checkov**: Infrastructure security scanning
   - **Trufflehog**: Secret detection
   - **CodeQL**: Code security analysis
   - SARIF upload to GitHub Security tab

3. **Least Privilege**
   - Environment-specific IAM roles
   - Minimum required permissions
   - Conditional access based on repository

### Deployment Features

1. **Environment Management**
   - Automatic environment detection from branch
   - Manual environment selection via workflow dispatch
   - Environment-specific configurations

2. **Terraform Workflow**
   - Format checking
   - Security validation
   - Plan generation with diff
   - Apply with approval gates
   - State management

3. **Deployment Validation**
   - Pre-deployment security scans
   - Post-deployment health checks
   - Smoke tests
   - Monitoring verification

4. **Rollback Capabilities**
   - Manual rollback trigger
   - Automatic rollback on failure
   - State preservation

### Monitoring & Notifications

1. **PR Comments**
   - Terraform plan output
   - Security scan results
   - Cost analysis
   - Deployment summary

2. **Slack Notifications**
   - Deployment status
   - Environment information
   - Triggered by information
   - Error details

3. **Artifacts**
   - Terraform plans (5-day retention)
   - Terraform outputs (30-day retention)
   - Security scan results
   - Cost analysis reports

---

## Usage Examples

### Example 1: Deploy to Dev (Automatic)

```bash
# Create feature branch
git checkout -b feature/new-api

# Make changes to Terraform
vim terraform/aws/main.tf

# Commit and push
git add terraform/aws/main.tf
git commit -m "feat: add new API gateway"
git push origin feature/new-api

# Create PR - workflow runs automatically
# - Security scans execute
# - Terraform plan generated
# - Plan posted to PR
# - No deployment (dev environment)
```

### Example 2: Deploy to Staging (Automatic)

```bash
# Merge to develop branch
git checkout develop
git merge feature/new-api
git push origin develop

# Workflow triggers automatically:
# 1. Security scanning
# 2. Terraform plan for staging
# 3. Terraform apply to staging
# 4. Application deployment
# 5. Post-deployment validation
# 6. Notifications sent
```

### Example 3: Deploy to Production (Automatic)

```bash
# Merge to main branch
git checkout main
git merge develop
git push origin main

# Workflow triggers automatically:
# 1. Enhanced security scanning
# 2. Terraform plan for production
# 3. Manual approval required (via GitHub Environment)
# 4. Terraform apply to production
# 5. Application deployment
# 6. Extensive validation
# 7. Monitoring verification
# 8. Notifications sent
```

### Example 4: Manual Deployment

Navigate to GitHub Actions → Select workflow → Run workflow

**AWS Deployment Options:**
- Environment: `dev`, `staging`, or `prod`
- Action: `deploy`, `plan-only`, or `destroy`

**Multi-Cloud Deployment Options:**
- Environment: `dev`, `staging`, or `prod`
- Clouds: `aws`, `gcp`, or `all`
- Action: `deploy`, `plan-only`, or `destroy`

### Example 5: Plan-Only Execution

```bash
# Via workflow dispatch
# Select: action = "plan-only"

# This will:
# 1. Run security scans
# 2. Generate Terraform plan
# 3. Post plan to PR (if applicable)
# 4. NOT apply any changes
```

### Example 6: Rollback

```bash
# Via workflow dispatch
# Select: action = "destroy"

# Or triggered automatically on deployment failure
# The rollback job will:
# 1. Initialize Terraform
# 2. Revert to previous state
# 3. Verify rollback success
# 4. Notify stakeholders
```

---

## Security Configuration

### Recommended IAM Policies

**AWS Terraform Execution Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "dynamodb:*",
        "lambda:*",
        "iam:GetRole",
        "iam:PassRole",
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state-*/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock-*"
    }
  ]
}
```

**GCP Service Account Roles:**
```bash
# Terraform execution
roles/compute.admin
roles/storage.admin
roles/iam.serviceAccountUser

# State management
roles/storage.objectAdmin  # for state bucket
```

### Secret Management Best Practices

1. **Use GitHub Environments**
   - Separate secrets per environment
   - Environment protection rules
   - Required reviewers for production

2. **Rotate Credentials Regularly**
   - OIDC tokens automatically rotate
   - Review service account permissions quarterly
   - Audit access logs monthly

3. **Minimal Scope**
   - Grant only necessary permissions
   - Use separate roles per environment
   - Implement resource-based policies

4. **Secret Scanning**
   - Trufflehog runs on every commit
   - GitHub secret scanning enabled
   - Pre-commit hooks for local scanning

---

## Troubleshooting

### Common Issues

#### 1. OIDC Authentication Fails

**Symptoms:**
```
Error: Could not assume role with OIDC
```

**Solutions:**
```bash
# Verify OIDC provider exists
aws iam list-open-id-connect-providers

# Check role trust policy
aws iam get-role --role-name github-actions-terraform

# Verify repository is allowed in trust policy
# Subject should match: "repo:YOUR_ORG/YOUR_REPO:*"

# Check GitHub token permissions
# Ensure id-token: write is set
```

#### 2. Terraform State Lock

**Symptoms:**
```
Error: Error acquiring the state lock
```

**Solutions:**
```bash
# AWS: Check DynamoDB table
aws dynamodb get-item \
  --table-name terraform-state-lock-dev \
  --key '{"LockID": {"S": "terraform-state-dev"}}'

# If stuck, force unlock (use with caution)
terraform force-unlock <LOCK_ID>

# GCP: Check state file
gsutil ls -l gs://my-terraform-state-dev/**/.terraform.tflock.info
```

#### 3. Security Scan Failures

**Symptoms:**
```
tfsec found security issues
```

**Solutions:**
```bash
# Run locally
cd terraform/aws
tfsec .

# Common fixes:
# - Enable encryption at rest
# - Use secure protocols (HTTPS)
# - Implement least privilege IAM
# - Add security group rules
# - Enable logging

# Add exceptions (use sparingly)
# tfsec:ignore:AWS001
resource "aws_s3_bucket" "example" {
  # ...
}
```

#### 4. Plan Shows No Changes But Apply Fails

**Symptoms:**
```
Plan shows no changes, but apply fails with errors
```

**Solutions:**
```bash
# State might be out of sync
terraform state pull

# Refresh state
terraform refresh

# Verify backend configuration
terraform init -reconfigure

# Check for manual changes
# Compare actual infrastructure vs state file
```

#### 5. Deployment Timeout

**Symptoms:**
```
Job exceeded maximum execution time
```

**Solutions:**
```yaml
# Increase timeout in workflow
jobs:
  terraform-apply:
    timeout-minutes: 60  # Increase from default 30

# Or break into smaller deployments
# Use targeted applies
terraform apply -target=module.vpc
```

### Debug Mode

Enable debug output:

```yaml
# In workflow file, add to Terraform steps:
env:
  TF_LOG: DEBUG
  TF_LOG_PATH: terraform-debug.log

# Upload debug logs
- name: Upload Debug Logs
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: terraform-debug-logs
    path: terraform-debug.log
```

### Checking Workflow Status

```bash
# Using GitHub CLI
gh run list --workflow=aws-deploy.yml

# View specific run
gh run view <RUN_ID>

# View logs
gh run view <RUN_ID> --log
```

---

## Best Practices

### 1. Branch Strategy

```
main (production)
  └── develop (staging)
      └── feature/* (dev/testing)
```

- **feature branches**: Plan only, no deployment
- **develop**: Auto-deploy to staging
- **main**: Auto-deploy to production (with approval)

### 2. Environment Protection

Configure GitHub Environment rules:

**Development:**
- No protection rules
- Automatic deployment

**Staging:**
- Optional: 1 reviewer required
- Automatic deployment after approval

**Production:**
- Required reviewers: 2
- Deployment branches: main only
- Wait timer: 5 minutes
- Environment secrets: production-only

### 3. Cost Management

```yaml
# Add cost checks to workflows
- name: Cost Threshold Check
  run: |
    COST=$(infracost breakdown --path . --format json | jq '.totalMonthlyCost')
    if (( $(echo "$COST > 1000" | bc -l) )); then
      echo "Cost exceeds threshold: $COST"
      exit 1
    fi
```

### 4. Terraform Module Structure

```
terraform/
├── aws/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   ├── environments/
│   │   ├── dev.tfvars
│   │   ├── staging.tfvars
│   │   └── prod.tfvars
│   └── modules/
│       ├── vpc/
│       ├── compute/
│       └── database/
└── gcp/
    └── (same structure)
```

### 5. Version Pinning

```hcl
# In terraform blocks
terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 6. State Management

```hcl
# Always use remote state
terraform {
  backend "s3" {
    # Configuration via -backend-config
    # Never hardcode credentials
  }
}

# Enable versioning on state buckets
# Enable encryption at rest
# Use state locking (DynamoDB/GCS)
```

### 7. Monitoring & Alerting

```yaml
# Add CloudWatch/Cloud Monitoring
# Set up alerts for:
# - Deployment failures
# - State lock issues
# - Cost anomalies
# - Security findings

# Integrate with incident management
# - PagerDuty
# - Opsgenie
# - Slack
```

### 8. Documentation

- Keep this guide updated
- Document infrastructure decisions
- Maintain runbooks for common operations
- Update changelog for workflow changes

### 9. Testing

```yaml
# Pre-deployment testing
- terraform validate
- terraform plan
- tfsec scan
- checkov scan

# Post-deployment testing
- Health checks
- Smoke tests
- Integration tests
- Performance tests
```

### 10. Compliance & Auditing

```yaml
# Enable audit logging
# - CloudTrail (AWS)
# - Cloud Audit Logs (GCP)

# Regular compliance checks
# - GDPR
# - HIPAA
# - SOC2
# - PCI-DSS

# Track all deployments
# - Who deployed
# - What changed
# - When deployed
# - Why deployed (PR link)
```

---

## Workflow Diagram

```
┌─────────────────┐
│   Code Change   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  GitHub Push    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Determine Environment  │
│  - dev / staging / prod │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Security Scanning     │
│  - tfsec / Checkov      │
│  - Secret detection     │
│  - CodeQL analysis      │
└────────┬────────────────┘
         │
         ├─── FAIL ───► Notify & Stop
         │
         ▼
┌─────────────────────────┐
│   Terraform Plan        │
│  - Format check         │
│  - Validate config      │
│  - Generate plan        │
└────────┬────────────────┘
         │
         ├─── No changes ───► Skip Apply
         │
         ▼
┌─────────────────────────┐
│   Manual Approval       │
│  (production only)      │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Terraform Apply       │
│  - Execute plan         │
│  - Update infrastructure│
└────────┬────────────────┘
         │
         ├─── FAIL ───► Rollback
         │
         ▼
┌─────────────────────────┐
│  Application Deploy     │
│  - Build artifacts      │
│  - Deploy code          │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Post-Deploy Validation │
│  - Health checks        │
│  - Smoke tests          │
│  - Monitor setup        │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│   Notifications         │
│  - Slack / Email        │
│  - GitHub PR comment    │
└─────────────────────────┘
```

---

## Support & Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Review workflow execution logs
- Check security scan findings
- Monitor deployment success rates

**Monthly:**
- Update Terraform version
- Review and rotate credentials
- Audit IAM permissions
- Review cost analysis reports

**Quarterly:**
- Update GitHub Actions versions
- Review and update security policies
- Conduct disaster recovery drills
- Update documentation

### Getting Help

1. **Check Workflow Logs**
   - GitHub Actions → Workflow runs
   - Expand failed steps
   - Check artifact uploads

2. **Review Security Findings**
   - GitHub Security tab
   - SARIF reports
   - Checkov/tfsec output

3. **Consult Documentation**
   - This guide
   - Terraform documentation
   - Cloud provider documentation
   - GitHub Actions documentation

4. **Contact Support**
   - Open GitHub issue
   - Contact DevOps team
   - Escalate to cloud support

---

## Changelog

### Version 1.0.0 (Initial Release)

**Features:**
- AWS deployment workflow
- GCP deployment workflow
- Multi-cloud orchestration
- OIDC authentication
- Security scanning integration
- Environment-based deployments
- Automated rollback
- Cost analysis
- Compliance checking
- Slack notifications

**Security:**
- tfsec integration
- Checkov scanning
- Trufflehog secret detection
- CodeQL analysis
- SARIF upload to GitHub Security

**Documentation:**
- Complete setup guide
- Troubleshooting section
- Best practices
- Usage examples

---

## Additional Resources

### Documentation
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides)

### Tools
- [tfsec](https://aquasecurity.github.io/tfsec/)
- [Checkov](https://www.checkov.io/)
- [Infracost](https://www.infracost.io/)
- [Trufflehog](https://github.com/trufflesecurity/trufflehog)

### Community
- [Terraform Discuss](https://discuss.hashicorp.com/c/terraform-core)
- [AWS Forums](https://forums.aws.amazon.com/)
- [GCP Community](https://www.googlecloudcommunity.com/)
- [GitHub Community](https://github.community/)

---

**Last Updated:** 2025-11-06
**Maintained By:** DevOps Team
**Version:** 1.0.0
