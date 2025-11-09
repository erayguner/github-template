# Output values from Terraform configuration - Multi-Cloud Support

# Provider Status Outputs
output "providers_enabled" {
  description = "Map of enabled cloud providers"
  value       = local.providers_enabled
}

output "cloud_provider" {
  description = "Primary cloud provider configuration"
  value       = var.cloud_provider
}

# AWS Outputs (conditional)
output "aws_vpc_id" {
  description = "ID of the AWS VPC"
  value       = var.enable_aws ? aws_vpc.main[0].id : null
}

output "aws_vpc_cidr_block" {
  description = "CIDR block of the AWS VPC"
  value       = var.enable_aws ? aws_vpc.main[0].cidr_block : null
}

output "aws_public_subnet_ids" {
  description = "IDs of the AWS public subnets"
  value       = var.enable_aws ? aws_subnet.public[*].id : []
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = var.enable_aws ? data.aws_caller_identity.current[0].account_id : null
  sensitive   = true
}

output "aws_region" {
  description = "AWS region"
  value       = var.enable_aws ? var.aws_region : null
}

output "aws_log_group_arn" {
  description = "ARN of the AWS VPC flow logs CloudWatch log group (null if disabled)"
  value       = var.enable_aws && var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].arn : null
}

output "aws_logs_kms_key_arn" {
  description = "KMS key ARN used for CloudWatch Logs encryption (null if disabled)"
  value       = var.enable_aws && var.enable_flow_logs ? aws_kms_key.logs[0].arn : null
}

# GCP Outputs (conditional)
output "gcp_project_id" {
  description = "Google Cloud Project ID"
  value       = var.enable_gcp ? var.gcp_project_id : null
  sensitive   = true
}

output "gcp_network_id" {
  description = "ID of the GCP VPC network"
  value       = var.enable_gcp ? google_compute_network.main[0].id : null
}

output "gcp_network_self_link" {
  description = "Self link of the GCP VPC network"
  value       = var.enable_gcp ? google_compute_network.main[0].self_link : null
}

output "gcp_subnet_id" {
  description = "ID of the GCP public subnet"
  value       = var.enable_gcp ? google_compute_subnetwork.public[0].id : null
}

output "gcp_router_name" {
  description = "Name of the GCP router"
  value       = var.enable_gcp ? google_compute_router.main[0].name : null
}

output "gcp_nat_name" {
  description = "Name of the GCP NAT configuration"
  value       = var.enable_gcp ? google_compute_router_nat.main[0].name : null
}

output "gcp_private_subnet_id" {
  description = "ID of the GCP private subnet (flow logs)"
  value       = var.enable_gcp && var.enable_flow_logs ? google_compute_subnetwork.private[0].id : null
}

output "gcp_region" {
  description = "Google Cloud region"
  value       = var.enable_gcp ? var.gcp_region : null
}

output "gcp_zone" {
  description = "Google Cloud zone"
  value       = var.enable_gcp ? var.gcp_zone : null
}

# Common Outputs
output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}