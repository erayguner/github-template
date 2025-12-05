<div align="center">

<!-- Banner Image -->
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:4285F4,100:34A853&height=200&section=header&text=GCP%20Terraform%20Template&fontSize=40&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=Production-Ready%20Infrastructure%20as%20Code&descAlignY=55&descSize=18">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:4285F4,100:34A853&height=200&section=header&text=GCP%20Terraform%20Template&fontSize=40&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=Production-Ready%20Infrastructure%20as%20Code&descAlignY=55&descSize=18" alt="GCP Terraform Template Banner"/>
</picture>

<!-- Badges Row 1: Status -->
<p>
  <a href="https://github.com/erayguner/github-template/actions/workflows/ci.yml">
    <img src="https://github.com/erayguner/github-template/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI/CD Pipeline"/>
  </a>
  <a href="https://github.com/erayguner/github-template/actions/workflows/security.yml">
    <img src="https://github.com/erayguner/github-template/actions/workflows/security.yml/badge.svg?branch=main" alt="Security Analysis"/>
  </a>
  <a href="https://github.com/erayguner/github-template/actions/workflows/mega-linter.yml">
    <img src="https://github.com/erayguner/github-template/actions/workflows/mega-linter.yml/badge.svg?branch=main" alt="MegaLinter"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
</p>

<!-- Badges Row 2: Technologies -->
<p>
  <img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Google Cloud Platform"/>
  <img src="https://img.shields.io/badge/Terraform-1.10+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform 1.10+"/>
  <img src="https://img.shields.io/badge/Cloud_Build-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Cloud Build"/>
  <img src="https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.11+"/>
</p>

<!-- Badges Row 3: Security -->
<p>
  <img src="https://img.shields.io/badge/Security-tfsec-2B9348?logo=terraform&logoColor=white" alt="tfsec"/>
  <img src="https://img.shields.io/badge/Security-checkov-2B9348?logo=checkov&logoColor=white" alt="checkov"/>
  <img src="https://img.shields.io/badge/Security-gitleaks-2B9348?logo=git&logoColor=white" alt="gitleaks"/>
  <img src="https://img.shields.io/badge/Security-CodeQL-2B9348?logo=github&logoColor=white" alt="CodeQL"/>
  <img src="https://img.shields.io/badge/MegaLinter-Enabled-brightgreen?logo=mega&logoColor=white" alt="MegaLinter"/>
</p>

<!-- Navigation -->
<p>
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-features">Features</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-documentation">Documentation</a> •
  <a href="#-contributing">Contributing</a>
</p>

</div>

---

## What is this?

A **production-ready GitHub template** for deploying infrastructure to **Google Cloud Platform** using Terraform. Perfect for developers and teams onboarding their first project to GCP with enterprise-grade CI/CD, security scanning, and best practices baked in.

```bash
# Get started in under 5 minutes!
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID
```

---

## Features

| Category | Features |
|----------|----------|
| **Infrastructure** | Terraform 1.10+, Multi-cloud support (AWS/GCP), Remote state with GCS backend |
| **CI/CD** | GitHub Actions, Google Cloud Build, Automated deployments, Environment promotion |
| **Security** | tfsec, checkov, gitleaks, CodeQL, TruffleHog, detect-secrets |
| **Code Quality** | MegaLinter (70+ linters), Ruff, shellcheck, yamllint, actionlint |
| **DevEx** | Pre-commit hooks, Makefile targets, UV package manager, Hot-reload workflows |
| **Documentation** | Architecture diagrams, API reference, Runbooks, Troubleshooting guides |

---

## Quick Start

### Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Python | 3.11+ | [Download](https://www.python.org/downloads/) |
| Terraform | 1.10+ | [Download](https://www.terraform.io/downloads) |
| UV | Latest | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| gcloud CLI | Latest | [Download](https://cloud.google.com/sdk/docs/install) |
| pre-commit | Latest | `pip install pre-commit` |

### Option 1: Use as GitHub Template (Recommended)

1. Click **"Use this template"** button above
2. Clone your new repository
3. Run the setup script:

```bash
# Set up GCP project with all required resources
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID

# Install development dependencies
make setup

# Verify everything works
make validate-all
```

### Option 2: Manual Setup

```bash
# Clone the repository
git clone https://github.com/erayguner/github-template.git my-gcp-project
cd my-gcp-project

# Set up Python environment
cd python && uv sync --group dev && cd ..

# Set up Terraform
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project settings
terraform init
terraform validate
cd ..

# Install pre-commit hooks
pre-commit install

# Verify setup
make validate-all
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GitHub Repository                               │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │   Pre-commit    │───▶│  GitHub Actions │───▶│  Cloud Build    │         │
│  │     Hooks       │    │    CI/CD        │    │   Deployment    │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│         │                       │                      │                    │
│         ▼                       ▼                      ▼                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Security Scanning Pipeline                        │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │ tfsec   │ │ checkov │ │gitleaks │ │ CodeQL  │ │TruffleHog│       │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Google Cloud Platform                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐               │
│  │   Cloud Run   │    │  Cloud SQL    │    │ Cloud Storage │               │
│  │   Services    │    │   Databases   │    │    Buckets    │               │
│  └───────────────┘    └───────────────┘    └───────────────┘               │
│         │                    │                     │                        │
│         └────────────────────┼─────────────────────┘                        │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         VPC Network                                  │   │
│  │  ┌─────────────────┐         ┌─────────────────┐                    │   │
│  │  │  Public Subnet  │         │  Private Subnet │                    │   │
│  │  │  (NAT Gateway)  │         │   (Internal)    │                    │   │
│  │  └─────────────────┘         └─────────────────┘                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Security & IAM                                    │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐       │   │
│  │  │  Service   │ │  Workload  │ │   Secret   │ │    IAM     │       │   │
│  │  │  Accounts  │ │  Identity  │ │   Manager  │ │   Roles    │       │   │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
.
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                 # Main CI/CD pipeline
│   │   ├── cloud-build-deploy.yml # GCP Cloud Build deployment
│   │   ├── security.yml           # Security scanning
│   │   └── mega-linter.yml        # Code quality linting
│   ├── ISSUE_TEMPLATE/            # Issue templates
│   └── PULL_REQUEST_TEMPLATE.md   # PR template
├── terraform/
│   ├── main.tf                    # Main configuration
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values
│   ├── gcp.tf                     # GCP resources
│   ├── aws.tf                     # AWS resources (optional)
│   ├── backend.tf                 # State backend config
│   ├── service_accounts.tf        # IAM service accounts
│   ├── providers.tf               # Provider configuration
│   └── versions.tf                # Version constraints
├── python/
│   ├── src/                       # Python source code
│   ├── tests/                     # Test files
│   ├── pyproject.toml             # Project configuration
│   └── requirements.txt           # Dependencies
├── scripts/
│   └── setup-gcp-project.sh       # GCP project setup script
├── docs/
│   ├── QUICK-START-GCP.md         # 5-minute GCP setup
│   ├── GCP-SETUP.md               # Comprehensive GCP guide
│   ├── CLOUD-BUILD.md             # Cloud Build integration
│   ├── GCP-APIS-REFERENCE.md      # API reference
│   └── multi-cloud.md             # Multi-cloud setup
├── cloudbuild.yaml                # Cloud Build configuration
├── .pre-commit-config.yaml        # Pre-commit hooks (security-focused)
├── .tflint.hcl                    # TFLint configuration
├── .yamllint.yml                  # YAML linting rules
├── Makefile                       # Development commands
└── README.md                      # This file
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Quick Start (5 min)](docs/QUICK-START-GCP.md) | Get your first deployment running |
| [Full GCP Setup](docs/GCP-SETUP.md) | Comprehensive GCP configuration guide |
| [Cloud Build](docs/CLOUD-BUILD.md) | Cloud Build integration and deployment |
| [API Reference](docs/GCP-APIS-REFERENCE.md) | Required GCP APIs and permissions |
| [Multi-Cloud](docs/multi-cloud.md) | AWS + GCP hybrid deployments |
| [Template Usage](docs/TEMPLATE-USAGE.md) | How to customize this template |
| [Contributing](CONTRIBUTING.md) | Contribution guidelines |
| [Security](SECURITY.md) | Security policies and reporting |

---

## Development Commands

```bash
# Full setup (Python + Terraform + hooks)
make setup

# Run all validations
make validate-all

# Individual validations
make lint              # Run all linters
make test              # Run all tests
make security          # Run security scans

# Terraform commands
make terraform-init    # Initialize Terraform
make terraform-plan    # Plan infrastructure changes
make terraform-apply   # Apply infrastructure changes

# Python commands
make python-lint       # Lint Python code
make python-test       # Run Python tests
make python-format     # Format Python code

# Pre-commit
make pre-commit        # Run all pre-commit hooks

# Cleanup
make clean             # Clean all generated files
```

---

## Security

This template implements multiple layers of security scanning:

| Tool | Purpose | When it runs |
|------|---------|--------------|
| **tfsec** | Terraform security scanner | Pre-commit, CI |
| **checkov** | Infrastructure as Code analysis | Pre-commit, CI |
| **gitleaks** | Secret detection in git history | Pre-commit, CI |
| **detect-secrets** | Baseline secret scanning | Pre-commit |
| **TruffleHog** | Deep secret scanning | CI |
| **CodeQL** | SAST for Python | CI |
| **Bandit** | Python security linting | CI |
| **Dependabot** | Dependency vulnerability alerts | Automated |

See [SECURITY.md](SECURITY.md) for our security policy and vulnerability reporting.

---

## CI/CD Pipeline

The pipeline runs automatically on every push and pull request:

```
┌────────────────┐   ┌────────────────┐   ┌────────────────┐
│  Pre-commit    │──▶│ GitHub Actions │──▶│  Cloud Build   │
│    Hooks       │   │    CI/CD       │   │   Deployment   │
└────────────────┘   └────────────────┘   └────────────────┘
       │                    │                     │
       ▼                    ▼                     ▼
┌────────────────┐   ┌────────────────┐   ┌────────────────┐
│ Local checks:  │   │ Pipeline jobs: │   │ Deploy stages: │
│ • Formatting   │   │ • Lint & Test  │   │ • Build image  │
│ • Linting      │   │ • Security     │   │ • Push to AR   │
│ • Secrets      │   │ • Terraform    │   │ • Deploy CR    │
│ • Terraform    │   │ • CodeQL       │   │ • Smoke tests  │
└────────────────┘   └────────────────┘   └────────────────┘
```

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run validations (`make validate-all`)
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

<!-- Footer Banner -->
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:34A853,100:4285F4&height=100&section=footer">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:34A853,100:4285F4&height=100&section=footer" alt="Footer"/>
</picture>

<p>
  <strong>Made with Terraform and Google Cloud</strong>
</p>

<p>
  <a href="https://github.com/erayguner/github-template/stargazers">
    <img src="https://img.shields.io/github/stars/erayguner/github-template?style=social" alt="Stars"/>
  </a>
  <a href="https://github.com/erayguner/github-template/network/members">
    <img src="https://img.shields.io/github/forks/erayguner/github-template?style=social" alt="Forks"/>
  </a>
</p>

</div>
