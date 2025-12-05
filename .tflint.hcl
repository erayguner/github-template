# TFLint Configuration
# Documentation: https://github.com/terraform-linters/tflint
#
# Install plugins:
#   tflint --init

config {
  # Enable module inspection (call_module_type replaces deprecated 'module' in v0.54.0+)
  # Options: "all", "local", "none"
  call_module_type = "local"

  # Force mode - returns non-zero exit code on any issue
  force = false
}

# =============================================================================
# Core Rules
# =============================================================================

# Disallow deprecated (0.11-style) interpolation
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Disallow legacy dot index syntax
rule "terraform_deprecated_index" {
  enabled = true
}

# Disallow variables, data sources, and locals that are declared but never used
# Disabled: Template repositories intentionally include unused example variables
# that users can customize for their specific use cases
rule "terraform_unused_declarations" {
  enabled = false
}

# Disallow // comments in favor of #
rule "terraform_comment_syntax" {
  enabled = true
}

# Disallow variable declarations without description
rule "terraform_documented_variables" {
  enabled = true
}

# Disallow output declarations without description
rule "terraform_documented_outputs" {
  enabled = true
}

# Enforce naming conventions
rule "terraform_naming_convention" {
  enabled = true

  # Naming convention format options: snake_case, mixed_snake_case, none
  format = "snake_case"

  # Custom name patterns for specific block types
  custom_formats = {}
}

# Ensure that a module uses specific versions
rule "terraform_module_pinned_source" {
  enabled = true

  # Local modules don't need version pinning
  style = "flexible"

  # Default branches to avoid
  default_branches = ["main", "master"]
}

# Disallow specifying a git or mercurial repository as a module source without pinning to a version
rule "terraform_module_version" {
  enabled = true
  exact   = false
}

# Require specific Terraform version
rule "terraform_required_version" {
  enabled = true
}

# Require specific provider versions
rule "terraform_required_providers" {
  enabled = true
}

# Recommend using type defaults for optional variables
rule "terraform_typed_variables" {
  enabled = true
}

# Standard file names
rule "terraform_standard_module_structure" {
  enabled = true
}

# Workspace management
rule "terraform_workspace_remote" {
  enabled = true
}

# =============================================================================
# Google Cloud Plugin
# =============================================================================

plugin "google" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# =============================================================================
# AWS Plugin
# =============================================================================

plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  # Enable deep checking for AWS resources
  deep_check = false
}

# =============================================================================
# Additional Rules (AWS-specific)
# =============================================================================

# Ensure aws_instance has valid instance types
rule "aws_instance_invalid_type" {
  enabled = true
}

# Ensure aws_db_instance uses valid instance classes
rule "aws_db_instance_invalid_type" {
  enabled = true
}

# Ensure EBS volumes are encrypted
rule "aws_ebs_volume_invalid_type" {
  enabled = true
}

# =============================================================================
# Additional Rules (GCP-specific)
# =============================================================================

# Note: GCP-specific rules are automatically enabled by the google plugin.
# Only add rules here if you need to customize their behavior.
# The plugin includes rules for compute instances, Cloud SQL, GKE, etc.
# See: https://github.com/terraform-linters/tflint-ruleset-google/blob/main/docs/rules/README.md
