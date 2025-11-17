# GCP Terraform CI/CD - Quick Start Guide

Get your GCP Terraform CI/CD pipeline running in **5 minutes** with just your GCP Project ID!

## Prerequisites

- GCP Account with billing enabled
- `gcloud` CLI installed and authenticated
- `terraform` installed (1.10+)
- GitHub repository access

## Setup Overview

This guide walks you through setting up GCP with Workload Identity Federation (no service account keys needed).

**What you'll configure:**
- ✅ Enable required GCP APIs
- ✅ Create service account with proper IAM roles
- ✅ Set up Workload Identity Federation for GitHub Actions
- ✅ Create GCS buckets (state, logs, artifacts)
- ✅ Configure Terraform backend
- ✅ Set up GitHub repository variables

## What Gets Created

### GCP Resources

| Resource        | Name                         | Purpose                 |
|-----------------|------------------------------|-------------------------|
| Service Account | `github-actions-terraform`   | CI/CD authentication    |
| GCS Bucket      | `PROJECT_ID-terraform-state` | Terraform state storage |
| GCS Bucket      | `PROJECT_ID-build-logs`      | Build logs              |
| GCS Bucket      | `PROJECT_ID-build-artifacts` | Build artifacts         |
| GCS Bucket      | `PROJECT_ID-build-cache`     | Build cache             |

### IAM Roles

The service account is granted:
- `roles/editor` - Manage resources
- `roles/compute.admin` - Compute resources
- `roles/storage.admin` - Storage management
- `roles/iam.serviceAccountUser` - Service account usage

### APIs Enabled

- Compute Engine API
- Cloud Resource Manager API
- IAM API
- Service Usage API
- Cloud Storage API
- Cloud Build API (optional)
- Logging API
- Monitoring API

## GitHub Workload Identity Federation

Instead of using service account keys, this setup uses **Workload Identity Federation** for secure, keyless authentication.

### 1. Create Workload Identity Pool

```bash
# Enable IAM Credentials API
gcloud services enable iamcredentials.googleapis.com --project=YOUR_PROJECT_ID

# Get project number
export PROJECT_NUMBER=$(gcloud projects describe YOUR_PROJECT_ID --format='value(projectNumber)')

# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Create Workload Identity Provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner == 'YOUR_GITHUB_USERNAME'" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### 2. Grant Service Account Access

```bash
# Allow GitHub Actions to impersonate service account
export SA_EMAIL="github-actions-terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com"
export GITHUB_REPO="YOUR_GITHUB_USERNAME/github-template"

gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="YOUR_PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```

### 3. Configure GitHub Repository

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click the **Variables** tab
3. Add these variables:

| Variable Name                    | Value                                                  |
|----------------------------------|--------------------------------------------------------|
| `GCP_PROJECT_ID`                 | `YOUR_PROJECT_ID`                                      |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider` |
| `GCP_SERVICE_ACCOUNT`            | `github-actions-terraform@YOUR_PROJECT_ID.iam.gserviceaccount.com` |
| `TF_VAR_gcp_project_id`          | `YOUR_PROJECT_ID`                                      |

## Test Terraform Locally

```bash
# Navigate to Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure
terraform plan

# Review the plan, then apply
terraform apply
```

## Trigger CI/CD Pipeline

```bash
# Commit and push to trigger pipeline
git add .
git commit -m "feat: configure GCP project for CI/CD"
git push origin main
```

The GitHub Actions pipeline will:
1. 🔍 Detect Terraform files
2. 🔧 Check formatting
3. ✅ Validate configuration
4. 🔒 Run security scans (tfsec, checkov)
5. 📊 Upload results to GitHub Security

## Verify Everything Works

### Check GitHub Actions

1. Go to your repository on GitHub
2. Click **Actions** tab
3. You should see the CI/CD pipeline running
4. All jobs should complete successfully

### Check GCP Resources

```bash
# List enabled APIs
gcloud services list --enabled --project=YOUR_PROJECT_ID

# List GCS buckets
gcloud storage buckets list --project=YOUR_PROJECT_ID

