#!/bin/bash

# GCP Terraform CI/CD Automated Setup Script
# This script automates the setup of a GCP project for Terraform CI/CD
# Usage: ./setup-gcp-project.sh <GCP_PROJECT_ID> [OPTIONS]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_REGION="us-central1"
DEFAULT_ZONE="us-central1-a"
SA_NAME="github-actions-terraform"
SKIP_BILLING_CHECK=false
SKIP_API_ENABLE=false
CREATE_BUCKETS=true
CREATE_SA=true

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        echo "Installation guide: $2"
        exit 1
    fi
}

usage() {
    cat << EOF
GCP Terraform CI/CD Automated Setup Script

Usage: $0 <GCP_PROJECT_ID> [OPTIONS]

Required:
    GCP_PROJECT_ID          Your Google Cloud Project ID

Options:
    -r, --region REGION     GCP region (default: us-central1)
    -z, --zone ZONE         GCP zone (default: us-central1-a)
    --sa-name NAME          Service account name (default: github-actions-terraform)
    --skip-billing          Skip billing account check
    --skip-apis             Skip enabling APIs
    --no-buckets            Don't create GCS buckets
    --no-sa                 Don't create service account
    -h, --help              Show this help message

Examples:
    # Basic setup
    $0 my-gcp-project-123

    # Custom region and zone
    $0 my-gcp-project-123 -r europe-west1 -z europe-west1-b

    # Skip billing check (useful for existing projects)
    $0 my-gcp-project-123 --skip-billing

Environment Variables:
    BILLING_ACCOUNT_ID      Set to auto-link billing account

EOF
    exit 0
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
fi

GCP_PROJECT_ID="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
            GCP_REGION="$2"
            shift 2
            ;;
        -z|--zone)
            GCP_ZONE="$2"
            shift 2
            ;;
        --sa-name)
            SA_NAME="$2"
            shift 2
            ;;
        --skip-billing)
            SKIP_BILLING_CHECK=true
            shift
            ;;
        --skip-apis)
            SKIP_API_ENABLE=true
            shift
            ;;
        --no-buckets)
            CREATE_BUCKETS=false
            shift
            ;;
        --no-sa)
            CREATE_SA=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Use defaults if not provided
GCP_REGION="${GCP_REGION:-$DEFAULT_REGION}"
GCP_ZONE="${GCP_ZONE:-$DEFAULT_ZONE}"

# Validate project ID format
if ! [[ "$GCP_PROJECT_ID" =~ ^[a-z][a-z0-9-]{4,28}[a-z0-9]$ ]]; then
    print_error "Invalid GCP Project ID format"
    echo "Project ID must:"
    echo "  - Be 6-30 characters long"
    echo "  - Start with a lowercase letter"
    echo "  - Contain only lowercase letters, numbers, and hyphens"
    echo "  - End with a letter or number"
    exit 1
fi

# Main script
print_header "GCP Terraform CI/CD Setup"
echo "Project ID: $GCP_PROJECT_ID"
echo "Region: $GCP_REGION"
echo "Zone: $GCP_ZONE"
echo ""

# Check prerequisites
print_header "Checking Prerequisites"

check_command "gcloud" "https://cloud.google.com/sdk/docs/install"
check_command "terraform" "https://www.terraform.io/downloads"

print_success "All required commands are installed"

# Authenticate
print_header "Authentication Check"

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    print_warning "Not authenticated with gcloud"
    print_info "Running: gcloud auth login"
    gcloud auth login
fi

ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1)
print_success "Authenticated as: $ACTIVE_ACCOUNT"

# Set project
print_header "Configuring Project"

# Check if project exists
if gcloud projects describe "$GCP_PROJECT_ID" &>/dev/null; then
    print_info "Project $GCP_PROJECT_ID already exists"
else
    print_info "Creating new project: $GCP_PROJECT_ID"
    if gcloud projects create "$GCP_PROJECT_ID"; then
        print_success "Project created successfully"
    else
        print_error "Failed to create project. It might already exist or you may lack permissions."
        exit 1
    fi
fi

# Set active project
gcloud config set project "$GCP_PROJECT_ID"
print_success "Active project set to: $GCP_PROJECT_ID"

