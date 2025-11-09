# Main Terraform configuration - Multi-Cloud Support
# Supports AWS, GCP, or both providers based on variables

terraform {
  # Uncomment and configure backend for production use
  # AWS S3 Backend
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "terraform.tfstate"
  #   region = "us-west-2"
  # }

  # GCP Cloud Storage Backend
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state"
  # }
}

# Configure Providers
# Note: Providers cannot use count/for_each, so they're always configured
# Use conditional resources instead to control what gets created

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment   = var.environment
      Project       = var.project_name
      ManagedBy     = "Terraform"
      CloudProvider = "AWS"
    }
  }

  # Skip provider registration if not needed
  skip_region_validation      = !var.enable_aws
  skip_credentials_validation = !var.enable_aws
  skip_requesting_account_id  = !var.enable_aws
}

provider "google" {
  project = var.gcp_project_id != "" ? var.gcp_project_id : "dummy-project"
  region  = var.gcp_region
  zone    = var.gcp_zone

  default_labels = {
    environment    = var.environment
    project        = var.project_name
    managed-by     = "terraform"
    cloud-provider = "gcp"
  }
}

# Local values for multi-cloud logic
locals {
  # Determine active providers
  providers_enabled = {
    aws = var.enable_aws
    gcp = var.enable_gcp
  }

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}