# Multi-Cloud Terraform Configuration

This template supports **AWS**, **Google Cloud Platform (GCP)**, or **both** providers simultaneously, giving you flexibility in your cloud infrastructure deployment.

## 🌩️ Supported Cloud Providers

| Provider | Status | Features Supported |
|----------|---------|-------------------|
| **AWS** | ✅ Full Support | VPC, Subnets, Security Groups, EC2 |
| **GCP** | ✅ Full Support | VPC Network, Subnets, Firewall Rules, Compute Engine |
| **Multi-Cloud** | ✅ Supported | Deploy to both AWS and GCP simultaneously |

## 🚀 Quick Start

### 1. Choose Your Cloud Strategy

**Option A: AWS Only**
```hcl
cloud_provider = "aws"
enable_aws     = true
enable_gcp     = false
aws_region     = "us-west-2"
```

**Option B: GCP Only**
```hcl
cloud_provider = "gcp"
enable_aws     = false
enable_gcp     = true
gcp_project_id = "my-gcp-project"
gcp_region     = "us-central1"
```

**Option C: Multi-Cloud**
```hcl
cloud_provider = "multi"
enable_aws     = true
enable_gcp     = true
aws_region     = "us-west-2"
gcp_project_id = "my-gcp-project"
gcp_region     = "us-central1"
```

### 2. Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configuration.

### 3. Initialize and Deploy

```bash
# Initialize Terraform (downloads required providers)
terraform init

# Review the deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

## 🏗️ Architecture Patterns

### AWS Architecture
```
AWS VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)
├── Internet Gateway
├── Route Tables
└── Security Groups
```

### GCP Architecture
```
GCP VPC Network
├── Public Subnet (10.0.0.0/16)
├── Firewall Rules (HTTP/HTTPS/SSH)
├── Cloud Router
└── Cloud NAT
```

### Multi-Cloud Architecture
```
Hybrid Infrastructure
├── AWS Resources
│   ├── VPC + Subnets
│   └── Security Groups
└── GCP Resources
    ├── VPC Network + Subnets  
    └── Firewall Rules
```

## 🔧 Configuration Options

### Provider Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_aws` | bool | `true` | Enable AWS provider and resources |
| `enable_gcp` | bool | `false` | Enable GCP provider and resources |
| `cloud_provider` | string | `"aws"` | Primary cloud strategy (aws/gcp/multi) |

### AWS Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `"us-west-2"` | AWS region for resources |
| `instance_type` | string | `"t3.micro"` | EC2 instance type |

### GCP Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `gcp_project_id` | string | `""` | GCP project ID (required if enable_gcp=true) |
| `gcp_region` | string | `"us-central1"` | GCP region for resources |
| `gcp_zone` | string | `"us-central1-a"` | GCP zone for resources |

## 🔒 Authentication Setup

### AWS Authentication

**Option 1: AWS CLI**
```bash
aws configure
```

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"
```

**Option 3: IAM Role (recommended for CI/CD)**
```bash
# Configure IAM role with appropriate permissions
export AWS_ROLE_ARN="arn:aws:iam::123456789012:role/TerraformRole"
```

### GCP Authentication

**Option 1: gcloud CLI**
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

**Option 2: Service Account Key**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

**Option 3: ADC (Application Default Credentials)**
```bash
gcloud auth application-default login
```

## 📋 Usage Examples

### Example 1: AWS Development Environment

```hcl
# terraform.tfvars
project_name   = "webapp-dev"
environment    = "dev"
cloud_provider = "aws"
enable_aws     = true
enable_gcp     = false
aws_region     = "us-west-2"
vpc_cidr       = "10.0.0.0/16"
instance_type  = "t3.micro"
```

### Example 2: GCP Production Environment

```hcl
# terraform.tfvars
project_name   = "webapp-prod"
environment    = "prod"
cloud_provider = "gcp"
enable_aws     = false
enable_gcp     = true
gcp_project_id = "webapp-production-12345"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"
vpc_cidr       = "10.0.0.0/16"
```

### Example 3: Multi-Cloud Staging

```hcl
# terraform.tfvars
project_name   = "webapp-staging"
environment    = "staging"
cloud_provider = "multi"
enable_aws     = true
enable_gcp     = true
aws_region     = "us-west-2"
gcp_project_id = "webapp-staging-67890"
gcp_region     = "us-central1"
vpc_cidr       = "10.0.0.0/16"
```

## 🎯 Resource Mapping

### Network Resources

| Resource Type | AWS | GCP |
|---------------|-----|-----|
| **Virtual Network** | `aws_vpc` | `google_compute_network` |
| **Subnet** | `aws_subnet` | `google_compute_subnetwork` |
| **Internet Gateway** | `aws_internet_gateway` | Built-in |
| **NAT Gateway** | `aws_nat_gateway` | `google_compute_router_nat` |
| **Route Table** | `aws_route_table` | `google_compute_route` |

### Security Resources

| Resource Type | AWS | GCP |
|---------------|-----|-----|
| **Firewall** | `aws_security_group` | `google_compute_firewall` |
| **IAM Role** | `aws_iam_role` | `google_service_account` |
| **Policy** | `aws_iam_policy` | `google_project_iam_binding` |

### Compute Resources

| Resource Type | AWS | GCP |
|---------------|-----|-----|
| **Virtual Machine** | `aws_instance` | `google_compute_instance` |
| **Load Balancer** | `aws_lb` | `google_compute_url_map` |
| **Auto Scaling** | `aws_autoscaling_group` | `google_compute_instance_group_manager` |

## 🛠️ Advanced Configuration

### Backend Configuration

**AWS S3 Backend:**
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
  }
}
```

