# Google Cloud Build Integration Guide

This guide explains how to integrate your GitHub repository with Google Cloud Build for running CI/CD pipelines directly in GCP instead of GitHub Actions.

## Table of Contents
- [Overview](#overview)
- [Why Use Cloud Build?](#why-use-cloud-build)
- [Prerequisites](#prerequisites)
- [Setup Steps](#setup-steps)
- [Build Configuration](#build-configuration)
- [Running Builds](#running-builds)
- [Advanced Configuration](#advanced-configuration)
- [Cost Comparison](#cost-comparison)

## Overview

Google Cloud Build is a serverless CI/CD platform that executes builds on Google Cloud infrastructure. It can be triggered by GitHub events (push, pull request) and provides:

- Native GCP integration
- Faster builds with GCP network speeds
- Direct access to GCP resources without authentication
- Build caching and optimization
- Integration with Container Registry/Artifact Registry

## Why Use Cloud Build?

**Use Cloud Build when:**
- ✅ Your infrastructure is primarily on GCP
- ✅ You need faster builds with GCP resources
- ✅ You want to avoid managing GitHub Actions secrets for GCP
- ✅ You need to build and push to GCR/Artifact Registry frequently
- ✅ You want to integrate with other GCP services (Cloud Run, GKE, etc.)

**Use GitHub Actions when:**
- ✅ Multi-cloud deployment (AWS, Azure, GCP)
- ✅ You want to stay within GitHub ecosystem
- ✅ You need extensive third-party GitHub Actions
- ✅ Lower cost for simple workflows (free for public repos)

## Prerequisites

Before starting, ensure you have:

1. **GCP Project**: Active project with billing enabled
2. **gcloud CLI**: Installed and authenticated
3. **GitHub Repository**: Admin access
4. **Cloud Build API**: Enabled in your GCP project

```bash
# Set your project
export GCP_PROJECT_ID="your-project-id"
gcloud config set project $GCP_PROJECT_ID

# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com
```

## Setup Steps

### Step 1: Connect GitHub Repository to Cloud Build

#### Option A: Using Google Cloud Console (Recommended for First Time)

1. Navigate to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
2. Click **"Connect Repository"**
3. Select **"GitHub (Cloud Build GitHub App)"**
4. Click **"Authenticate with GitHub"**
5. Authorize Google Cloud Build
6. Select your repository
7. Click **"Connect Repository"**

#### Option B: Using gcloud CLI

```bash
# Install Cloud Build GitHub App first via console, then:

# List available repositories
gcloud beta builds repositories list --connection=GITHUB_CONNECTION

# Create a build trigger (we'll do this in next step)
```

### Step 2: Grant Cloud Build Service Account Permissions

```bash
# Get Cloud Build service account
export PROJECT_NUMBER=$(gcloud projects describe $GCP_PROJECT_ID --format="value(projectNumber)")
export CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Grant necessary IAM roles
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/storage.admin"

# For Terraform state management
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/editor"
```

### Step 3: Create Cloud Build Configuration File

Create `cloudbuild.yaml` in your repository root:

```yaml
# cloudbuild.yaml - Terraform CI/CD Pipeline
steps:
  # Step 1: Install dependencies
  - name: 'gcr.io/cloud-builders/gcloud'
    id: 'setup'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        echo "Setting up build environment..."
        echo "Project: $PROJECT_ID"
        echo "Branch: $BRANCH_NAME"
        echo "Commit: $COMMIT_SHA"

  # Step 2: Terraform Format Check
  - name: 'hashicorp/terraform:1.10'
    id: 'terraform-fmt'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        echo "Checking Terraform formatting..."
        terraform fmt -check -diff -recursive .

  # Step 3: Terraform Init
  - name: 'hashicorp/terraform:1.10'
    id: 'terraform-init'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        echo "Initializing Terraform..."
        terraform init -backend-config="bucket=${_TF_STATE_BUCKET}"

  # Step 4: Terraform Validate
  - name: 'hashicorp/terraform:1.10'
    id: 'terraform-validate'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        echo "Validating Terraform configuration..."
        terraform validate

  # Step 5: Terraform Plan
  - name: 'hashicorp/terraform:1.10'
    id: 'terraform-plan'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        echo "Running Terraform plan..."
        terraform plan -out=tfplan \
          -var="gcp_project_id=$PROJECT_ID" \
          -var="project_name=${_PROJECT_NAME}" \
          -var="environment=${_ENVIRONMENT}"

  # Step 6: Security Scan - tfsec
  - name: 'aquasec/tfsec:latest'
    id: 'tfsec-scan'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - 'tfsec . --soft-fail'

  # Step 7: Security Scan - Checkov
  - name: 'bridgecrew/checkov:latest'
    id: 'checkov-scan'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - 'checkov -d . --soft-fail'

  # Step 8: Python Linting (if applicable)
  - name: 'python:3.13-slim'
    id: 'python-lint'
    dir: 'python'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        if [ -d "python" ]; then
          pip install ruff
          ruff check .
        else
          echo "No Python directory found, skipping..."
        fi

  # Step 9: Terraform Apply (only on main branch)
  - name: 'hashicorp/terraform:1.10'
    id: 'terraform-apply'
    dir: 'terraform'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        if [ "$BRANCH_NAME" = "main" ]; then
          echo "Applying Terraform changes..."
          terraform apply -auto-approve tfplan
        else
          echo "Skipping apply - not on main branch"
        fi

# Substitution variables
substitutions:
  _TF_STATE_BUCKET: '${PROJECT_ID}-terraform-state'
  _PROJECT_NAME: 'my-project'
  _ENVIRONMENT: 'dev'
  _GCP_REGION: 'us-central1'

# Build configuration
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'E2_HIGHCPU_8'  # Faster builds
  substitution_option: 'ALLOW_LOOSE'

# Timeout for entire build
timeout: '1800s'  # 30 minutes

# Store build logs
logsBucket: 'gs://${PROJECT_ID}-build-logs'

# Build artifacts (optional)
artifacts:
  objects:
    location: 'gs://${PROJECT_ID}-build-artifacts'
    paths:
      - 'terraform/tfplan'
      - 'terraform/*.tfstate'
```

### Step 4: Create Build Trigger

#### Using Cloud Console

1. Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers)
2. Click **"Create Trigger"**
3. Configure trigger:
   - **Name**: `terraform-ci-cd`
   - **Event**: Push to a branch
   - **Source**: Your connected repository
   - **Branch**: `^main$` (regex)
   - **Configuration**: Cloud Build configuration file (yaml)
   - **Location**: `cloudbuild.yaml`
4. Add substitution variables (optional):
   - `_ENVIRONMENT`: `dev`
   - `_PROJECT_NAME`: `my-project`
5. Click **"Create"**

#### Using gcloud CLI

```bash
# Create trigger for main branch
gcloud builds triggers create github \
  --name="terraform-ci-cd-main" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --substitutions="_ENVIRONMENT=prod,_PROJECT_NAME=my-project"

# Create trigger for pull requests
gcloud builds triggers create github \
  --name="terraform-ci-cd-pr" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --pull-request-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --substitutions="_ENVIRONMENT=dev,_PROJECT_NAME=my-project" \
  --comment-control=COMMENTS_ENABLED
```

### Step 5: Create Required GCS Buckets

```bash
# Create bucket for build logs
gcloud storage buckets create gs://${GCP_PROJECT_ID}-build-logs \
  --project=$GCP_PROJECT_ID \
  --location=us-central1 \
  --uniform-bucket-level-access

# Create bucket for build artifacts
gcloud storage buckets create gs://${GCP_PROJECT_ID}-build-artifacts \
  --project=$GCP_PROJECT_ID \
  --location=us-central1 \
  --uniform-bucket-level-access

# Create bucket for Terraform state (if not already created)
gcloud storage buckets create gs://${GCP_PROJECT_ID}-terraform-state \
  --project=$GCP_PROJECT_ID \
  --location=us-central1 \
  --uniform-bucket-level-access \
  --versioning
```

## Build Configuration

### Environment-Specific Builds

Create separate triggers for different environments:

```bash
# Development trigger (dev branch)
gcloud builds triggers create github \
  --name="terraform-dev" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^dev$" \
  --build-config="cloudbuild.yaml" \
  --substitutions="_ENVIRONMENT=dev,_PROJECT_NAME=my-project-dev"

# Staging trigger (staging branch)
gcloud builds triggers create github \
  --name="terraform-staging" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^staging$" \
  --build-config="cloudbuild.yaml" \
  --substitutions="_ENVIRONMENT=staging,_PROJECT_NAME=my-project-staging"

# Production trigger (main branch with manual approval)
gcloud builds triggers create github \
  --name="terraform-prod" \
  --repo-name="github-template" \
  --repo-owner="erayguner" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml" \
  --substitutions="_ENVIRONMENT=prod,_PROJECT_NAME=my-project-prod" \
  --require-approval
```

### Build Notifications

Set up Pub/Sub notifications for build status:

```bash
# Create Pub/Sub topic
gcloud pubsub topics create cloud-builds

# Create subscription for email notifications
gcloud pubsub subscriptions create cloud-builds-email \
  --topic=cloud-builds

# Configure Cloud Build to publish to topic
# (This is done automatically when you create triggers)
```

## Running Builds

### Trigger Build Manually

```bash
# Trigger a build manually
gcloud builds triggers run terraform-ci-cd-main \
  --branch=main

# Trigger with substitutions
gcloud builds triggers run terraform-ci-cd-main \
  --branch=main \
  --substitutions=_ENVIRONMENT=prod,_PROJECT_NAME=my-prod-project
```

### View Build Status

```bash
# List recent builds
gcloud builds list --limit=10

# View specific build
gcloud builds describe BUILD_ID

# Stream build logs
gcloud builds log BUILD_ID --stream
```

### Monitor in Cloud Console

1. Navigate to [Cloud Build History](https://console.cloud.google.com/cloud-build/builds)
2. View build status, logs, and artifacts
3. Click on a build to see detailed step-by-step execution

## Advanced Configuration

### Parallel Steps

Run independent steps in parallel for faster builds:

```yaml
# Run security scans in parallel
steps:
  # ... previous steps ...

  - name: 'aquasec/tfsec:latest'
    id: 'tfsec-scan'
    waitFor: ['terraform-validate']  # Only wait for validation
    dir: 'terraform'
    args: ['--soft-fail', '.']

  - name: 'bridgecrew/checkov:latest'
    id: 'checkov-scan'
    waitFor: ['terraform-validate']  # Run in parallel with tfsec
    dir: 'terraform'
    args: ['-d', '.', '--soft-fail']

  - name: 'hashicorp/terraform:1.10'
    id: 'terraform-plan'
    waitFor: ['tfsec-scan', 'checkov-scan']  # Wait for both scans
    # ... plan step ...
```

### Using Build Secrets

Store secrets in Secret Manager:

```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret \
  --data-file=-

# Grant Cloud Build access
gcloud secrets add-iam-policy-binding my-secret \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/secretmanager.secretAccessor"
```

Use in `cloudbuild.yaml`:

```yaml
steps:
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args:
      - '-c'
      - |
        SECRET_VALUE=$(gcloud secrets versions access latest --secret=my-secret)
        echo "Using secret: $SECRET_VALUE"
    env:
      - 'SECRET_PROJECT_ID=$PROJECT_ID'

# Or use availableSecrets (recommended)
availableSecrets:
  secretManager:
    - versionName: projects/$PROJECT_ID/secrets/my-secret/versions/latest
      env: 'MY_SECRET'

steps:
  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: 'bash'
    args: ['-c', 'echo "Secret: $$MY_SECRET"']
    secretEnv: ['MY_SECRET']
```

### Build Caching

Speed up builds with caching:

```yaml
steps:
  # Cache Terraform plugins
  - name: 'gcr.io/cloud-builders/gsutil'
    id: 'restore-cache'
    args:
      - '-m'
      - 'rsync'
      - '-r'
      - 'gs://${PROJECT_ID}-build-cache/terraform/.terraform/'
      - 'terraform/.terraform/'
    # Don't fail if cache doesn't exist
    waitFor: ['-']

  # ... terraform steps ...

  # Save cache
  - name: 'gcr.io/cloud-builders/gsutil'
    id: 'save-cache'
    args:
      - '-m'
      - 'rsync'
      - '-r'
      - 'terraform/.terraform/'
      - 'gs://${PROJECT_ID}-build-cache/terraform/.terraform/'
```

## Cost Comparison

### Cloud Build Pricing (as of 2024)

- **First 120 build-minutes/day**: Free
- **Additional build-minutes**: $0.003/build-minute
- **Example**: 500 build-minutes/month = ~$11.40/month

### GitHub Actions Pricing

- **Public repositories**: Free unlimited
- **Private repositories**: 2,000 minutes/month free, then $0.008/minute

### Cost Optimization Tips

1. **Use smaller machine types** for simple builds
2. **Implement caching** to reduce build time
3. **Run builds only on necessary branches**
4. **Use parallel steps** to reduce total time
5. **Set appropriate timeouts** to avoid stuck builds

## Troubleshooting

### Common Issues

#### 1. Permission Denied Errors

```bash
# Check service account permissions
gcloud projects get-iam-policy $GCP_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:${CLOUD_BUILD_SA}"

# Add missing permissions
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:${CLOUD_BUILD_SA}" \
  --role="roles/REQUIRED_ROLE"
```

#### 2. Build Timeout

```yaml
# Increase timeout in cloudbuild.yaml
timeout: '3600s'  # 1 hour

# Or per-step timeout
steps:
  - name: 'hashicorp/terraform:1.10'
    timeout: '1800s'  # 30 minutes
    # ...
```

#### 3. Trigger Not Firing

```bash
# Verify trigger configuration
gcloud builds triggers describe TRIGGER_NAME

# Check trigger history
gcloud builds list --filter="trigger_id=TRIGGER_ID" --limit=5

# Test trigger manually
gcloud builds triggers run TRIGGER_NAME --branch=main
```

## Migrating from GitHub Actions

### Comparison Matrix

| Feature               | GitHub Actions    | Cloud Build       |
|-----------------------|-------------------|-------------------|
| GCP Integration       | Requires secrets  | Native            |
| Build Speed (GCP)     | Slower (external) | Faster (internal) |
| Cost (private)        | $0.008/min        | $0.003/min        |
| Setup Complexity      | Lower             | Medium            |
| GCR/Artifact Registry | Manual push       | Automatic         |
| Multi-cloud           | Better            | GCP-focused       |

### Migration Checklist

- [ ] Enable Cloud Build API
- [ ] Connect GitHub repository
- [ ] Grant service account permissions
- [ ] Create `cloudbuild.yaml`
- [ ] Create build triggers
- [ ] Set up GCS buckets
- [ ] Test builds on dev branch
- [ ] Monitor first production build
- [ ] Set up notifications
- [ ] Disable/remove GitHub Actions workflows (optional)

## Next Steps

1. **Set up monitoring**: Configure Cloud Build notifications
2. **Implement approval gates**: Require manual approval for production
3. **Add deployment steps**: Deploy to Cloud Run, GKE, etc.
4. **Cost tracking**: Set up billing alerts for Cloud Build
5. **Documentation**: Document your specific build process

## Additional Resources

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Build Pricing](https://cloud.google.com/build/pricing)
- [Cloud Build Triggers](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers)
- [Cloud Build GitHub App](https://github.com/apps/google-cloud-build)
