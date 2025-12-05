# Terraform Backend Configuration
# This file configures remote state storage in Google Cloud Storage
#
# IMPORTANT: Before using this backend, you must:
# 1. Create the GCS bucket: gsutil mb -l us-central1 gs://${PROJECT_ID}-terraform-state
# 2. Enable versioning: gsutil versioning set on gs://${PROJECT_ID}-terraform-state
# 3. Set up IAM permissions for the service account
#
# To migrate from local to remote state:
#   terraform init -migrate-state
#
# For different environments, use workspaces or backend prefixes:
#   terraform workspace new dev
#   terraform workspace new staging
#   terraform workspace new prod

terraform {
  # Google Cloud Storage backend (recommended for GCP projects)
  # Uncomment and configure when ready for remote state management
  #
  # backend "gcs" {
  #   # Bucket name format: {project_id}-terraform-state
  #   # Replace with your actual bucket name
  #   bucket = "YOUR_PROJECT_ID-terraform-state"
  #
  #   # State file prefix (use different prefixes for environments)
  #   prefix = "terraform/state"
  #
  #   # Optional: Encryption using Cloud KMS
  #   # encryption_key = "projects/PROJECT/locations/LOCATION/keyRings/KEYRING/cryptoKeys/KEY"
  # }

  # Alternative: AWS S3 backend (for multi-cloud or AWS-primary projects)
  # backend "s3" {
  #   bucket         = "YOUR_BUCKET_NAME-terraform-state"
  #   key            = "terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  #
  #   # Optional: Use IAM role for access
  #   # role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformStateAccess"
  # }
}

# Local values for state management
locals {
  # Backend bucket naming convention
  state_bucket_name = "${var.project_name}-terraform-state"

  # State file paths for different environments
  state_paths = {
    dev     = "terraform/state/dev"
    staging = "terraform/state/staging"
    prod    = "terraform/state/prod"
  }

  # Current state path based on environment
  current_state_path = local.state_paths[var.environment]
}

# GCS bucket for Terraform state (create this before using GCS backend)
# Uncomment when you want Terraform to manage the state bucket itself
#
# resource "google_storage_bucket" "terraform_state" {
#   count = var.enable_gcp ? 1 : 0
#
#   name          = local.state_bucket_name
#   location      = var.gcp_region
#   project       = var.gcp_project_id
#   force_destroy = false
#
#   # Enable versioning for state history
#   versioning {
#     enabled = true
#   }
#
#   # Lifecycle rule to clean up old versions
#   lifecycle_rule {
#     action {
#       type = "Delete"
#     }
#     condition {
#       num_newer_versions = 10
#       with_state         = "ARCHIVED"
#     }
#   }
#
#   # Prevent public access
#   uniform_bucket_level_access = true
#
#   labels = {
#     purpose     = "terraform-state"
#     environment = var.environment
#     managed_by  = "terraform"
#   }
# }

# DynamoDB table for state locking (AWS)
# Uncomment when using S3 backend
#
# resource "aws_dynamodb_table" "terraform_locks" {
#   count = var.enable_aws ? 1 : 0
#
#   name         = "${var.project_name}-terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#
#   tags = {
#     Name        = "${var.project_name}-terraform-locks"
#     Environment = var.environment
#     ManagedBy   = "terraform"
#   }
# }
