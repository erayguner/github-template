# Multi-Cloud Configuration Guide

## 🎯 Provider Configuration Strategy

Since Terraform providers cannot use `count` or `for_each`, this template uses **conditional resources** instead of conditional providers.

### 🔧 How It Works

1. **Providers are always configured** (but may skip validation if not used)
2. **Resources are conditional** based on `enable_aws` and `enable_gcp` variables
3. **Authentication is optional** - providers skip validation when disabled

## 🚀 Usage Patterns

### Pattern 1: Single Provider (Recommended)

**For AWS-only projects:**
```bash
# Remove GCP files to avoid provider requirements
rm gcp.tf

# Or comment out google provider in main.tf and versions.tf
# Then use: enable_aws = true, enable_gcp = false
```

**For GCP-only projects:**
```bash
# Remove AWS files to avoid provider requirements  
rm aws.tf

# Or comment out aws provider in main.tf and versions.tf
# Then use: enable_aws = false, enable_gcp = true
```

### Pattern 2: Multi-Cloud

Keep all files and use:
```hcl
enable_aws     = true
enable_gcp     = true
gcp_project_id = "your-gcp-project"
```

### Pattern 3: Dynamic Selection

Use the `cloud_provider` variable to control resource creation:

```hcl
# In your .tf files, use:
count = var.cloud_provider == "aws" || var.cloud_provider == "multi" ? 1 : 0
```

## 📁 File Organization

```
terraform/
├── main.tf           # Common configuration and provider setup
├── aws.tf           # AWS-specific resources (conditional)
├── gcp.tf           # GCP-specific resources (conditional) 
├── variables.tf     # All variables including provider selection
├── outputs.tf       # Multi-cloud outputs
├── versions.tf      # Provider version constraints
└── providers.tf     # Provider configuration notes
```

## 🧪 Testing Different Configurations

### Test AWS Configuration
```bash
terraform plan \
  -var="enable_aws=true" \
  -var="enable_gcp=false" \
  -var="project_name=test-aws"
```

### Test GCP Configuration  
```bash
terraform plan \
  -var="enable_aws=false" \
  -var="enable_gcp=true" \
  -var="gcp_project_id=my-test-project" \
  -var="project_name=test-gcp"
```

### Test Multi-Cloud
```bash
terraform plan \
  -var="enable_aws=true" \
  -var="enable_gcp=true" \
  -var="gcp_project_id=my-test-project" \
  -var="project_name=test-multi"
```

## ⚡ Performance Optimization

For better performance and to avoid unnecessary provider initialization:

### Option 1: Remove Unused Provider Files
```bash
# For AWS-only projects
rm gcp.tf

# For GCP-only projects  
rm aws.tf
```

### Option 2: Use Separate Configurations
Create separate directories:
```
terraform-aws/     # AWS-only configuration
terraform-gcp/     # GCP-only configuration  
terraform-multi/   # Multi-cloud configuration
```

## 🔧 Advanced Configuration

### Custom Provider Configuration

For advanced use cases, you can create custom provider configurations:

```hcl
# terraform/custom-providers.tf

# AWS with custom settings
provider "aws" {
  alias  = "custom"
  region = var.aws_region
  
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
  
  default_tags {
    tags = var.aws_default_tags
  }
}

# GCP with custom settings
provider "google" {
  alias                 = "custom"
  project              = var.gcp_project_id
  region               = var.gcp_region
  user_project_override = true
  
  default_labels = var.gcp_default_labels
}
```

## 📚 Best Practices

### 1. Environment-Specific Provider Selection
```hcl
# Use different providers per environment
locals {
  provider_config = {
    dev     = { aws = true,  gcp = false }
    staging = { aws = false, gcp = true  }
    prod    = { aws = true,  gcp = true  }
  }
}

enable_aws = local.provider_config[var.environment].aws
enable_gcp = local.provider_config[var.environment].gcp
```

### 2. Resource Naming Conventions
```hcl
# Include cloud provider in resource names
resource "aws_vpc" "main" {
  count = var.enable_aws ? 1 : 0
  
  tags = {
    Name = "${var.project_name}-aws-vpc"
  }
}

resource "google_compute_network" "main" {
  count = var.enable_gcp ? 1 : 0
  
  name = "${var.project_name}-gcp-vpc"
}
```

### 3. Conditional Data Sources
```hcl
# Only fetch data when provider is enabled
data "aws_availability_zones" "available" {
  count = var.enable_aws ? 1 : 0
  state = "available"
}

data "google_compute_zones" "available" {
  count  = var.enable_gcp ? 1 : 0
  region = var.gcp_region
}
```

## 🚨 Common Gotchas

1. **Provider credentials**: Even unused providers may require dummy credentials
2. **Resource references**: Use conditional logic when referencing resources from disabled providers
3. **Data sources**: Make data sources conditional to avoid authentication errors
4. **Outputs**: Use conditional outputs to avoid referencing non-existent resources

## 💡 Migration Guide

### From Single Provider to Multi-Cloud

1. **Add provider variables** to your existing configuration
2. **Move resources** to conditional blocks
3. **Update outputs** to be conditional
4. **Test thoroughly** with different provider combinations

### From Multi-Cloud to Single Provider

1. **Set one provider to false**: `enable_aws = false` or `enable_gcp = false`
2. **Remove unused resources**: Delete aws.tf or gcp.tf
3. **Simplify outputs**: Remove conditional logic
4. **Clean up providers**: Remove unused provider from versions.tf