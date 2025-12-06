<div align="center">

# 🌩️ Terraform Configuration

<p align="center">
  <strong>Infrastructure as Code for Multi-Cloud Deployments</strong><br/>
  <em>AWS • Google Cloud Platform • Multi-Cloud</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Terraform-1.10+-623CE4?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform 1.10+"/>
  <img src="https://img.shields.io/badge/AWS-Supported-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/GCP-Supported-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="GCP"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/tfsec-Security-00ADD8?style=flat-square&logo=terraform&logoColor=white" alt="tfsec"/>
  <img src="https://img.shields.io/badge/checkov-Scanning-1B3C87?style=flat-square&logo=checkmarx&logoColor=white" alt="checkov"/>
  <img src="https://img.shields.io/badge/IaC-Infrastructure_as_Code-purple?style=flat-square" alt="IaC"/>
</p>

</div>

---

This directory contains Terraform infrastructure as code configurations.

> 📖 **For comprehensive documentation, see [TERRAFORM_GUIDE.md](./TERRAFORM_GUIDE.md)**

## 📚 Documentation

- **[TERRAFORM_GUIDE.md](./TERRAFORM_GUIDE.md)** - Complete Terraform guide with advanced usage
- **[README-MultiCloud.md](./README-MultiCloud.md)** - Multi-cloud specific documentation
- **[MULTI_CLOUD_SUMMARY.md](./MULTI_CLOUD_SUMMARY.md)** - Multi-cloud architecture summary

## 📁 Structure

```
terraform/
├── environments/           # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/               # Reusable Terraform modules
│   ├── networking/
│   ├── compute/
│   └── storage/
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
├── versions.tf           # Provider version constraints
└── README.md             # This file
```

## 🌩️ Multi-Cloud Support

This configuration supports **AWS**, **Google Cloud Platform**, or **both** simultaneously:

- **AWS Only**: `enable_aws = true, enable_gcp = false`
- **GCP Only**: `enable_aws = false, enable_gcp = true`  
- **Multi-Cloud**: `enable_aws = true, enable_gcp = true`

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.10.0
- Cloud provider CLI tools:
  - **AWS**: [AWS CLI](https://aws.amazon.com/cli/) (if using AWS)
  - **GCP**: [gcloud CLI](https://cloud.google.com/sdk/gcloud) (if using GCP)
- Valid cloud credentials configured for chosen provider(s)

### Basic Usage

1. **Choose your cloud provider** and copy example variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your provider settings
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Plan changes:**
   ```bash
   # AWS only
   terraform plan -var="enable_aws=true" -var="enable_gcp=false"
   
   # GCP only  
   terraform plan -var="enable_aws=false" -var="enable_gcp=true" -var="gcp_project_id=my-project"
   
   # Multi-cloud
   terraform plan -var="enable_aws=true" -var="enable_gcp=true" -var="gcp_project_id=my-project"
   ```

4. **Apply changes:**
   ```bash
   terraform apply
   ```

5. **Destroy resources (when needed):**
   ```bash
   terraform destroy
   ```

## 🔧 Configuration

### Variables

Key variables that need to be configured:

```hcl
# Example variables - customize for your needs
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "Cloud provider region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
```

### Environment Variables

Set these environment variables or use a `.tfvars` file:

```bash
export TF_VAR_environment="dev"
export TF_VAR_project_name="my-project"
export TF_VAR_region="eu-west-2"
```

Or create a `terraform.tfvars` file:

```hcl
environment  = "dev"
project_name = "my-project"
region      = "eu-west-2"
```

## 🏗️ Architecture

Describe your infrastructure architecture here:

- **Networking**: VPC, subnets, security groups
- **Compute**: EC2 instances, auto scaling groups
- **Storage**: S3 buckets, EBS volumes
- **Database**: RDS instances, DynamoDB tables
- **Load Balancing**: ALB/NLB configuration
- **Security**: IAM roles, security policies

## 🔒 Security

### Best Practices

- [ ] Use least privilege principle for IAM policies
- [ ] Enable encryption at rest and in transit
- [ ] Use secrets management for sensitive data
- [ ] Enable logging and monitoring
- [ ] Regular security assessments with tfsec/checkov

### Security Tools

This repository uses:
- **tfsec**: Static analysis for Terraform
- **Checkov**: Policy as code security scanning
- **terraform-compliance**: BDD testing for Terraform

## 📊 Monitoring

### Outputs

Important outputs from this configuration:

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns
}
```

### State Management

- **Backend**: Configure remote state storage (S3, Azure Storage, GCS)
- **State Locking**: Enable state locking to prevent concurrent modifications
- **Backup**: Regular state backups

## 🧪 Testing

### Local Testing

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan with specific var file
terraform plan -var-file="environments/dev/terraform.tfvars"
```

### Automated Testing

CI/CD pipeline includes:
- Terraform formatting checks
- Terraform validation
- Security scanning
- Plan generation
- Cost estimation (if configured)

## 📚 Documentation

### Module Documentation

Each module includes:
- Purpose and functionality
- Input variables
- Output values
- Usage examples

### Generated Documentation

This README is automatically updated with terraform-docs:

```bash
terraform-docs markdown table --output-file README.md .
```

<!-- BEGIN_TF_DOCS -->
<!-- Terraform documentation will be automatically generated here -->
<!-- END_TF_DOCS -->

## 🤝 Contributing

1. Create a new branch for your changes
2. Make your changes and test locally
3. Run pre-commit hooks: `pre-commit run --all-files`
4. Submit a pull request with detailed description
5. Ensure all CI checks pass

## 🔄 Versioning

We use semantic versioning for this Terraform configuration:
- **MAJOR**: Breaking changes to the infrastructure
- **MINOR**: New features or resources
- **PATCH**: Bug fixes and minor improvements

## 📞 Support

For questions or issues:
1. Check existing [Issues](../../issues)
2. Review [Terraform documentation](https://www.terraform.io/docs)
3. Create a new issue with the bug report template

## 📄 License

This Terraform configuration is licensed under [MIT License](../../LICENSE).