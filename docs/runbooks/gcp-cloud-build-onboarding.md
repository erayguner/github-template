# GCP Cloud Build Onboarding Runbook

## Table of Contents
1. [Overview & Prerequisites](#overview--prerequisites)
2. [Method 1: Cloud Build GitHub App (Recommended)](#method-1-cloud-build-github-app-recommended)
3. [Method 2: Workload Identity Federation](#method-2-workload-identity-federation)
4. [Cloud Build Configuration](#cloud-build-configuration)
5. [IAM Roles & Permissions](#iam-roles--permissions)
6. [Verification & Testing](#verification--testing)
7. [Monitoring & Logging](#monitoring--logging)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Cost Optimization Tips](#cost-optimization-tips)
10. [Security Best Practices](#security-best-practices)

---

## Overview & Prerequisites

### What is Cloud Build?
Google Cloud Build is a fully managed CI/CD platform that executes builds on Google Cloud infrastructure. It can import source code from various repositories, execute build steps, and produce artifacts.

### Prerequisites

#### GCP Requirements
- ✅ Active GCP account with billing enabled
- ✅ GCP project created (or use existing)
- ✅ Cloud Build API enabled
- ✅ Cloud Resource Manager API enabled
- ✅ Appropriate IAM permissions (Owner or Editor role)

#### Local Environment
- ✅ [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated
- ✅ Git installed
- ✅ GitHub repository admin access
- ✅ Terraform (optional, for IaC deployment)

#### Repository Requirements
- ✅ GitHub repository: `erayguner/github-template`
- ✅ Terraform configuration in `/terraform` directory
- ✅ Existing workflows in `.github/workflows/`

### Quick Start Checklist

```bash
# 1. Authenticate with GCP
gcloud auth login
gcloud auth application-default login

# 2. Set your GCP project
export PROJECT_ID="your-gcp-project-id"
gcloud config set project ${PROJECT_ID}

# 3. Enable required APIs
gcloud services enable cloudbuild.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  secretmanager.googleapis.com \
  compute.googleapis.com

# 4. Verify setup
gcloud config list
gcloud projects describe ${PROJECT_ID}
```

---

## Method 1: Cloud Build GitHub App (Recommended)

This method uses Google's Cloud Build GitHub App for seamless integration with automatic webhook management.

### Advantages
- ✅ Automatic webhook configuration
- ✅ Easy repository access management
- ✅ Native GitHub integration
- ✅ Simple trigger management
- ✅ No manual secret management

### Step-by-Step Setup

#### Step 1: Install Cloud Build GitHub App

1. **Navigate to Cloud Build in GCP Console**
   ```bash
   # Open in browser
   echo "https://console.cloud.google.com/cloud-build/triggers?project=${PROJECT_ID}"
   ```

2. **Connect Repository**
   - Go to: Cloud Build > Triggers
   - Click "Connect Repository"
   - Select "GitHub (Cloud Build GitHub App)"
   - Click "Continue"

3. **Authenticate with GitHub**
   - Sign in to your GitHub account
   - Select organization/account: `erayguner`
   - Choose repository access:
     - Option A: Select only `github-template`
     - Option B: All repositories (if managing multiple)
   - Click "Install" or "Install & Authorize"

4. **Confirm Repository Connection**
   - In GCP Console, select `erayguner/github-template`
   - Click "Connect"
   - Verify repository appears in connected repositories list

#### Step 2: Create Build Triggers

##### Trigger 1: Terraform Plan on Pull Request

```bash
# Create PR trigger for Terraform plan
gcloud builds triggers create github \
  --name="terraform-plan-pr" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^(?!main$).*" \
  --pull-request-pattern="^.*" \
  --build-config="cloudbuild-plan.yaml" \
  --comment-control=COMMENTS_ENABLED \
  --description="Run Terraform plan on pull requests"
```

**Create `cloudbuild-plan.yaml`:**
```yaml
# Save to: /Users/eray/github-template/cloudbuild-plan.yaml
steps:
  # Step 1: Initialize Terraform
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-init'
    dir: 'terraform'
    args:
      - 'init'
      - '-backend=false'
    env:
      - 'TF_IN_AUTOMATION=true'

  # Step 2: Validate Terraform
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-validate'
    dir: 'terraform'
    args:
      - 'validate'

  # Step 3: Format Check
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-fmt-check'
    dir: 'terraform'
    args:
      - 'fmt'
      - '-check'
      - '-recursive'

  # Step 4: Terraform Plan
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-plan'
    dir: 'terraform'
    args:
      - 'plan'
      - '-var=project_name=github-template'
      - '-var=environment=dev'
      - '-var=enable_gcp=true'
      - '-var=gcp_project_id=${PROJECT_ID}'
      - '-var=gcp_region=us-central1'
      - '-out=tfplan'

  # Step 5: Show Plan
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-show'
    dir: 'terraform'
    args:
      - 'show'
      - '-no-color'
      - 'tfplan'

options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'N1_HIGHCPU_8'
  substitutionOption: 'ALLOW_LOOSE'

timeout: '1200s'

substitutions:
  _ENVIRONMENT: 'dev'
```

##### Trigger 2: Terraform Apply on Main Branch

```bash
# Create main branch trigger for Terraform apply
gcloud builds triggers create github \
  --name="terraform-apply-main" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild-apply.yaml" \
  --description="Apply Terraform on main branch merge"
```

**Create `cloudbuild-apply.yaml`:**
```yaml
# Save to: /Users/eray/github-template/cloudbuild-apply.yaml
steps:
  # Step 1: Setup GCS backend for state
  - name: 'gcr.io/cloud-builders/gsutil'
    id: 'create-state-bucket'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        gsutil ls gs://${PROJECT_ID}-terraform-state || \
        gsutil mb -l ${_REGION} gs://${PROJECT_ID}-terraform-state
        gsutil versioning set on gs://${PROJECT_ID}-terraform-state

  # Step 2: Initialize Terraform with backend
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-init'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        cat > backend.tf <<EOF
        terraform {
          backend "gcs" {
            bucket = "${PROJECT_ID}-terraform-state"
            prefix = "terraform/state/${_ENVIRONMENT}"
          }
        }
        EOF
        terraform init -reconfigure

  # Step 3: Terraform Plan
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-plan'
    dir: 'terraform'
    args:
      - 'plan'
      - '-var=project_name=github-template'
      - '-var=environment=${_ENVIRONMENT}'
      - '-var=enable_gcp=true'
      - '-var=gcp_project_id=${PROJECT_ID}'
      - '-var=gcp_region=${_REGION}'
      - '-out=tfplan'

  # Step 4: Terraform Apply
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-apply'
    dir: 'terraform'
    args:
      - 'apply'
      - '-auto-approve'
      - 'tfplan'

  # Step 5: Export outputs
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-output'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        terraform output -json > /workspace/terraform-outputs.json
        cat /workspace/terraform-outputs.json

  # Step 6: Store outputs in Secret Manager
  - name: 'gcr.io/cloud-builders/gcloud'
    id: 'store-outputs'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        gcloud secrets versions add terraform-outputs-${_ENVIRONMENT} \
          --data-file=/workspace/terraform-outputs.json || \
        gcloud secrets create terraform-outputs-${_ENVIRONMENT} \
          --data-file=/workspace/terraform-outputs.json \
          --replication-policy="automatic"

options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'N1_HIGHCPU_8'

timeout: '2400s'

substitutions:
  _ENVIRONMENT: 'dev'
  _REGION: 'us-central1'
```

##### Trigger 3: Multi-Environment Deployment

```bash
# Create staging trigger
gcloud builds triggers create github \
  --name="terraform-apply-staging" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^staging$" \
  --build-config="cloudbuild-apply.yaml" \
  --substitutions="_ENVIRONMENT=staging,_REGION=us-central1" \
  --description="Deploy to staging environment"

# Create production trigger (requires manual approval)
gcloud builds triggers create github \
  --name="terraform-apply-prod" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^production$" \
  --build-config="cloudbuild-apply.yaml" \
  --substitutions="_ENVIRONMENT=prod,_REGION=us-central1" \
  --require-approval \
  --description="Deploy to production (requires approval)"
```

#### Step 3: Configure Build Service Account

```bash
# Get Cloud Build service account
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')
export CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Grant necessary permissions
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/secretmanager.admin"
```

#### Step 4: Test the Integration

```bash
# Trigger a manual build
gcloud builds triggers run terraform-plan-pr \
  --branch=test-branch

# Monitor build
gcloud builds list --limit=5

# View logs
gcloud builds log $(gcloud builds list --limit=1 --format='value(id)')
```

---

## Method 2: Workload Identity Federation

This method enables GitHub Actions to authenticate to GCP without storing service account keys.

### Advantages
- ✅ No long-lived credentials
- ✅ Automatic credential rotation
- ✅ Fine-grained access control
- ✅ Better security posture
- ✅ Integration with existing GitHub Actions

### Step-by-Step Setup

#### Step 1: Create Workload Identity Pool

```bash
# Set variables
export PROJECT_ID="your-gcp-project-id"
export POOL_NAME="github-actions-pool"
export PROVIDER_NAME="github-provider"
export SERVICE_ACCOUNT_NAME="github-actions-sa"
export REPO="erayguner/github-template"

# Create Workload Identity Pool
gcloud iam workload-identity-pools create ${POOL_NAME} \
  --location="global" \
  --description="Workload Identity Pool for GitHub Actions" \
  --display-name="GitHub Actions Pool"

# Get pool ID
export WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe ${POOL_NAME} \
  --location="global" \
  --format="value(name)")

echo "Pool ID: ${WORKLOAD_IDENTITY_POOL_ID}"
```

#### Step 2: Create Workload Identity Provider

```bash
# Create OIDC provider for GitHub
gcloud iam workload-identity-pools providers create-oidc ${PROVIDER_NAME} \
  --location="global" \
  --workload-identity-pool=${POOL_NAME} \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner=='erayguner'"

# Get provider ID
export PROVIDER_ID=$(gcloud iam workload-identity-pools providers describe ${PROVIDER_NAME} \
  --location="global" \
  --workload-identity-pool=${POOL_NAME} \
  --format="value(name)")

echo "Provider ID: ${PROVIDER_ID}"
```

#### Step 3: Create Service Account

```bash
# Create service account for GitHub Actions
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
  --display-name="GitHub Actions Service Account" \
  --description="Service account for GitHub Actions deployments"

export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Grant necessary roles
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/secretmanager.secretAccessor"
```

#### Step 4: Configure Workload Identity Binding

```bash
# Allow GitHub Actions to impersonate service account
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_EMAIL} \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"

# Verify binding
gcloud iam service-accounts get-iam-policy ${SERVICE_ACCOUNT_EMAIL}
```

#### Step 5: Get Workload Identity Provider Resource Name

```bash
# Get the full provider resource name for GitHub secrets
export WIF_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME}"

echo "Add this to GitHub Secrets as WIF_PROVIDER:"
echo ${WIF_PROVIDER}
echo ""
echo "Add this to GitHub Secrets as WIF_SERVICE_ACCOUNT:"
echo ${SERVICE_ACCOUNT_EMAIL}
```

#### Step 6: Configure GitHub Secrets

Navigate to: `https://github.com/erayguner/github-template/settings/secrets/actions`

Add the following secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `GCP_PROJECT_ID` | `${PROJECT_ID}` | Your GCP Project ID |
| `GCP_SA_EMAIL` | `${SERVICE_ACCOUNT_EMAIL}` | Service Account email |
| `WIF_PROVIDER` | `${WIF_PROVIDER}` | Workload Identity Provider |
| `WIF_SERVICE_ACCOUNT` | `${SERVICE_ACCOUNT_EMAIL}` | Service Account for WIF |

#### Step 7: Update GitHub Actions Workflow

Update `.github/workflows/gcp-deploy.yml`:

```yaml
name: GCP Terraform Deploy with WIF

on:
  push:
    branches:
      - main
      - staging
  pull_request:
    branches:
      - main

permissions:
  id-token: write  # Required for OIDC
  contents: read
  pull-requests: write

jobs:
  terraform:
    name: Terraform Plan/Apply
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Authenticate to Google Cloud
        id: auth
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
          token_format: 'access_token'
          create_credentials_file: true

      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0

      - name: Terraform Init
        working-directory: ./terraform
        run: |
          cat > backend.tf <<EOF
          terraform {
            backend "gcs" {
              bucket = "${{ secrets.GCP_PROJECT_ID }}-terraform-state"
              prefix = "terraform/state/${{ github.ref_name }}"
            }
          }
          EOF
          terraform init

      - name: Terraform Plan
        id: plan
        working-directory: ./terraform
        run: |
          terraform plan \
            -var="project_name=github-template" \
            -var="environment=${{ github.ref_name == 'main' && 'prod' || 'dev' }}" \
            -var="enable_gcp=true" \
            -var="gcp_project_id=${{ secrets.GCP_PROJECT_ID }}" \
            -var="gcp_region=us-central1" \
            -out=tfplan \
            -no-color
        continue-on-error: true

      - name: Post Plan to PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const output = `#### Terraform Plan 📖

            <details><summary>Show Plan</summary>

            \`\`\`
            ${{ steps.plan.outputs.stdout }}
            \`\`\`

            </details>

            *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        working-directory: ./terraform
        run: terraform apply -auto-approve tfplan
```

---

## Cloud Build Configuration

### Environment-Specific Builds

Create `cloudbuild-multi-env.yaml`:

```yaml
# Multi-environment Cloud Build configuration
steps:
  # Determine environment
  - name: 'bash'
    id: 'set-environment'
    script: |
      #!/bin/bash
      case "${BRANCH_NAME}" in
        main|master)
          echo "prod" > /workspace/environment.txt
          ;;
        staging)
          echo "staging" > /workspace/environment.txt
          ;;
        *)
          echo "dev" > /workspace/environment.txt
          ;;
      esac
      export ENV=$(cat /workspace/environment.txt)
      echo "Environment: ${ENV}"

  # Initialize Terraform
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-init'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        export ENV=$(cat /workspace/environment.txt)
        cat > backend.tf <<EOF
        terraform {
          backend "gcs" {
            bucket = "${PROJECT_ID}-terraform-state"
            prefix = "terraform/state/\${ENV}"
          }
        }
        EOF
        terraform init -reconfigure

  # Terraform Plan
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-plan'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        export ENV=$(cat /workspace/environment.txt)
        terraform plan \
          -var="project_name=github-template" \
          -var="environment=${ENV}" \
          -var="enable_gcp=true" \
          -var="gcp_project_id=${PROJECT_ID}" \
          -var="gcp_region=${_REGION}" \
          -out=tfplan

  # Conditional Apply (only for main, staging)
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-apply'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        if [[ "${BRANCH_NAME}" =~ ^(main|master|staging)$ ]]; then
          terraform apply -auto-approve tfplan
        else
          echo "Skipping apply for branch: ${BRANCH_NAME}"
        fi

  # Run tests
  - name: 'python:3.11'
    id: 'run-tests'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        pip install pytest
        pytest python/tests/ || true

  # Security scan
  - name: 'gcr.io/cloud-builders/gcloud'
    id: 'security-scan'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        # Run security checks
        gcloud secrets list --project=${PROJECT_ID}

substitutions:
  _REGION: 'us-central1'

options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'N1_HIGHCPU_8'
  dynamic_substitutions: true

timeout: '3600s'
```

### Build with Caching

```yaml
# cloudbuild-cached.yaml - Optimized build with caching
steps:
  # Restore cache
  - name: 'gcr.io/cloud-builders/gsutil'
    id: 'restore-cache'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        gsutil -m rsync -r -d \
          gs://${PROJECT_ID}-build-cache/terraform/.terraform \
          /workspace/terraform/.terraform || echo "No cache found"

  # Terraform operations
  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-init'
    dir: 'terraform'
    args: ['init', '-upgrade']

  - name: 'hashicorp/terraform:1.6'
    id: 'terraform-plan'
    dir: 'terraform'
    args:
      - 'plan'
      - '-var=project_name=github-template'
      - '-var=enable_gcp=true'
      - '-var=gcp_project_id=${PROJECT_ID}'

  # Save cache
  - name: 'gcr.io/cloud-builders/gsutil'
    id: 'save-cache'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        gsutil -m rsync -r -d \
          /workspace/terraform/.terraform \
          gs://${PROJECT_ID}-build-cache/terraform/.terraform

options:
  machineType: 'N1_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY

timeout: '1800s'
```

---

## IAM Roles & Permissions

### Required Service Accounts

#### Cloud Build Service Account

```bash
# Default Cloud Build service account
export CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Create custom service account (optional)
gcloud iam service-accounts create cloudbuild-terraform \
  --display-name="Cloud Build Terraform" \
  --description="Service account for Terraform deployments via Cloud Build"

export TERRAFORM_SA="cloudbuild-terraform@${PROJECT_ID}.iam.gserviceaccount.com"
```

### Permission Matrix

| Role | Purpose | Service Account | Why Needed |
|------|---------|----------------|------------|
| `roles/editor` | Manage GCP resources | Cloud Build SA | Create/modify infrastructure |
| `roles/compute.networkAdmin` | Network management | Cloud Build SA | VPC, subnets, firewall rules |
| `roles/iam.serviceAccountUser` | Impersonate service accounts | Cloud Build SA | Deploy with service accounts |
| `roles/secretmanager.admin` | Manage secrets | Cloud Build SA | Store sensitive outputs |
| `roles/storage.objectAdmin` | GCS bucket management | Cloud Build SA | Terraform state storage |
| `roles/cloudbuild.builds.editor` | Manage builds | GitHub Actions SA | Trigger builds from GitHub |
| `roles/iam.workloadIdentityUser` | WIF authentication | GitHub Actions SA | Keyless authentication |

### Grant Permissions Script

```bash
#!/bin/bash
# File: scripts/setup-iam.sh

set -e

PROJECT_ID="${1:-your-project-id}"
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

echo "Setting up IAM permissions for Cloud Build..."

# Cloud Build permissions
ROLES=(
  "roles/editor"
  "roles/compute.networkAdmin"
  "roles/iam.serviceAccountUser"
  "roles/secretmanager.admin"
  "roles/storage.objectAdmin"
  "roles/logging.logWriter"
)

for ROLE in "${ROLES[@]}"; do
  echo "Granting ${ROLE} to ${CLOUD_BUILD_SA}"
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="${ROLE}" \
    --condition=None \
    --no-user-output-enabled
done

echo "IAM setup complete!"
```

### Least Privilege Custom Role

```bash
# Create custom role with minimal permissions
gcloud iam roles create TerraformDeployer \
  --project=${PROJECT_ID} \
  --title="Terraform Deployer" \
  --description="Minimal permissions for Terraform deployments" \
  --permissions=compute.networks.create,\
compute.networks.delete,\
compute.networks.get,\
compute.networks.update,\
compute.subnetworks.create,\
compute.subnetworks.delete,\
compute.subnetworks.get,\
compute.subnetworks.update,\
compute.firewalls.create,\
compute.firewalls.delete,\
compute.firewalls.get,\
compute.firewalls.update,\
resourcemanager.projects.get,\
storage.buckets.create,\
storage.buckets.get,\
storage.objects.create,\
storage.objects.delete,\
storage.objects.get

# Assign custom role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="projects/${PROJECT_ID}/roles/TerraformDeployer"
```

---

## Verification & Testing

### Test Checklist

#### 1. Verify Cloud Build Setup

```bash
# List triggers
gcloud builds triggers list --format="table(name,github.name,github.owner,status)"

# Test trigger
gcloud builds triggers run terraform-plan-pr \
  --branch=test-verification

# Check recent builds
gcloud builds list --limit=10 --format="table(id,status,source.repoSource.branchName,createTime)"
```

#### 2. Verify Workload Identity Federation

```bash
# Test WIF authentication
gcloud iam workload-identity-pools providers describe ${PROVIDER_NAME} \
  --location="global" \
  --workload-identity-pool=${POOL_NAME}

# Verify service account bindings
gcloud iam service-accounts get-iam-policy ${SERVICE_ACCOUNT_EMAIL} \
  --format=json | jq '.bindings[] | select(.role=="roles/iam.workloadIdentityUser")'
```

#### 3. Test Terraform State Backend

```bash
# Verify state bucket exists
gsutil ls gs://${PROJECT_ID}-terraform-state/

# Check state file
gsutil ls gs://${PROJECT_ID}-terraform-state/terraform/state/

# Test state locking
cd terraform
terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"
terraform workspace list
```

#### 4. End-to-End Test

```bash
# Create test branch
git checkout -b test-cloud-build-e2e

# Make a change to Terraform
echo "# Test Cloud Build" >> terraform/README.md

# Commit and push
git add terraform/README.md
git commit -m "test: Cloud Build integration"
git push origin test-cloud-build-e2e

# Create PR via GitHub CLI
gh pr create --title "Test: Cloud Build E2E" --body "Testing Cloud Build integration"

# Monitor build
gcloud builds list --ongoing --format="table(id,status,logUrl)"

# Check logs
BUILD_ID=$(gcloud builds list --limit=1 --format='value(id)')
gcloud builds log ${BUILD_ID} --stream
```

#### 5. Validation Script

```bash
#!/bin/bash
# File: scripts/validate-setup.sh

set -e

PROJECT_ID="${1}"
REPO_OWNER="erayguner"
REPO_NAME="github-template"

echo "🔍 Validating Cloud Build Setup for ${PROJECT_ID}..."

# Check APIs
echo "✓ Checking APIs..."
gcloud services list --enabled --filter="name:cloudbuild.googleapis.com" --format="value(name)"

# Check triggers
echo "✓ Checking triggers..."
TRIGGER_COUNT=$(gcloud builds triggers list --format="value(name)" | wc -l)
echo "  Found ${TRIGGER_COUNT} triggers"

# Check service account
echo "✓ Checking service account permissions..."
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')
SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${SA}" \
  --format="table(bindings.role)"

# Check state bucket
echo "✓ Checking Terraform state bucket..."
gsutil ls gs://${PROJECT_ID}-terraform-state/ || echo "  ⚠️  State bucket not found"

# Check GitHub connection
echo "✓ Checking GitHub connection..."
gcloud builds connections list --region=us-central1 || echo "  No connections found"

echo "✅ Validation complete!"
```

---

## Monitoring & Logging

### Cloud Build Logs

```bash
# View recent builds
gcloud builds list --limit=20 --format="table(id,status,source.repoSource.branchName,startTime,duration)"

# Stream logs for a build
gcloud builds log $(gcloud builds list --limit=1 --format='value(id)') --stream

# Export logs to BigQuery
gcloud logging sinks create cloudbuild-sink \
  bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/cloudbuild_logs \
  --log-filter='resource.type="build"'
```

### Build Metrics

```bash
# Create dashboard monitoring build success rate
gcloud monitoring dashboards create --config-from-file=- <<EOF
{
  "displayName": "Cloud Build Metrics",
  "dashboardFilters": [{
    "filterType": "RESOURCE_LABEL",
    "labelKey": "project_id",
    "stringValue": "${PROJECT_ID}"
  }],
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Build Success Rate",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"build\" AND metric.type=\"cloudbuild.googleapis.com/build/count\"",
                  "aggregation": {
                    "alignmentPeriod": "3600s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              }
            }]
          }
        }
      }
    ]
  }
}
EOF
```

### Alerting

```bash
# Create alert for failed builds
gcloud alpha monitoring policies create --notification-channels=CHANNEL_ID \
  --display-name="Cloud Build Failures" \
  --condition-display-name="Build failed" \
  --condition-threshold-value=1 \
  --condition-threshold-duration=60s \
  --condition-filter='resource.type="build" AND metric.type="cloudbuild.googleapis.com/build/count" AND metric.label.status="FAILURE"'
```

### Log Analysis Queries

```bash
# Find all failed builds in last 24 hours
gcloud logging read "resource.type=build AND severity=ERROR" \
  --limit=50 \
  --format=json \
  --freshness=24h

# Find builds for specific branch
gcloud logging read "resource.type=build AND jsonPayload.substitutions.BRANCH_NAME=main" \
  --limit=10 \
  --format="table(timestamp,jsonPayload.status,jsonPayload.id)"

# Find slow builds (>10min)
gcloud logging read "resource.type=build" \
  --format=json | jq '.[] | select(.jsonPayload.timing.endTime and
    (((.jsonPayload.timing.endTime | fromdateiso8601) -
      (.jsonPayload.timing.startTime | fromdateiso8601)) > 600))'
```

---

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: "Permission Denied" Errors

**Symptoms:**
```
Error: Error creating Network: googleapi: Error 403: Permission denied
```

**Solution:**
```bash
# Check service account permissions
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# List current permissions
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${CLOUD_BUILD_SA}"

# Add missing permission
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/compute.networkAdmin"
```

#### Issue 2: Terraform State Lock

**Symptoms:**
```
Error: Error acquiring the state lock
```

**Solution:**
```bash
# List current locks
gsutil ls gs://${PROJECT_ID}-terraform-state/terraform/state/*/default.tflock

# Force unlock (use with caution)
cd terraform
terraform force-unlock <LOCK_ID>

# Or remove lock file directly
gsutil rm gs://${PROJECT_ID}-terraform-state/terraform/state/dev/default.tflock
```

#### Issue 3: GitHub Connection Failed

**Symptoms:**
```
Error: Repository not found or access denied
```

**Solution:**
```bash
# Re-install GitHub App
# 1. Go to: https://github.com/apps/google-cloud-build
# 2. Click "Configure"
# 3. Re-authorize repository access

# Or recreate trigger with correct repo
gcloud builds triggers delete terraform-plan-pr
gcloud builds triggers create github \
  --name="terraform-plan-pr" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern=".*" \
  --build-config="cloudbuild-plan.yaml"
```

#### Issue 4: Workload Identity Federation Not Working

**Symptoms:**
```
Error: Unable to impersonate service account
```

**Solution:**
```bash
# Verify WIF setup
gcloud iam workload-identity-pools providers describe ${PROVIDER_NAME} \
  --location="global" \
  --workload-identity-pool=${POOL_NAME}

# Check attribute mapping
gcloud iam workload-identity-pools providers describe ${PROVIDER_NAME} \
  --location="global" \
  --workload-identity-pool=${POOL_NAME} \
  --format="value(attributeMapping)"

# Verify service account binding
gcloud iam service-accounts get-iam-policy ${SERVICE_ACCOUNT_EMAIL}

# Re-add binding if missing
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_EMAIL} \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
```

#### Issue 5: Build Timeout

**Symptoms:**
```
ERROR: build step 2 "hashicorp/terraform:1.6" exceeded timeout
```

**Solution:**
```yaml
# Increase timeout in cloudbuild.yaml
timeout: '3600s'  # Increase from default 600s

# Or per-step timeout
steps:
  - name: 'hashicorp/terraform:1.6'
    timeout: '1800s'
    args: ['apply', '-auto-approve']
```

#### Issue 6: Missing Terraform Providers

**Symptoms:**
```
Error: Could not download provider
```

**Solution:**
```bash
# Add provider cache
steps:
  - name: 'gcr.io/cloud-builders/gsutil'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        mkdir -p /workspace/.terraform.d/plugin-cache
        gsutil -m rsync -r \
          gs://${PROJECT_ID}-terraform-cache/.terraform.d/plugin-cache \
          /workspace/.terraform.d/plugin-cache || echo "No cache"
    env:
      - 'TF_PLUGIN_CACHE_DIR=/workspace/.terraform.d/plugin-cache'
```

### Debug Mode

```bash
# Run build with verbose logging
gcloud builds submit \
  --config=cloudbuild-plan.yaml \
  --substitutions=_DEBUG=true \
  --verbosity=debug

# Add debug steps to cloudbuild.yaml
steps:
  - name: 'bash'
    id: 'debug-info'
    script: |
      #!/bin/bash
      echo "=== Environment Variables ==="
      env | sort
      echo "=== GCloud Config ==="
      gcloud config list
      echo "=== Current Directory ==="
      pwd
      ls -la
      echo "=== Terraform Version ==="
      terraform version || echo "Terraform not found"
```

### Validation Checklist

- [ ] Cloud Build API enabled
- [ ] GitHub App installed and authorized
- [ ] Triggers created and active
- [ ] Service account has required permissions
- [ ] State bucket exists and is accessible
- [ ] Terraform files are valid
- [ ] Workload Identity Federation configured (if using)
- [ ] GitHub secrets configured (if using WIF)
- [ ] Test build successful
- [ ] Logs accessible and readable

---

## Cost Optimization Tips

### 1. Build Machine Type Optimization

```yaml
# Use smaller machines for simple builds
options:
  machineType: 'E2_MEDIUM'  # Instead of N1_HIGHCPU_8

# Use larger machines only when needed
options:
  machineType: 'N1_HIGHCPU_32'  # For complex terraform plans
```

**Machine Type Pricing (approximate):**
- E2_MEDIUM: ~$0.004/minute
- N1_HIGHCPU_8: ~$0.013/minute
- N1_HIGHCPU_32: ~$0.052/minute

### 2. Build Caching

```bash
# Create cache bucket
gsutil mb -l ${REGION} gs://${PROJECT_ID}-build-cache

# Enable cache in builds
steps:
  - name: 'gcr.io/cloud-builders/gsutil'
    args: ['rsync', '-r', 'gs://${PROJECT_ID}-build-cache/', '/workspace/cache/']

  # ... build steps ...

  - name: 'gcr.io/cloud-builders/gsutil'
    args: ['rsync', '-r', '/workspace/cache/', 'gs://${PROJECT_ID}-build-cache/']
```

**Potential Savings:** 30-50% on build time for cached builds

### 3. Conditional Builds

```yaml
# Only run expensive tests on main branch
steps:
  - name: 'bash'
    id: 'conditional-tests'
    script: |
      if [[ "${BRANCH_NAME}" == "main" ]]; then
        echo "Running full test suite..."
        npm run test:integration
      else
        echo "Running unit tests only..."
        npm run test:unit
      fi
```

### 4. Terraform State Management

```bash
# Use state locking to prevent concurrent runs
terraform {
  backend "gcs" {
    bucket = "${PROJECT_ID}-terraform-state"
    prefix = "terraform/state"
  }
}

# Clean up old state versions
gsutil lifecycle set - gs://${PROJECT_ID}-terraform-state <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 10
        }
      }
    ]
  }
}
EOF
```

### 5. Build Timeout Optimization

```yaml
# Set reasonable timeouts
timeout: '600s'  # 10 minutes for simple builds

# Per-step timeouts
steps:
  - name: 'hashicorp/terraform:1.6'
    timeout: '300s'  # 5 minutes for init
    args: ['init']
```

### 6. Log Retention

```bash
# Set log retention to reduce storage costs
gcloud logging sinks create cloudbuild-logs-retention \
  logging.googleapis.com/projects/${PROJECT_ID}/locations/global/buckets/cloudbuild-logs \
  --log-filter='resource.type="build"' \
  --retention-days=30
```

### Cost Monitoring

```bash
# Enable budget alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Cloud Build Budget" \
  --budget-amount=100USD \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100
```

---

## Security Best Practices

### 1. Service Account Security

```bash
# Use separate service accounts per environment
gcloud iam service-accounts create cloudbuild-dev
gcloud iam service-accounts create cloudbuild-staging
gcloud iam service-accounts create cloudbuild-prod

# Grant minimal permissions
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:cloudbuild-dev@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="projects/${PROJECT_ID}/roles/TerraformDeployer"
```

### 2. Secret Management

```bash
# Store secrets in Secret Manager
echo -n "sensitive-value" | gcloud secrets create terraform-api-key \
  --data-file=-

# Access in Cloud Build
steps:
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        API_KEY=$(gcloud secrets versions access latest --secret=terraform-api-key)
        export TF_VAR_api_key=${API_KEY}
        terraform apply
```

### 3. VPC Service Controls

```bash
# Create service perimeter
gcloud access-context-manager perimeters create cloudbuild-perimeter \
  --title="Cloud Build Perimeter" \
  --resources=projects/${PROJECT_NUMBER} \
  --restricted-services=cloudbuild.googleapis.com \
  --policy=POLICY_ID
```

### 4. Build Approvals

```yaml
# Require manual approval for production
options:
  requestedVerifyOption: 'VERIFIED'

# Or use gcloud
gcloud builds triggers create github \
  --name="prod-deploy" \
  --require-approval \
  --approval-required
```

### 5. Audit Logging

```bash
# Enable Cloud Build audit logs
gcloud logging sinks create cloudbuild-audit \
  bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/audit_logs \
  --log-filter='protoPayload.serviceName="cloudbuild.googleapis.com"'

# Query audit logs
bq query --use_legacy_sql=false '
SELECT
  timestamp,
  protoPayload.authenticationInfo.principalEmail,
  protoPayload.methodName,
  protoPayload.resourceName
FROM
  `'"${PROJECT_ID}"'.audit_logs.cloudaudit_googleapis_com_activity_*`
WHERE
  DATE(_PARTITIONTIME) = CURRENT_DATE()
  AND protoPayload.serviceName = "cloudbuild.googleapis.com"
ORDER BY timestamp DESC
LIMIT 100
'
```

### 6. Binary Authorization

```bash
# Require signed container images
gcloud container binauthz policy import policy.yaml

# policy.yaml
admissionWhitelistPatterns:
- namePattern: gcr.io/${PROJECT_ID}/*
globalPolicyEvaluationMode: ENABLE
defaultAdmissionRule:
  requireAttestationsBy:
  - projects/${PROJECT_ID}/attestors/build-verified
  evaluationMode: REQUIRE_ATTESTATION
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
```

### 7. Network Isolation

```yaml
# Use Private Pools for build isolation
steps:
  - name: 'hashicorp/terraform:1.6'
    args: ['plan']

options:
  pool:
    name: 'projects/${PROJECT_ID}/locations/${REGION}/workerPools/private-pool'
  machineType: 'N1_HIGHCPU_8'
```

### Security Checklist

- [ ] Service accounts use least privilege
- [ ] Secrets stored in Secret Manager
- [ ] Audit logging enabled
- [ ] Build approvals for production
- [ ] VPC Service Controls configured
- [ ] Binary authorization enabled
- [ ] Private worker pools for sensitive builds
- [ ] Regular security scanning
- [ ] Access reviews quarterly
- [ ] Encryption at rest enabled

---

## Quick Reference

### Essential Commands

```bash
# Authentication
gcloud auth login
gcloud auth application-default login

# Project setup
gcloud config set project PROJECT_ID
gcloud services enable cloudbuild.googleapis.com

# Trigger management
gcloud builds triggers list
gcloud builds triggers run TRIGGER_NAME --branch=BRANCH

# Build management
gcloud builds list --ongoing
gcloud builds log BUILD_ID --stream
gcloud builds cancel BUILD_ID

# Service account
gcloud iam service-accounts list
gcloud projects get-iam-policy PROJECT_ID

# Debugging
gcloud builds submit --config=cloudbuild.yaml --no-source
gcloud logging read "resource.type=build" --limit=10
```

### Useful Links

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Cloud Build Pricing](https://cloud.google.com/build/pricing)
- [GitHub Actions with GCP](https://github.com/google-github-actions)

### Support Contacts

- GCP Support: https://cloud.google.com/support
- Community: https://stackoverflow.com/questions/tagged/google-cloud-build
- GitHub Issues: https://github.com/erayguner/github-template/issues

---

## Appendix

### A. Complete Setup Script

```bash
#!/bin/bash
# File: scripts/complete-setup.sh
# Complete Cloud Build setup automation

set -e

PROJECT_ID="${1}"
REGION="${2:-us-central1}"
REPO_OWNER="${3:-erayguner}"
REPO_NAME="${4:-github-template}"

if [ -z "$PROJECT_ID" ]; then
  echo "Usage: $0 PROJECT_ID [REGION] [REPO_OWNER] [REPO_NAME]"
  exit 1
fi

echo "🚀 Setting up Cloud Build for ${REPO_OWNER}/${REPO_NAME}..."

# 1. Enable APIs
echo "📡 Enabling APIs..."
gcloud services enable \
  cloudbuild.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  secretmanager.googleapis.com \
  compute.googleapis.com \
  --project=${PROJECT_ID}

# 2. Create state bucket
echo "🪣 Creating Terraform state bucket..."
gsutil mb -l ${REGION} gs://${PROJECT_ID}-terraform-state || echo "Bucket exists"
gsutil versioning set on gs://${PROJECT_ID}-terraform-state

# 3. Setup service account
echo "👤 Setting up service account..."
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

ROLES=(
  "roles/editor"
  "roles/compute.networkAdmin"
  "roles/iam.serviceAccountUser"
  "roles/secretmanager.admin"
)

for ROLE in "${ROLES[@]}"; do
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="${ROLE}" \
    --quiet
done

# 4. Create triggers
echo "⚡ Creating build triggers..."
gcloud builds triggers create github \
  --name="terraform-plan-pr" \
  --repo-name="${REPO_NAME}" \
  --repo-owner="${REPO_OWNER}" \
  --pull-request-pattern="^.*" \
  --build-config="cloudbuild-plan.yaml" \
  --project=${PROJECT_ID} || echo "Trigger exists"

gcloud builds triggers create github \
  --name="terraform-apply-main" \
  --repo-name="${REPO_NAME}" \
  --repo-owner="${REPO_OWNER}" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild-apply.yaml" \
  --project=${PROJECT_ID} || echo "Trigger exists"

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review triggers: gcloud builds triggers list"
echo "2. Test build: gcloud builds triggers run terraform-plan-pr --branch=test"
echo "3. Monitor: gcloud builds list --ongoing"
```

### B. Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_ID` | GCP Project ID | `my-project-123` |
| `PROJECT_NUMBER` | GCP Project Number | `123456789` |
| `BRANCH_NAME` | Git branch name | `main`, `staging` |
| `COMMIT_SHA` | Git commit SHA | `abc123...` |
| `REPO_NAME` | Repository name | `github-template` |
| `REPO_OWNER` | Repository owner | `erayguner` |
| `BUILD_ID` | Cloud Build ID | `12345678-1234-...` |
| `_REGION` | GCP region | `us-central1` |
| `_ENVIRONMENT` | Environment name | `dev`, `staging`, `prod` |

---

**Document Version:** 1.0.0
**Last Updated:** 2025-11-06
**Maintained By:** DevOps Team
**Review Cycle:** Quarterly
