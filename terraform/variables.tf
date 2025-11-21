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
    condition     = can(regex("^[a-z]{2}-[a-z-]+-[0-9]$", var.aws_region))
    error_message = "AWS region must match pattern like us-west-2, eu-central-1"
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

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

# Network / Security Configuration Additions
variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP (80) ingress (default open)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = alltrue([for c in var.allowed_http_cidrs : can(cidrhost(c, 0))])
    error_message = "Each entry in allowed_http_cidrs must be a valid IPv4 CIDR block."
  }
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed for HTTPS (443) ingress (default open)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = alltrue([for c in var.allowed_https_cidrs : can(cidrhost(c, 0))])
    error_message = "Each entry in allowed_https_cidrs must be a valid IPv4 CIDR block."
  }
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH (22) ingress (default open)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = alltrue([for c in var.allowed_ssh_cidrs : can(cidrhost(c, 0))])
    error_message = "Each entry in allowed_ssh_cidrs must be a valid IPv4 CIDR block."
  }
}

variable "log_retention_days" {
  description = "Retention period (days) for log groups / flow logs"
  type        = number
  default     = 7
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 365
    error_message = "log_retention_days must be between 1 and 365."
  }
}

variable "enable_flow_logs" {
  description = "Enable creation of flow logs resources (AWS & enhanced GCP subnet logging)"
  type        = bool
  default     = true
}
