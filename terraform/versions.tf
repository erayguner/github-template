# Terraform and provider version constraints

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # AWS Provider (optional - enabled via var.enable_aws)
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    # Google Cloud Provider (optional - enabled via var.enable_gcp)
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    # Utility providers (always available)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}