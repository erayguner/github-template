<div align="center">

# 🚀 Multi-Language Repository Template

<p align="center">
  <strong>Production-ready GitHub template with automated CI/CD, security scanning, and modern development workflows</strong>
</p>

<p align="center">
  <a href="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml">
    <img src="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml/badge.svg" alt="CI/CD Pipeline"/>
  </a>
  <a href="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml">
    <img src="https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml/badge.svg" alt="Security Analysis"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.9+-3776AB?logo=python&logoColor=white" alt="Python 3.9+"/>
  <img src="https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform&logoColor=white" alt="Terraform 1.6+"/>
  <img src="https://img.shields.io/badge/UV-Package_Manager-DE5FE9?logo=astral&logoColor=white" alt="UV"/>
  <img src="https://img.shields.io/badge/Ruff-Linter-D7FF64?logo=ruff&logoColor=black" alt="Ruff"/>
  <img src="https://img.shields.io/badge/CodeQL-Security-2B9348?logo=github&logoColor=white" alt="CodeQL"/>
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-supported-technologies">Technologies</a> •
  <a href="#license">License</a>
</p>

</div>

---

## 📖 Overview

Production-ready GitHub template for Terraform and Python projects with automated CI/CD, security scanning, and modern development workflows.

## ✨ Key Features

- 🛡️ **Security-First**: CodeQL, GitLeaks, Dependabot
- ⚡ **Fast Tooling**: UV package manager, Ruff linting  
- 🌩️ **Multi-Cloud**: AWS, GCP, or hybrid support
- 🔄 **Zero-Config**: Automatic project detection

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
- **Python 3.9+** - [Download here](https://www.python.org/downloads/)
- **UV** - Ultra-fast Python package manager: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Terraform 1.6+** - [Download here](https://www.terraform.io/downloads)
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

- 📖 Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- 🔒 Review [SECURITY.md](SECURITY.md) for security policies
- 📚 Check [docs/](docs/) for detailed documentation
- 🏗️ See [DEPLOYMENT.md](DEPLOYMENT.md) for deployment instructions

## License

MIT License - see [LICENSE](LICENSE) for details.