**GCP Cloud Storage Backend:**
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "infrastructure/terraform/state"
  }
}
```

### Provider Aliases (for multi-region deployments)

```hcl
# Multiple AWS regions
provider "aws" {
  alias  = "primary"
  region = "us-west-2"
}

provider "aws" {
  alias  = "secondary"
  region = "us-east-1"
}

# Multiple GCP regions
provider "google" {
  alias   = "primary"
  project = var.gcp_project_id
  region  = "us-central1"
}

provider "google" {
  alias   = "secondary"
  project = var.gcp_project_id
  region  = "europe-west1"
}
```

## 🧪 Testing Multi-Cloud Configuration

### Test AWS Only
```bash
terraform plan -var="enable_aws=true" -var="enable_gcp=false"
```

### Test GCP Only
```bash
terraform plan -var="enable_aws=false" -var="enable_gcp=true" -var="gcp_project_id=my-project"
```

### Test Multi-Cloud
```bash
terraform plan -var="enable_aws=true" -var="enable_gcp=true" -var="gcp_project_id=my-project"
```

## 🔍 Troubleshooting

### Common Issues

**Issue**: Provider authentication errors
**Solution**: Ensure proper authentication setup for each enabled provider

**Issue**: GCP project not found
**Solution**: Verify `gcp_project_id` is correct and you have access

**Issue**: AWS region access denied
**Solution**: Check IAM permissions for the specified AWS region

**Issue**: Resource conflicts in multi-cloud
**Solution**: Use different CIDR ranges or naming conventions

### Validation Commands

```bash
# Check provider authentication
terraform plan -refresh-only

# Validate configuration syntax
terraform validate

# Check resource dependencies
terraform graph | dot -Tpng > infrastructure.png
```

## 📊 Cost Optimization

### AWS Cost Optimization
- Use `t3.micro` instances for development
- Enable spot instances for non-critical workloads
- Use reserved instances for production

### GCP Cost Optimization
- Use `e2-micro` instances for development
- Enable preemptible instances for batch workloads
- Use committed use discounts for production

### Multi-Cloud Cost Management
- Deploy development in the most cost-effective region
- Use cloud-specific cost monitoring tools
- Implement resource tagging for cost allocation

## 🚀 Migration Strategies

### AWS to GCP Migration
1. Enable both providers: `enable_aws=true`, `enable_gcp=true`
2. Deploy GCP infrastructure parallel to AWS
3. Migrate data and applications
4. Disable AWS: `enable_aws=false`

### GCP to AWS Migration
1. Enable both providers: `enable_aws=true`, `enable_gcp=true`
2. Deploy AWS infrastructure parallel to GCP
3. Migrate data and applications
4. Disable GCP: `enable_gcp=false`

## 📚 Additional Resources

- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Multi-Provider Best Practices](https://www.terraform.io/docs/language/providers/configuration.html)
- [Cloud Provider Comparison Guide](https://cloud.google.com/docs/compare/aws)