# Check/Enable billing
if [ "$SKIP_BILLING_CHECK" = false ]; then
    print_header "Billing Configuration"

    if gcloud billing projects describe "$GCP_PROJECT_ID" &>/dev/null; then
        BILLING_ACCOUNT=$(gcloud billing projects describe "$GCP_PROJECT_ID" --format="value(billingAccountName)")
        print_success "Billing already enabled: $BILLING_ACCOUNT"
    else
        print_warning "Billing is not enabled for this project"

        if [ -n "$BILLING_ACCOUNT_ID" ]; then
            print_info "Linking billing account: $BILLING_ACCOUNT_ID"
            gcloud billing projects link "$GCP_PROJECT_ID" \
                --billing-account="$BILLING_ACCOUNT_ID"
            print_success "Billing account linked"
        else
            print_warning "To enable billing, run:"
            echo "  gcloud billing projects link $GCP_PROJECT_ID --billing-account=BILLING_ACCOUNT_ID"
            echo ""
            echo "List billing accounts with:"
            echo "  gcloud billing accounts list"
            echo ""
            read -p "Continue without billing? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
else
    print_info "Skipping billing check (--skip-billing flag set)"
fi

# Enable APIs
if [ "$SKIP_API_ENABLE" = false ]; then
    print_header "Enabling Required APIs"

    REQUIRED_APIS=(
        "compute.googleapis.com"
        "cloudresourcemanager.googleapis.com"
        "iam.googleapis.com"
        "serviceusage.googleapis.com"
        "storage-api.googleapis.com"
        "storage.googleapis.com"
        "cloudbuild.googleapis.com"
        "logging.googleapis.com"
        "monitoring.googleapis.com"
    )

    print_info "Enabling ${#REQUIRED_APIS[@]} APIs..."

    for api in "${REQUIRED_APIS[@]}"; do
        if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
            echo "  ✓ $api (already enabled)"
        else
            echo "  ⏳ Enabling $api..."
            gcloud services enable "$api" --quiet
            echo "  ✅ $api enabled"
        fi
    done

    print_success "All required APIs enabled"
else
    print_info "Skipping API enablement (--skip-apis flag set)"
fi

# Create service account
if [ "$CREATE_SA" = true ]; then
    print_header "Creating Service Account"

    SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

    if gcloud iam service-accounts describe "$SA_EMAIL" &>/dev/null; then
        print_info "Service account already exists: $SA_EMAIL"
    else
        print_info "Creating service account: $SA_NAME"
        gcloud iam service-accounts create "$SA_NAME" \
            --display-name="GitHub Actions Terraform" \
            --description="Service account for GitHub Actions CI/CD"
        print_success "Service account created: $SA_EMAIL"
    fi

    # Grant IAM roles
    print_info "Granting IAM roles to service account..."

    ROLES=(
        "roles/editor"
        "roles/compute.admin"
        "roles/storage.admin"
        "roles/iam.serviceAccountUser"
    )

    for role in "${ROLES[@]}"; do
        echo "  ⏳ Granting $role..."
        gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" \
            --member="serviceAccount:${SA_EMAIL}" \
            --role="$role" \
            --quiet > /dev/null
        echo "  ✅ $role granted"
    done

    print_success "IAM roles configured"

    # Create service account key
    print_info "Creating service account key..."
    KEY_FILE="github-actions-key-${GCP_PROJECT_ID}.json"

    if [ -f "$KEY_FILE" ]; then
        print_warning "Key file already exists: $KEY_FILE"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping key creation"
        else
            gcloud iam service-accounts keys create "$KEY_FILE" \
                --iam-account="$SA_EMAIL"
            print_success "Service account key created: $KEY_FILE"
        fi
    else
        gcloud iam service-accounts keys create "$KEY_FILE" \
            --iam-account="$SA_EMAIL"
        print_success "Service account key created: $KEY_FILE"
    fi
else
    print_info "Skipping service account creation (--no-sa flag set)"
fi

# Create GCS buckets
if [ "$CREATE_BUCKETS" = true ]; then
    print_header "Creating GCS Buckets"

    BUCKETS=(
        "${GCP_PROJECT_ID}-terraform-state"
        "${GCP_PROJECT_ID}-build-logs"
        "${GCP_PROJECT_ID}-build-artifacts"
        "${GCP_PROJECT_ID}-build-cache"
    )

    for bucket in "${BUCKETS[@]}"; do
        if gsutil ls -b "gs://$bucket" &>/dev/null; then
            echo "  ✓ gs://$bucket (already exists)"
        else
            echo "  ⏳ Creating gs://$bucket..."
            gcloud storage buckets create "gs://$bucket" \
                --project="$GCP_PROJECT_ID" \
                --location="$GCP_REGION" \
                --uniform-bucket-level-access \
                --quiet
            echo "  ✅ gs://$bucket created"
        fi
    done

    # Enable versioning on terraform state bucket
    print_info "Enabling versioning on terraform state bucket..."
    gcloud storage buckets update "gs://${GCP_PROJECT_ID}-terraform-state" \
        --versioning \
        --quiet

    print_success "All buckets created and configured"