# Check Terraform state
gsutil ls gs://YOUR_PROJECT_ID-terraform-state/
```

## Customization

### Change Region/Zone

```bash
./scripts/setup-gcp-project.sh YOUR_PROJECT_ID \
  --region europe-west1 \
  --zone europe-west1-b
```

### Skip Billing Check

```bash
./scripts/setup-gcp-project.sh YOUR_PROJECT_ID --skip-billing
```

### Custom Service Account Name

```bash
./scripts/setup-gcp-project.sh YOUR_PROJECT_ID \
  --sa-name my-custom-sa
```

## Troubleshooting

### "Project not found"

```bash
# List your projects
gcloud projects list

# Authenticate
gcloud auth login
```

### "API not enabled"

```bash
# Enable specific API
gcloud services enable SERVICE_NAME.googleapis.com --project=YOUR_PROJECT_ID
```

### "Permission denied"

```bash
# Check your IAM permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"
```

### GitHub Actions Fails

1. Verify all three secrets are added correctly
2. Check `GCP_SA_KEY` is base64-encoded (no line breaks)
3. Ensure service account has proper permissions
4. Check GitHub Actions logs for specific error

## Advanced Configuration

### Enable Cloud Build (Optional)

```bash
# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com --project=YOUR_PROJECT_ID

# See Cloud Build integration guide
cat docs/CLOUD-BUILD.md
```

### Multiple Environments

Create separate projects for each environment:

```bash
# Development
./scripts/setup-gcp-project.sh my-project-dev

# Staging
./scripts/setup-gcp-project.sh my-project-staging

# Production
./scripts/setup-gcp-project.sh my-project-prod
```

### Custom Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
# Your custom values
project_name = "my-awesome-project"
environment  = "production"
vpc_cidr     = "10.100.0.0/16"

tags = {
  Team       = "Platform"
  CostCenter = "Engineering"
  Owner      = "devops@example.com"
}
```

## What's Next?

### 1. Review Security

- [ ] Check [SECURITY.md](../SECURITY.md) for best practices
- [ ] Review IAM permissions (principle of least privilege)
- [ ] Set up billing alerts
- [ ] Enable VPC Service Controls (for production)

### 2. Add Infrastructure

Edit `terraform/gcp.tf` to add your resources:
- Compute instances
- Cloud SQL databases
- Cloud Run services
- GKE clusters
- Cloud Functions

### 3. Set Up Environments

- [ ] Create separate GCP projects for dev/staging/prod
- [ ] Configure environment-specific variables
- [ ] Set up proper approval gates for production

### 4. Monitoring & Alerts

```bash
# Enable monitoring
gcloud services enable monitoring.googleapis.com

# Set up billing alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget" \
  --budget-amount=100USD \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90
```

### 5. Cost Optimization

- Use appropriate machine types
- Implement auto-scaling
- Clean up unused resources
- Use committed use discounts
- Monitor with Cloud Billing reports

## Resources

### Documentation
- [Full GCP Setup Guide](GCP-SETUP.md)
- [Cloud Build Integration](CLOUD-BUILD.md)
- [Multi-Cloud Setup](multi-cloud.md)

### External Links
- [GCP Free Tier](https://cloud.google.com/free)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)

### Support
- GitHub Issues: [Report issues](https://github.com/erayguner/github-template/issues)
- GCP Support: https://cloud.google.com/support
- Terraform Community: https://discuss.hashicorp.com/

## Success Checklist

- [ ] Required GCP APIs enabled
- [ ] Service account created with proper IAM roles
- [ ] Workload Identity Pool and Provider created
- [ ] GitHub repository variables configured (all 4)
- [ ] Local Terraform test passed
- [ ] GitHub Actions pipeline passed with Workload Identity
- [ ] GCS buckets created
- [ ] Documentation reviewed
- [ ] Billing alerts configured
- [ ] First Terraform apply successful

🎉 **Congratulations!** Your GCP Terraform CI/CD pipeline is ready!

---

**Pro Tip**: Star this repository and use it as a template for future GCP projects!
