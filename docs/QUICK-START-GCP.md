# GCP Terraform CI/CD - Quick Start Guide

Get your GCP Terraform CI/CD pipeline running in **5 minutes** with just your GCP Project ID!

## Prerequisites

- GCP Account with billing enabled
- `gcloud` CLI installed and authenticated
- `terraform` installed (1.10+)
- GitHub repository access

## One-Command Setup

```bash
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID
```

That's it! The script will automatically:
- ✅ Create/configure your GCP project
- ✅ Enable all required APIs
- ✅ Create service account with proper permissions
- ✅ Generate service account key
- ✅ Create GCS buckets (state, logs, artifacts)
- ✅ Configure Terraform backend
- ✅ Generate terraform.tfvars

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

## GitHub Configuration

After running the setup script, add these secrets to your GitHub repository:

### 1. Navigate to Repository Settings

```
GitHub Repository > Settings > Secrets and variables > Actions > New repository secret
```

### 2. Add Required Secrets

#### Secret 1: GCP_PROJECT_ID
```
Name: GCP_PROJECT_ID
Value: your-gcp-project-id
```

#### Secret 2: GCP_SA_KEY
```bash
# Get the base64-encoded key (command provided by setup script)
cat github-actions-key-YOUR_PROJECT_ID.json | base64 -w 0

# Copy the output and add as secret
Name: GCP_SA_KEY
Value: <paste base64-encoded key>
```

#### Secret 3: TF_VAR_gcp_project_id
```
Name: TF_VAR_gcp_project_id
Value: your-gcp-project-id
```

### 3. Delete Local Key File

**IMPORTANT**: After adding the key to GitHub, delete the local file:
```bash
rm github-actions-key-YOUR_PROJECT_ID.json
```

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
- [Template Usage](TEMPLATE-USAGE.md)
- [Multi-Cloud Setup](multi-cloud.md)
- [CI/CD Architecture](ci-architecture.md)

### External Links
- [GCP Free Tier](https://cloud.google.com/free)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)

### Support
- GitHub Issues: [Report issues](https://github.com/erayguner/github-template/issues)
- GCP Support: https://cloud.google.com/support
- Terraform Community: https://discuss.hashicorp.com/

## Success Checklist

- [ ] Setup script completed successfully
- [ ] GitHub secrets added (all 3)
- [ ] Local Terraform test passed
- [ ] GitHub Actions pipeline passed
- [ ] GCS buckets created
- [ ] Service account key deleted locally
- [ ] Documentation reviewed
- [ ] Billing alerts configured
- [ ] First Terraform apply successful

🎉 **Congratulations!** Your GCP Terraform CI/CD pipeline is ready!

---

**Pro Tip**: Star this repository and use it as a template for future GCP projects!