else
    print_info "Skipping bucket creation (--no-buckets flag set)"
fi

# Update Terraform configuration
print_header "Updating Terraform Configuration"

TERRAFORM_DIR="./terraform"
if [ -d "$TERRAFORM_DIR" ]; then
    # Create terraform.tfvars if it doesn't exist
    TFVARS_FILE="$TERRAFORM_DIR/terraform.tfvars"

    if [ ! -f "$TFVARS_FILE" ]; then
        print_info "Creating terraform.tfvars..."
        cat > "$TFVARS_FILE" << EOF
# GCP Configuration
gcp_project_id = "$GCP_PROJECT_ID"
gcp_region     = "$GCP_REGION"
gcp_zone       = "$GCP_ZONE"

# Enable GCP resources
enable_gcp = true
enable_aws = false

# Project Configuration
project_name = "$GCP_PROJECT_ID"
environment  = "dev"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Additional tags
tags = {
  ManagedBy  = "Terraform"
  Repository = "github-template"
}
EOF
        print_success "terraform.tfvars created"
    else
        print_info "terraform.tfvars already exists, skipping"
    fi

    # Update backend configuration in main.tf
    print_info "Updating Terraform backend configuration..."
    MAIN_TF="$TERRAFORM_DIR/main.tf"

    if [ -f "$MAIN_TF" ]; then
        # Check if backend is already configured
        if grep -q 'bucket = "' "$MAIN_TF"; then
            print_info "Backend already configured in main.tf"
        else
            print_info "Backend configuration needs manual update"
            print_warning "Update $MAIN_TF backend block with:"
            echo ""
            echo "  backend \"gcs\" {"
            echo "    bucket = \"$GCP_PROJECT_ID-terraform-state\""
            echo "    prefix = \"terraform/state\""
            echo "  }"
            echo ""
        fi
    fi

    print_success "Terraform configuration updated"
else
    print_warning "Terraform directory not found: $TERRAFORM_DIR"
fi

# Summary
print_header "Setup Complete! 🎉"

echo ""
echo "Next Steps:"
echo ""
echo "1. Add the following secrets to your GitHub repository:"
echo "   (Settings > Secrets and variables > Actions > New repository secret)"
echo ""
echo "   Secret Name: GCP_PROJECT_ID"
echo "   Value: $GCP_PROJECT_ID"
echo ""

if [ "$CREATE_SA" = true ] && [ -f "$KEY_FILE" ]; then
    echo "   Secret Name: GCP_SA_KEY"
    echo "   Value: (run this command to get base64-encoded key)"
    echo "   $ cat $KEY_FILE | base64 -w 0"
    echo ""
    echo "   Secret Name: TF_VAR_gcp_project_id"
    echo "   Value: $GCP_PROJECT_ID"
    echo ""
fi

echo "2. Test Terraform locally:"
echo "   $ cd terraform"
echo "   $ terraform init"
echo "   $ terraform validate"
echo "   $ terraform plan"
echo ""

echo "3. Push to GitHub to trigger CI/CD:"
echo "   $ git add ."
echo "   $ git commit -m \"feat: configure GCP project for CI/CD\""
echo "   $ git push origin main"
echo ""

if [ "$CREATE_SA" = true ] && [ -f "$KEY_FILE" ]; then
    print_warning "IMPORTANT: Delete the service account key file after adding to GitHub:"
    echo "   $ rm $KEY_FILE"
    echo ""
fi

echo "Documentation:"
echo "  - GCP Setup Guide: docs/GCP-SETUP.md"
echo "  - Cloud Build Integration: docs/CLOUD-BUILD.md"
echo ""

print_success "Setup completed successfully!"

# Save configuration
CONFIG_FILE=".gcp-setup-config"
cat > "$CONFIG_FILE" << EOF
# GCP Setup Configuration
# Generated on $(date)
GCP_PROJECT_ID=$GCP_PROJECT_ID
GCP_REGION=$GCP_REGION
GCP_ZONE=$GCP_ZONE
SA_NAME=$SA_NAME
SA_EMAIL=$SA_EMAIL
TF_STATE_BUCKET=${GCP_PROJECT_ID}-terraform-state
EOF

print_info "Configuration saved to: $CONFIG_FILE"
