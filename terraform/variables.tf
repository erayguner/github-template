# Input variables for Terraform configuration

# Cloud Provider Selection
variable "enable_aws" {
  description = "Enable AWS resources and provider"
  type        = bool
  default     = true
}

variable "enable_gcp" {
  description = "Enable Google Cloud resources and provider"
  type        = bool
  default     = false
}

variable "cloud_provider" {
  description = "Primary cloud provider (aws, gcp, or multi)"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "gcp", "multi"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, gcp, multi."
  }
}

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 50
    error_message = "Project name must be between 1 and 50 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-west-2, eu-central-1, etc."
  }
}

# GCP Configuration
variable "gcp_project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_project_id)) || var.gcp_project_id == ""
    error_message = "GCP project ID must be 6-30 characters, start with lowercase letter, contain only lowercase letters, numbers, and hyphens, and end with letter or number. Use empty string to disable GCP."
  }
}

variable "gcp_region" {
  description = "Google Cloud region for resources"
  type        = string
  default     = "europe-west2"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.gcp_region))
    error_message = "GCP region must be in the format: us-central1, europe-west1, etc."
  }
}

variable "gcp_zone" {
  description = "Google Cloud zone for resources"
  type        = string
  default     = "europe-west2-a"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.gcp_zone))
    error_message = "GCP zone must be in the format: us-central1-a, europe-west1-b, etc."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition = contains([
      "t3.micro", "t3.small", "t3.medium", "t3.large",
      "t3.xlarge", "t3.2xlarge", "m5.large", "m5.xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

# GitHub Integration Variables (for Workload Identity Federation)
variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", var.github_org)) || var.github_org == ""
    error_message = "GitHub org must contain only alphanumeric characters and hyphens."
  }
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.github_repo)) || var.github_repo == ""
    error_message = "GitHub repo must contain only valid repository characters."
  }
}

# Cloud Run Configuration
variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service"
  type        = string
  default     = "512Mi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.cloud_run_memory))
    error_message = "Cloud Run memory must be specified in Mi or Gi (e.g., 512Mi, 1Gi)."
  }
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run service"
  type        = string
  default     = "1"

  validation {
    condition     = contains(["1", "2", "4", "8"], var.cloud_run_cpu)
    error_message = "Cloud Run CPU must be 1, 2, 4, or 8."
  }
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0

  validation {
    condition     = var.cloud_run_min_instances >= 0 && var.cloud_run_min_instances <= 100
    error_message = "Min instances must be between 0 and 100."
  }
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10

  validation {
    condition     = var.cloud_run_max_instances >= 1 && var.cloud_run_max_instances <= 1000
    error_message = "Max instances must be between 1 and 1000."
  }
}