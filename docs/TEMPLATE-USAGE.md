# How to Use This Template

This guide walks you through customizing this GitHub template for your own GCP project.

## Table of Contents

- [Using as a GitHub Template](#using-as-a-github-template)
- [What to Customize](#what-to-customize)
- [Step-by-Step Customization](#step-by-step-customization)
- [Checklist](#checklist)
- [Common Customizations](#common-customizations)
- [Troubleshooting](#troubleshooting)

---

## Using as a GitHub Template

### Option 1: GitHub UI (Recommended)

1. Click the green **"Use this template"** button at the top of the repository
2. Select **"Create a new repository"**
3. Fill in your repository details:
   - **Repository name**: Your project name (e.g., `my-gcp-project`)
   - **Description**: Brief description of your project
   - **Visibility**: Public or Private
4. Click **"Create repository from template"**

### Option 2: GitHub CLI

```bash
gh repo create my-gcp-project --template erayguner/github-template --private
cd my-gcp-project
```

### Option 3: Manual Clone

```bash
# Clone the template
git clone https://github.com/erayguner/github-template.git my-gcp-project
cd my-gcp-project

# Remove template git history
rm -rf .git

# Initialize new git repository
git init
git add .
git commit -m "Initial commit from template"

# Add your remote
git remote add origin https://github.com/YOUR_USERNAME/my-gcp-project.git
git push -u origin main
```

---

## What to Customize

### Required Changes

| File/Location | What to Change | Example |
|---------------|----------------|---------|
| `terraform/terraform.tfvars` | GCP project ID, region, project name | `gcp_project_id = "my-project-123"` |
| `.github/workflows/*.yml` | Repository references (if forking) | Update `erayguner/github-template` |
| `README.md` | Project name, description, badges | Update title and description |
| `.github/CODEOWNERS` | Team members and reviewers | Add your GitHub usernames |

### Recommended Changes

| File/Location | What to Change | Why |
|---------------|----------------|-----|
| `CONTRIBUTING.md` | Contribution guidelines | Customize for your team |
| `SECURITY.md` | Security contact info | Add your security email |
| `docs/` | Documentation | Update for your use case |
| `python/src/` | Application code | Replace with your code |

### Optional Changes

| File/Location | What to Change | When |
|---------------|----------------|------|
| `terraform/aws.tf` | AWS resources | If not using AWS |
| `.mega-linter.yml` | Linter configuration | If using different tools |
| `cloudbuild.yaml` | Build steps | For custom deployments |

---

## Step-by-Step Customization

### Step 1: Set Up Your GCP Project

```bash
# Run the setup script with your GCP project ID
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID

# This creates:
# - Service account with proper permissions
# - GCS bucket for Terraform state
# - Enables required APIs
# - Generates backend configuration
```

### Step 2: Update Terraform Variables

Create your `terraform.tfvars` file:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Project Configuration
project_name   = "my-awesome-project"
environment    = "dev"

# GCP Configuration
enable_gcp      = true
gcp_project_id  = "my-gcp-project-123456"
gcp_region      = "europe-west2"
gcp_zone        = "europe-west2-a"

# AWS Configuration (set to false if not using)
enable_aws = false

# GitHub Integration (for Workload Identity)
github_org  = "your-github-username"
github_repo = "your-repo-name"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Optional: Tags
tags = {
  Team        = "Platform"
  CostCenter  = "Engineering"
}
```

### Step 3: Update GitHub Secrets

Add these secrets to your GitHub repository (Settings > Secrets > Actions):

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `GCP_PROJECT_ID` | Your GCP project ID | From GCP Console |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Workload Identity Provider | From Terraform output |
| `GCP_SERVICE_ACCOUNT` | Service account email | From Terraform output |

### Step 4: Update Repository References

Search and replace in these files:

```bash
# Find all references to the template repository
grep -r "erayguner/github-template" .

# Update to your repository
# Example: sed -i 's/erayguner\/github-template/your-username\/your-repo/g' README.md
```

### Step 5: Update Documentation

1. **README.md**: Update project name, description, and badges
2. **CONTRIBUTING.md**: Customize contribution guidelines
3. **SECURITY.md**: Add your security contact
4. **CODEOWNERS**: Add your team members

### Step 6: Configure Pre-commit

```bash
# Install pre-commit hooks
pre-commit install

# Run initial check
pre-commit run --all-files
```

### Step 7: Initialize Terraform Backend

```bash
cd terraform

# Update backend.tf with your bucket name
# Then initialize
terraform init \
  -backend-config="bucket=YOUR_PROJECT_ID-terraform-state" \
  -backend-config="prefix=terraform/state"
```

### Step 8: Verify Everything Works

```bash
# Return to project root
cd ..

# Run full validation
make validate-all

# This runs:
# - Python linting and tests
# - Terraform validation
# - Security scans
# - Pre-commit hooks
```

---

## Checklist

Use this checklist when setting up your new project:

### Initial Setup

- [ ] Created repository from template
- [ ] Cloned repository locally
- [ ] Ran `./scripts/setup-gcp-project.sh YOUR_PROJECT_ID`

### Terraform Configuration

- [ ] Created `terraform/terraform.tfvars` from example
- [ ] Updated GCP project ID
- [ ] Set correct region and zone
- [ ] Configured enable_gcp/enable_aws flags
- [ ] Set github_org and github_repo for Workload Identity
- [ ] Updated backend.tf with state bucket name
- [ ] Ran `terraform init` successfully
- [ ] Ran `terraform validate` successfully
- [ ] Ran `terraform plan` and reviewed changes

### GitHub Configuration

- [ ] Added GCP_PROJECT_ID secret
- [ ] Added GCP_WORKLOAD_IDENTITY_PROVIDER secret
- [ ] Added GCP_SERVICE_ACCOUNT secret
- [ ] Updated CODEOWNERS file
- [ ] Updated repository settings (branch protection, etc.)

### Documentation

- [ ] Updated README.md with project info
- [ ] Updated CONTRIBUTING.md
- [ ] Updated SECURITY.md with contact info
- [ ] Reviewed and updated docs/ as needed

### Development Setup

- [ ] Ran `make setup` successfully
- [ ] Pre-commit hooks installed
- [ ] All pre-commit checks pass
- [ ] CI pipeline runs successfully

### First Deployment

- [ ] Created dev environment
- [ ] Ran `terraform apply` for initial infrastructure
- [ ] Verified resources in GCP Console
- [ ] Tested Cloud Build deployment

---

## Common Customizations

### Removing AWS Support

If you're only using GCP:

1. Set `enable_aws = false` in `terraform.tfvars`
2. Optionally delete `terraform/aws.tf`
3. Remove AWS references from documentation

### Adding New Terraform Resources

1. Create a new `.tf` file in `terraform/` directory
2. Follow naming convention: `resource_type.tf` (e.g., `cloud_sql.tf`)
3. Add variables to `variables.tf`
4. Add outputs to `outputs.tf`

### Customizing CI/CD Pipeline

Edit `.github/workflows/ci.yml`:

```yaml
# Add new job
your-custom-job:
  name: Your Custom Job
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v5
    - name: Run custom task
      run: |
        echo "Your custom commands here"
```

### Changing Python Version

1. Update `pyproject.toml`:
   ```toml
   [project]
   requires-python = ">=3.12"
   ```

2. Update `.github/workflows/ci.yml`:
   ```yaml
   - name: Set up Python
     run: uv python install 3.12
   ```

3. Update `.pre-commit-config.yaml`:
   ```yaml
   default_language_version:
     python: python3.12
   ```

---

## Troubleshooting

### Terraform Init Fails

```bash
# Error: Backend configuration required
# Solution: Ensure state bucket exists
gsutil mb -l europe-west2 gs://YOUR_PROJECT_ID-terraform-state
gsutil versioning set on gs://YOUR_PROJECT_ID-terraform-state
```

### Pre-commit Hooks Fail

```bash
# Error: terraform_validate failed
# Solution: Initialize Terraform first
cd terraform && terraform init -backend=false && cd ..

# Then retry
pre-commit run --all-files
```

### Workload Identity Federation Issues

```bash
# Error: Permission denied
# Solution: Verify the Workload Identity setup
gcloud iam workload-identity-pools describe github-pool \
  --location="global" \
  --project=YOUR_PROJECT_ID
```

### GitHub Actions Secrets Not Found

1. Verify secrets are added to repository (not organization level unless inherited)
2. Check secret names match exactly (case-sensitive)
3. Ensure workflow has correct permissions

---

## Getting Help

- [GCP Quick Start](QUICK-START-GCP.md) - 5-minute setup guide
- [Full GCP Setup](GCP-SETUP.md) - Comprehensive documentation
- [Cloud Build](CLOUD-BUILD.md) - CI/CD deployment guide
- [Issues](https://github.com/erayguner/github-template/issues) - Report bugs or request features
