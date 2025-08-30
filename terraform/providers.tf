# Provider configuration strategy for optional multi-cloud support
# 
# This file demonstrates the recommended approach for optional provider usage
# Since providers cannot use count/for_each, we configure them but use
# conditional resources to control what actually gets created.

# Alternative approach: Use provider aliases for different configurations
# Uncomment these if you want explicit provider control

# provider "aws" {
#   alias  = "primary"
#   region = var.aws_region
# }

# provider "google" {
#   alias   = "primary" 
#   project = var.gcp_project_id
#   region  = var.gcp_region
# }

# For users who want to completely disable a provider, they can:
# 1. Comment out the provider block in main.tf
# 2. Remove provider from versions.tf required_providers
# 3. Remove the corresponding .tf files (aws.tf or gcp.tf)

# This approach maintains backward compatibility while allowing flexible usage