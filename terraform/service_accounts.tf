# Service Account Configuration for GCP
# This file defines service accounts with least-privilege IAM permissions
#
# Best Practices:
# - Use dedicated service accounts per application/service
# - Follow principle of least privilege
# - Avoid using default service accounts
# - Rotate keys periodically (prefer Workload Identity when possible)

# =============================================================================
# Primary Application Service Account
# =============================================================================

resource "google_service_account" "app" {
  count = var.enable_gcp ? 1 : 0

  account_id   = "${var.project_name}-app-sa"
  display_name = "${var.project_name} Application Service Account"
  description  = "Service account for ${var.project_name} application workloads"
  project      = var.gcp_project_id
}

# IAM roles for application service account
resource "google_project_iam_member" "app_roles" {
  for_each = var.enable_gcp ? toset([
    "roles/logging.logWriter",          # Write logs to Cloud Logging
    "roles/monitoring.metricWriter",    # Write metrics to Cloud Monitoring
    "roles/cloudtrace.agent",           # Send traces to Cloud Trace
    "roles/secretmanager.secretAccessor", # Access secrets
  ]) : []

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.app[0].email}"
}

# =============================================================================
# CI/CD Service Account (for GitHub Actions / Cloud Build)
# =============================================================================

resource "google_service_account" "cicd" {
  count = var.enable_gcp ? 1 : 0

  account_id   = "${var.project_name}-cicd-sa"
  display_name = "${var.project_name} CI/CD Service Account"
  description  = "Service account for CI/CD pipelines and deployments"
  project      = var.gcp_project_id
}

# IAM roles for CI/CD service account
resource "google_project_iam_member" "cicd_roles" {
  for_each = var.enable_gcp ? toset([
    "roles/cloudbuild.builds.builder",       # Run Cloud Build
    "roles/run.admin",                        # Deploy to Cloud Run
    "roles/storage.admin",                    # Access storage buckets
    "roles/artifactregistry.writer",          # Push container images
    "roles/iam.serviceAccountUser",           # Act as service accounts
    "roles/secretmanager.secretAccessor",     # Access deployment secrets
  ]) : []

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd[0].email}"
}

# =============================================================================
# Terraform Service Account (for infrastructure management)
# =============================================================================

resource "google_service_account" "terraform" {
  count = var.enable_gcp ? 1 : 0

  account_id   = "${var.project_name}-terraform-sa"
  display_name = "${var.project_name} Terraform Service Account"
  description  = "Service account for Terraform infrastructure management"
  project      = var.gcp_project_id
}

# IAM roles for Terraform service account
# Note: These are broad permissions - restrict further based on your needs
resource "google_project_iam_member" "terraform_roles" {
  for_each = var.enable_gcp ? toset([
    "roles/compute.admin",            # Manage compute resources
    "roles/storage.admin",            # Manage storage buckets
    "roles/iam.serviceAccountAdmin",  # Manage service accounts
    "roles/resourcemanager.projectIamAdmin", # Manage project IAM
    "roles/secretmanager.admin",      # Manage secrets
    "roles/cloudsql.admin",           # Manage Cloud SQL (if used)
    "roles/run.admin",                # Manage Cloud Run
    "roles/cloudbuild.builds.editor", # Manage Cloud Build triggers
  ]) : []

  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform[0].email}"
}

# =============================================================================
# Workload Identity Federation for GitHub Actions
# =============================================================================

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github" {
  count = var.enable_gcp ? 1 : 0

  workload_identity_pool_id = "${var.project_name}-github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions OIDC authentication"
  project                   = var.gcp_project_id
}

# Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "github" {
  count = var.enable_gcp ? 1 : 0

  workload_identity_pool_id          = google_iam_workload_identity_pool.github[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC provider for GitHub Actions"
  project                            = var.gcp_project_id

  # GitHub OIDC configuration
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Attribute mapping from GitHub token
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Restrict to specific repository (update with your repo)
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"
}

# Allow CI/CD service account to be impersonated via Workload Identity
resource "google_service_account_iam_member" "cicd_workload_identity" {
  count = var.enable_gcp ? 1 : 0

  service_account_id = google_service_account.cicd[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[0].name}/attribute.repository/${var.github_org}/${var.github_repo}"
}

# =============================================================================
# Outputs for Service Accounts
# =============================================================================

output "app_service_account_email" {
  description = "Email of the application service account"
  value       = var.enable_gcp ? google_service_account.app[0].email : null
}

output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = var.enable_gcp ? google_service_account.cicd[0].email : null
}

output "terraform_service_account_email" {
  description = "Email of the Terraform service account"
  value       = var.enable_gcp ? google_service_account.terraform[0].email : null
}

output "workload_identity_provider" {
  description = "Workload Identity Provider resource name for GitHub Actions"
  value       = var.enable_gcp ? google_iam_workload_identity_pool_provider.github[0].name : null
}

output "workload_identity_pool" {
  description = "Workload Identity Pool resource name"
  value       = var.enable_gcp ? google_iam_workload_identity_pool.github[0].name : null
}
