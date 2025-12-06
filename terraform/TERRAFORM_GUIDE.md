# 📘 Comprehensive Terraform Guide

This guide provides detailed information on using Terraform for multi-cloud infrastructure deployments.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration Reference](#configuration-reference)
- [Multi-Cloud Deployment](#multi-cloud-deployment)
- [Best Practices](#best-practices)
- [Security](#security)
- [State Management](#state-management)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

---

## Overview

This Terraform configuration provides a flexible, multi-cloud infrastructure-as-code solution supporting:

- **AWS** - Amazon Web Services
- **GCP** - Google Cloud Platform
- **Multi-Cloud** - Both AWS and GCP simultaneously

### Key Features

- ✅ Multi-cloud support with provider selection
- ✅ Environment-based configurations (dev, staging, prod)
- ✅ Comprehensive input validation
- ✅ Security best practices built-in
- ✅ Conditional resource creation
- ✅ Comprehensive outputs for integration
- ✅ Version constraints for reproducibility

---

## Prerequisites

### Required Software

1. **Terraform** >= 1.10.0
   ```bash
   # Install Terraform
   # macOS
   brew install terraform

   # Linux (Ubuntu/Debian)
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform

   # Verify installation
   terraform version
   ```

2. **Cloud Provider CLI Tools** (based on your target cloud)

   **AWS CLI** (for AWS deployments):
   ```bash
   # macOS
   brew install awscli

   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install

   # Configure credentials
   aws configure
   ```

   **gcloud CLI** (for GCP deployments):
   ```bash
   # macOS
   brew install --cask google-cloud-sdk

   # Linux
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL

   # Configure credentials
   gcloud init
   gcloud auth application-default login
   ```

### Cloud Provider Access

**For AWS:**
- AWS Account with appropriate IAM permissions
- Access Key ID and Secret Access Key OR IAM role
- Permissions to create VPCs, subnets, and other resources

**For GCP:**
- Google Cloud Project with billing enabled
- Service account with necessary permissions OR user account
- APIs enabled: Compute Engine API, Cloud Resource Manager API

---

## Getting Started

### 1. Initial Setup

```bash
# Clone or navigate to the terraform directory
cd terraform

# Review available variables
cat variables.tf

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your configuration:

**AWS-only deployment:**
```hcl
# terraform.tfvars
project_name    = "my-project"
environment     = "dev"
enable_aws      = true
enable_gcp      = false
aws_region      = "eu-west-2"
instance_type   = "t3.micro"
```

**GCP-only deployment:**
```hcl
# terraform.tfvars
project_name    = "my-project"
environment     = "dev"
enable_aws      = false
enable_gcp      = true
gcp_project_id  = "my-gcp-project-id"
gcp_region      = "europe-west2"
gcp_zone        = "europe-west2-a"
```

**Multi-cloud deployment:**
```hcl
# terraform.tfvars
project_name    = "my-project"
environment     = "dev"
enable_aws      = true
enable_gcp      = true
cloud_provider  = "multi"
aws_region      = "eu-west-2"
gcp_project_id  = "my-gcp-project-id"
gcp_region      = "europe-west2"
gcp_zone        = "europe-west2-a"
```

### 3. Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init

# Expected output: "Terraform has been successfully initialized!"
```

### 4. Plan Changes

```bash
# Review planned changes
terraform plan

# Save plan to file for review
terraform plan -out=tfplan

# Review the plan
terraform show tfplan
```

### 5. Apply Configuration

```bash
# Apply changes (will prompt for confirmation)
terraform apply

# Or apply saved plan (no confirmation prompt)
terraform apply tfplan

# Auto-approve (use with caution)
terraform apply -auto-approve
```

### 6. Review Outputs

```bash
# Show all outputs
terraform output

# Show specific output
terraform output aws_vpc_id
terraform output gcp_network_id

# Output in JSON format
terraform output -json
```

### 7. Destroy Resources (when done)

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Destroy specific resources
terraform destroy -target=aws_vpc.main
```

---

## Configuration Reference

### Variables

#### Cloud Provider Selection

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_aws` | bool | `true` | Enable AWS resources and provider |
| `enable_gcp` | bool | `false` | Enable GCP resources and provider |
| `cloud_provider` | string | `"aws"` | Primary cloud provider: aws, gcp, or multi |

#### Project Configuration

| Variable | Type | Default | Validation | Description |
|----------|------|---------|------------|-------------|
| `project_name` | string | - | 1-50 chars | Name of the project |
| `environment` | string | `"dev"` | dev, staging, prod | Environment name |

#### AWS Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `"eu-west-2"` | AWS region for resources |
| `instance_type` | string | `"t3.micro"` | EC2 instance type |
| `vpc_cidr` | string | `"10.0.0.0/16"` | CIDR block for VPC |

#### GCP Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `gcp_project_id` | string | `""` | Google Cloud project ID |
| `gcp_region` | string | `"europe-west2"` | GCP region for resources |
| `gcp_zone` | string | `"europe-west2-a"` | GCP zone for resources |

#### Additional Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_monitoring` | bool | `true` | Enable CloudWatch monitoring |
| `backup_retention_days` | number | `7` | Days to retain backups (1-365) |
| `tags` | map(string) | `{}` | Additional tags to apply |

### Outputs

#### Provider Status

- `providers_enabled` - Map of enabled cloud providers
- `cloud_provider` - Primary cloud provider configuration

#### AWS Outputs

- `aws_vpc_id` - ID of the AWS VPC
- `aws_vpc_cidr_block` - CIDR block of the AWS VPC
- `aws_public_subnet_ids` - IDs of AWS public subnets
- `aws_account_id` - AWS Account ID (sensitive)
- `aws_region` - AWS region

#### GCP Outputs

- `gcp_project_id` - Google Cloud Project ID (sensitive)
- `gcp_network_id` - ID of the GCP VPC network
- `gcp_network_self_link` - Self link of GCP VPC network
- `gcp_subnet_id` - ID of the GCP public subnet
- `gcp_region` - Google Cloud region
- `gcp_zone` - Google Cloud zone

#### Common Outputs

- `project_name` - Name of the project
- `environment` - Environment name

---

## Multi-Cloud Deployment

### Architecture Patterns

#### 1. Single Cloud (AWS)
```
┌─────────────────────────┐
│       AWS Only          │
├─────────────────────────┤
│ • VPC                   │
│ • Subnets               │
│ • Security Groups       │
│ • EC2 Instances         │
└─────────────────────────┘
```

#### 2. Single Cloud (GCP)
```
┌─────────────────────────┐
│       GCP Only          │
├─────────────────────────┤
│ • VPC Network           │
│ • Subnets               │
│ • Firewall Rules        │
│ • Compute Instances     │
└─────────────────────────┘
```

#### 3. Multi-Cloud (Hybrid)
```
┌─────────────┐    ┌─────────────┐
│     AWS     │    │     GCP     │
├─────────────┤    ├─────────────┤
│ • VPC       │    │ • VPC       │
│ • Subnets   │    │ • Subnets   │
│ • Resources │◄──►│ • Resources │
└─────────────┘    └─────────────┘
       VPN or Direct Connect
```

### Use Cases

**AWS Only:**
- AWS-native applications
- Leveraging AWS-specific services
- Cost optimization on AWS

**GCP Only:**
- Google Cloud native applications
- BigQuery/AI Platform integration
- GCP region requirements

**Multi-Cloud:**
- High availability across clouds
- Vendor lock-in avoidance
- Regulatory requirements
- Disaster recovery

### Configuration Examples

**Development Environment (AWS):**
```hcl
project_name    = "myapp"
environment     = "dev"
enable_aws      = true
enable_gcp      = false
aws_region      = "eu-west-2"
instance_type   = "t3.micro"
enable_monitoring = true
```

**Production Multi-Cloud:**
```hcl
project_name    = "myapp"
environment     = "prod"
enable_aws      = true
enable_gcp      = true
cloud_provider  = "multi"
aws_region      = "eu-west-2"
gcp_project_id  = "myapp-prod"
gcp_region      = "europe-west2"
instance_type   = "t3.large"
backup_retention_days = 30
```

---

## Best Practices

### 1. Version Control

```hcl
# Always specify provider versions
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

### 2. Variable Validation

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 3. Resource Naming

```hcl
# Use consistent naming convention
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### 4. Use Locals for Computed Values

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
```

### 5. Conditional Resources

```hcl
# Create resource only when AWS is enabled
resource "aws_vpc" "main" {
  count = var.enable_aws ? 1 : 0

  cidr_block = var.vpc_cidr
}
```

### 6. Output Sensitive Data

```hcl
output "database_password" {
  value     = random_password.db.result
  sensitive = true
}
```

### 7. Use Modules for Reusability

```hcl
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}
```

---

## Security

### Best Practices

#### 1. Never Commit Secrets

```bash
# .gitignore (already included)
*.tfvars
*.tfstate
*.tfstate.backup
.terraform/
terraform.tfvars
```

#### 2. Use Environment Variables

```bash
# Set sensitive variables via environment
export TF_VAR_database_password="secure-password"
export TF_VAR_api_key="your-api-key"

# Run Terraform
terraform apply
```

#### 3. Enable Encryption

**AWS:**
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

**GCP:**
```hcl
resource "google_storage_bucket" "data" {
  name     = "my-data-bucket"
  location = "US"

  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_key.id
  }
}
```

#### 4. Use IAM Roles (Not Keys)

```hcl
# AWS - Use IAM roles for EC2 instances
resource "aws_iam_instance_profile" "app" {
  name = "app-instance-profile"
  role = aws_iam_role.app.name
}

resource "aws_instance" "app" {
  ami                  = "ami-12345678"
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.app.name
}
```

#### 5. Network Security

```hcl
# Restrict access to specific IPs
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Application security group"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal only
  }
}
```

#### 6. Security Scanning

```bash
# Run tfsec for security scanning
tfsec .

# Run checkov for compliance
checkov -d .

# Run terraform-compliance
terraform-compliance -f compliance/ -p tfplan
```

### Security Tools Integration

This repository includes:
- **tfsec** - Static analysis security scanner
- **Checkov** - Policy-as-code security scanning
- **SARIF** - Security Alert reporting

---

## State Management

### Local State (Development)

```bash
# State stored locally in terraform.tfstate
terraform init
terraform apply
```

### Remote State (Production)

#### AWS S3 Backend

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Setup:**
```bash
# Create S3 bucket
aws s3 mb s3://my-terraform-state --region eu-west-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

#### GCP Cloud Storage Backend

```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "prod/terraform/state"
  }
}
```

**Setup:**
```bash
# Create GCS bucket
gsutil mb gs://my-terraform-state

# Enable versioning
gsutil versioning set on gs://my-terraform-state
```

### State Migration

```bash
# Migrate from local to remote
terraform init -migrate-state

# Pull remote state locally
terraform state pull > terraform.tfstate

# Push local state to remote
terraform state push terraform.tfstate
```

### State Operations

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show aws_vpc.main

# Remove resource from state (doesn't delete resource)
terraform state rm aws_vpc.main

# Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Import existing resource
terraform import aws_vpc.main vpc-12345678
```

---

## Troubleshooting

### Common Issues

#### 1. Provider Credential Errors

**Error:**
```
Error: error configuring Terraform AWS Provider: no valid credential sources
```

**Solution:**
```bash
# Configure AWS credentials
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# Or use IAM role (recommended)
```

#### 2. State Lock Errors

**Error:**
```
Error: Error acquiring the state lock
```

**Solution:**
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>

# Check DynamoDB for stuck locks
aws dynamodb scan --table-name terraform-locks
```

#### 3. Resource Already Exists

**Error:**
```
Error: VPC already exists
```

**Solution:**
```bash
# Import existing resource
terraform import aws_vpc.main vpc-12345678

# Or use data source instead
data "aws_vpc" "existing" {
  id = "vpc-12345678"
}
```

#### 4. Invalid Provider Configuration

**Error:**
```
Error: Invalid provider configuration
```

**Solution:**
```hcl
# Ensure provider is properly configured
provider "aws" {
  region = var.aws_region

  # Skip validation if not using AWS
  skip_region_validation = !var.enable_aws
}
```

#### 5. Timeout Errors

**Error:**
```
Error: timeout while waiting for state to become 'available'
```

**Solution:**
```hcl
# Increase timeout in resource
resource "aws_instance" "app" {
  # ... other config ...

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
```

### Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log

# Run command
terraform apply

# Disable debug logging
unset TF_LOG
unset TF_LOG_PATH

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Check for provider updates
terraform init -upgrade
```

---

## Advanced Usage

### Workspaces

```bash
# Create workspace
terraform workspace new dev

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select prod

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete dev
```

### Target Specific Resources

```bash
# Apply only specific resource
terraform apply -target=aws_vpc.main

# Destroy only specific resource
terraform destroy -target=aws_instance.app

# Multiple targets
terraform apply -target=aws_vpc.main -target=aws_subnet.public
```

### Refresh State

```bash
# Refresh state without applying changes
terraform refresh

# Update state from infrastructure
terraform apply -refresh-only
```

### Generate Configuration

```bash
# Generate JSON configuration
terraform show -json > config.json

# Generate dependency graph
terraform graph | dot -Tpng > graph.png
```

### Terraform Console

```bash
# Interactive console
terraform console

# Evaluate expressions
> var.project_name
> local.common_tags
> aws_vpc.main[0].id
```

### Import Resources

```bash
# Import AWS VPC
terraform import aws_vpc.main vpc-12345678

# Import GCP network
terraform import google_compute_network.main projects/my-project/global/networks/my-network

# Generate import configuration
terraform plan -generate-config-out=generated.tf
```

### Using Multiple Provider Configurations

```hcl
# Multiple AWS regions
provider "aws" {
  alias  = "eu-west"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "us-east"
  region = "us-east-1"
}

resource "aws_vpc" "west" {
  provider   = aws.eu-west
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "east" {
  provider   = aws.us-east
  cidr_block = "10.1.0.0/16"
}
```

---

## Additional Resources

### Documentation

- [Terraform Official Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Tools

- **terraform-docs** - Generate documentation from Terraform modules
- **tfsec** - Security scanner for Terraform code
- **Checkov** - Static code analysis for IaC
- **Terragrunt** - Thin wrapper for Terraform
- **Atlantis** - Terraform pull request automation

### Community

- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Discuss](https://discuss.hashicorp.com/c/terraform-core)
- [Terraform GitHub](https://github.com/hashicorp/terraform)

---

**Last Updated:** 2025-01-09
**Terraform Version:** 1.10+
**Maintained By:** [Your Team Name]
