<div align="center">

# 🚀 GCP Terraform CI/CD Template

<p align="center">
  <strong>Production-ready GitHub template for GCP infrastructure with automated CI/CD, security scanning, and one-command setup</strong>
</p>

<p align="center">
  <a href="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml">
    <img src="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml/badge.svg" alt="CI/CD Pipeline"/>
  </a>
  <a href="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml">
    <img src="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml/badge.svg" alt="Security Analysis"/>
  </a>
  <a href="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/mega-linter.yml">
    <img src="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/mega-linter.yml/badge.svg" alt="MegaLinter"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Google_Cloud-4285F4?logo=google-cloud&logoColor=white" alt="Google Cloud Platform"/>
  <img src="https://img.shields.io/badge/Terraform-1.10+-623CE4?logo=terraform&logoColor=white" alt="Terraform 1.10+"/>
  <img src="https://img.shields.io/badge/Python-3.11+-3776AB?logo=python&logoColor=white" alt="Python 3.11+"/>
  <img src="https://img.shields.io/badge/UV-Package_Manager-DE5FE9?logo=astral&logoColor=white" alt="UV"/>
  <img src="https://img.shields.io/badge/Ruff-Linter-D7FF64?logo=ruff&logoColor=black" alt="Ruff"/>
  <img src="https://img.shields.io/badge/MegaLinter-Enabled-brightgreen?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEyIDJMMyA3djZjMCA1LjU1IDMuODQgMTAuNzQgOSAxMiA1LjE2LTEuMjYgOS02LjQ1IDktMTJWN2wtOS01em0tMiAxNWwtNS01IDEuNDEtMS40MUwxMCAxNC4xN2w3LjU5LTcuNTlMMTkgOGwtOSA5eiIvPjwvc3ZnPg==" alt="MegaLinter"/>
  <img src="https://img.shields.io/badge/Security-tfsec_checkov-2B9348?logo=github&logoColor=white" alt="Security Scanning"/>
</p>

<p align="center">
  <a href="#-gcp-quick-start-5-minutes">GCP Quick Start</a> •
  <a href="#-quick-start">Full Setup</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-supported-technologies">Technologies</a>
</p>

</div>

---

## 📖 Overview

Production-ready GitHub template for Terraform and Python projects with automated CI/CD, security scanning, and modern development workflows. **Perfect for starting new GCP infrastructure projects** with a single command!

## 🎯 GCP Quick Start (5 Minutes)

Get your GCP Terraform CI/CD pipeline running with just your project ID:

```bash
# One command to set up everything!
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID
```

This automatically configures:
- ✅ GCP project with required APIs
- ✅ Service account with proper IAM roles
- ✅ GCS buckets for Terraform state, logs, and artifacts
- ✅ Terraform backend configuration
- ✅ GitHub Actions CI/CD pipeline

**📚 Detailed Guides:**
- [GCP Quick Start (5 min)](docs/QUICK-START-GCP.md) - Get started immediately
- [Full GCP Setup Guide](docs/GCP-SETUP.md) - Comprehensive documentation
- [Cloud Build Integration](docs/CLOUD-BUILD.md) - Alternative to GitHub Actions

## ✨ Key Features

- 🛡️ **Security-First**: CodeQL, tfsec, checkov, GitLeaks, Dependabot
- ⚡ **Fast Tooling**: UV package manager, Ruff linting, MegaLinter
- 🌩️ **Multi-Cloud**: AWS, GCP, or hybrid support
- 🔄 **Zero-Config**: Automatic project detection
- 📦 **Automated Setup**: One-command GCP project initialization
- 🔒 **Production-Ready**: Security scanning, state management, and best practices
- 🔍 **Comprehensive Linting**: MegaLinter runs 70+ linters for code quality

## 📁 Repository Structure

```
├── .github/
│   ├── workflows/
│   │   └── ci.yml              # Unified CI/CD pipeline
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   └── PULL_REQUEST_TEMPLATE/  # PR templates
├── terraform/                  # Terraform configurations
├── python/                     # Python source code
├── docs/                       # Documentation
├── scripts/                    # Utility scripts
├── .pre-commit-config.yaml     # Pre-commit configuration
├── .gitignore                  # Language-specific gitignore
└── README.md                   # Project documentation
```

## 🛠 Supported Technologies

**Terraform**: Multi-cloud (AWS/GCP), security scanning, auto-documentation  
**Python**: UV package manager, Ruff linting, comprehensive testing

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:
- **Python 3.11+** - [Download here](https://www.python.org/downloads/)
- **UV** - Ultra-fast Python package manager: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Terraform 1.10+** - [Download here](https://www.terraform.io/downloads)
- **Git** - [Download here](https://git-scm.com/downloads)

### Setup Steps

#### 1. Create from Template
Use this repository as a GitHub template or clone it:
```bash
git clone https://github.com/YOUR_USERNAME/github-template.git
cd github-template
```

#### 2. Python Setup
```bash
# Navigate to Python directory
cd python

# Create virtual environment and install dependencies
uv sync --group dev

# Activate the virtual environment (optional but recommended)
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Run tests to verify setup
uv run pytest

# Run linting
uv run ruff check .
```

#### 3. Terraform Setup
```bash
# Navigate to Terraform directory
cd terraform

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan your infrastructure (review before applying)
terraform plan

# Apply infrastructure (when ready)
terraform apply
```

#### 4. Git Hooks Setup
```bash
# Return to project root
cd ..

# Install pre-commit hooks
pre-commit install

# Test pre-commit hooks (optional)
pre-commit run --all-files
```

### Verify Installation

Run these commands to verify everything is working:

```bash
# Python checks
cd python && uv run pytest && cd ..

# Terraform checks
cd terraform && terraform validate && cd ..

# Pre-commit check
pre-commit run --all-files
```

### Next Steps

#### For GCP Users:
- 🚀 **Start Here**: [GCP Quick Start Guide](docs/QUICK-START-GCP.md) - 5-minute setup
- 📖 **Full Guide**: [GCP Setup Documentation](docs/GCP-SETUP.md) - Comprehensive setup
- 🔧 **Advanced**: [Cloud Build Integration](docs/CLOUD-BUILD.md) - GCP-native CI/CD
- 🌐 **Multi-Cloud**: [Multi-Cloud Setup](docs/multi-cloud.md) - AWS + GCP

#### General Documentation:
- 📖 Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- 🔒 Review [SECURITY.md](SECURITY.md) for security policies
- 📚 Check [docs/](docs/) for detailed documentation

## License

MIT License - see [LICENSE](LICENSE) for details.
