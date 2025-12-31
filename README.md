<div align="center">

<!-- Banner Image -->
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:4285F4,100:FF9900&height=200&section=header&text=Multi-Cloud%20Terraform%20Template&fontSize=36&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=Production-Ready%20Infrastructure%20as%20Code%20for%20AWS%20%26%20GCP&descAlignY=55&descSize=16">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:4285F4,100:FF9900&height=200&section=header&text=Multi-Cloud%20Terraform%20Template&fontSize=36&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=Production-Ready%20Infrastructure%20as%20Code%20for%20AWS%20%26%20GCP&descAlignY=55&descSize=16" alt="Multi-Cloud Terraform Template Banner"/>
</picture>

<!-- Badges Row 1: Status -->
<p>
  <a href="https://github.com/erayguner/github-template/actions/workflows/ci.yml">
    <img src="https://github.com/erayguner/github-template/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI/CD Pipeline"/>
  </a>
  <a href="https://github.com/erayguner/github-template/actions/workflows/security.yml">
    <img src="https://github.com/erayguner/github-template/actions/workflows/security.yml/badge.svg?branch=main" alt="Security Analysis"/>
  </a>
  <a href="https://github.com/erayguner/github-template/actions/workflows/terraform.yml">
    <img src="https://github.com/erayguner/github-template/actions/workflows/terraform.yml/badge.svg?branch=main" alt="Terraform"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
</p>

<!-- Badges Row 2: Technologies -->
<p>
  <img src="https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="Amazon Web Services"/>
  <img src="https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white" alt="Google Cloud Platform"/>
  <img src="https://img.shields.io/badge/Terraform-1.10+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform 1.10+"/>
  <img src="https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.11+"/>
</p>

<!-- Badges Row 3: Security -->
<p>
  <img src="https://img.shields.io/badge/Security-tfsec-2B9348?logo=terraform&logoColor=white" alt="tfsec"/>
  <img src="https://img.shields.io/badge/Security-checkov-2B9348?logo=checkov&logoColor=white" alt="checkov"/>
  <img src="https://img.shields.io/badge/Security-gitleaks-2B9348?logo=git&logoColor=white" alt="gitleaks"/>
  <img src="https://img.shields.io/badge/Security-CodeQL-2B9348?logo=github&logoColor=white" alt="CodeQL"/>
  <img src="https://img.shields.io/badge/Security-TruffleHog-2B9348?logo=git&logoColor=white" alt="TruffleHog"/>
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

A **production-ready GitHub template** for deploying infrastructure to **AWS**, **Google Cloud Platform**, or **both** using Terraform. Perfect for developers and teams who need enterprise-grade CI/CD, comprehensive security scanning, and infrastructure best practices out of the box.

**Key Highlights:**
- **Multi-Cloud**: Deploy to AWS, GCP, or both simultaneously
- **13 CI/CD Workflows**: Automated testing, security scanning, and deployment
- **8+ Security Tools**: tfsec, Checkov, Gitleaks, TruffleHog, Bandit, CodeQL, and more
- **AI-Powered Auto-Fix**: Claude integration to automatically fix CI failures

```bash
# GCP Quick Start (5 minutes)
./scripts/setup-gcp-project.sh YOUR_GCP_PROJECT_ID
```

---

## Features

| Category | Features |
|----------|----------|
| **Infrastructure** | Terraform 1.10+, Multi-cloud (AWS & GCP), Remote state backends, Workload Identity Federation |
| **CI/CD** | 13 GitHub Actions workflows, Google Cloud Build integration, Automated deployments |
| **Security** | tfsec, Checkov, Gitleaks, TruffleHog, Bandit, CodeQL, Trivy, detect-secrets |
| **Code Quality** | Ruff (Python), TFLint, shellcheck, yamllint, actionlint, Hadolint |
| **DevEx** | Pre-commit hooks, Makefile targets, UV package manager, Claude AI auto-fix |
| **Documentation** | Setup guides, Architecture diagrams, Multi-cloud guides, API reference |

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
│  │   Pre-commit    │───▶│  GitHub Actions │───▶│    Deployment   │         │
│  │     Hooks       │    │  (13 workflows) │    │  (Cloud Build)  │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│         │                       │                      │                    │
│         ▼                       ▼                      ▼                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Security Scanning Pipeline                        │   │
│  │  ┌───────┐ ┌─────────┐ ┌─────────┐ ┌────────┐ ┌───────────┐ ┌─────┐│   │
│  │  │ tfsec │ │ checkov │ │gitleaks │ │ CodeQL │ │TruffleHog │ │Trivy││   │
│  │  └───────┘ └─────────┘ └─────────┘ └────────┘ └───────────┘ └─────┘│   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                          │                       │
            ┌─────────────┘                       └─────────────┐
            ▼                                                   ▼
┌───────────────────────────────────┐     ┌───────────────────────────────────┐
│      Amazon Web Services (AWS)    │     │    Google Cloud Platform (GCP)    │
├───────────────────────────────────┤     ├───────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐       │     │  ┌───────────┐  ┌─────────────┐   │
│  │   VPC    │  │   IAM    │       │     │  │ Cloud Run │  │Cloud Storage│   │
│  │ Subnets  │  │  Roles   │       │     │  │ Services  │  │   Buckets   │   │
│  └──────────┘  └──────────┘       │     │  └───────────┘  └─────────────┘   │
│  ┌──────────┐  ┌──────────┐       │     │  ┌───────────┐  ┌─────────────┐   │
│  │   KMS    │  │   ALB    │       │     │  │    VPC    │  │   Firewall  │   │
│  │Encryption│  │  (Load)  │       │     │  │  Network  │  │    Rules    │   │
│  └──────────┘  └──────────┘       │     │  └───────────┘  └─────────────┘   │
│  ┌──────────────────────────┐     │     │  ┌───────────────────────────┐    │
│  │     Security Groups      │     │     │  │   Workload Identity Fed   │    │
│  │     VPC Flow Logs        │     │     │  │   Service Accounts        │    │
│  └──────────────────────────┘     │     │  └───────────────────────────┘    │
└───────────────────────────────────┘     └───────────────────────────────────┘
```

**Multi-Cloud Options:**
- **AWS Only**: `enable_aws = true, enable_gcp = false`
- **GCP Only**: `enable_aws = false, enable_gcp = true`
- **Multi-Cloud**: `enable_aws = true, enable_gcp = true`

---

## Repository Structure

```
.
├── .github/
│   ├── workflows/                 # 13 CI/CD workflows
│   │   ├── ci.yml                 # Main CI/CD pipeline (shell linting)
│   │   ├── python.yml             # Python: Ruff, mypy, pytest
│   │   ├── terraform.yml          # Terraform: fmt, validate, TFLint, tfsec, Checkov
│   │   ├── security.yml           # Security: Gitleaks, Trivy, TruffleHog, Bandit
│   │   ├── dependencies.yml       # Dependencies: SBOM, pip-audit, Grype
│   │   ├── yaml.yml               # YAML linting
│   │   ├── dockerfile.yml         # Docker: Hadolint
│   │   ├── actionlint.yml         # GitHub Actions validation
│   │   ├── auto-fix.yml           # Claude AI auto-fix for CI failures
│   │   └── cloud-build-deploy.yml # GCP Cloud Build deployment
│   ├── ISSUE_TEMPLATE/            # Bug & feature request templates
│   └── PULL_REQUEST_TEMPLATE.md   # PR template
├── terraform/
│   ├── main.tf                    # Providers & locals
│   ├── gcp.tf                     # GCP resources (VPC, Firewall, NAT)
│   ├── aws.tf                     # AWS resources (VPC, IAM, KMS, ALB)
│   ├── variables.tf               # Input variables with validation
│   ├── outputs.tf                 # Output values
│   ├── service_accounts.tf        # GCP service accounts & IAM
│   ├── backend.tf                 # State backend configuration
│   └── versions.tf                # Version constraints
├── python/
│   ├── src/                       # Python source code
│   ├── tests/                     # Test files
│   └── pyproject.toml             # Project config with Ruff, mypy, pytest
├── scripts/
│   └── setup-gcp-project.sh       # GCP one-command setup script
├── docs/
│   ├── QUICK-START-GCP.md         # 5-minute GCP setup
│   ├── GCP-SETUP.md               # Comprehensive GCP guide
│   ├── TEMPLATE-USAGE.md          # How to customize this template
│   ├── multi-cloud.md             # AWS + GCP hybrid setup
│   └── ci-architecture.md         # CI/CD pipeline architecture
├── cloudbuild.yaml                # GCP Cloud Build configuration
├── Dockerfile                     # Multi-stage Python container
├── Makefile                       # Development commands
├── .pre-commit-config.yaml        # Pre-commit hooks
├── .tflint.hcl                    # TFLint configuration
└── README.md                      # This file
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Quick Start (5 min)](docs/QUICK-START-GCP.md) | Get your first deployment running |
| [Full GCP Setup](docs/GCP-SETUP.md) | Comprehensive GCP configuration guide |
| [CI/CD Architecture](docs/ci-architecture.md) | Modular pipeline architecture |
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

The pipeline runs automatically on every push and pull request with **13 specialized workflows**:

```
┌────────────────┐   ┌────────────────────────────────────────────┐   ┌────────────────┐
│  Pre-commit    │──▶│           GitHub Actions (13 workflows)    │──▶│  Cloud Build   │
│    Hooks       │   │                                            │   │   Deployment   │
└────────────────┘   └────────────────────────────────────────────┘   └────────────────┘
       │                              │                                      │
       ▼                              ▼                                      ▼
┌────────────────┐   ┌────────────────────────────────────────────┐   ┌────────────────┐
│ Local checks:  │   │ Parallel workflows:                        │   │ Deploy stages: │
│ • Ruff format  │   │ • ci.yml (shell), python.yml, terraform.yml│   │ • Build image  │
│ • TFLint       │   │ • security.yml, dependencies.yml           │   │ • Push to AR   │
│ • Gitleaks     │   │ • yaml.yml, dockerfile.yml, actionlint.yml │   │ • Deploy CR    │
│ • detect-secrets│  │ • auto-fix.yml (Claude AI)                 │   │ • Smoke tests  │
└────────────────┘   └────────────────────────────────────────────┘   └────────────────┘
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
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:FF9900,100:4285F4&height=100&section=footer">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:FF9900,100:4285F4&height=100&section=footer" alt="Footer"/>
</picture>

<p>
  <strong>Built with Terraform for AWS and Google Cloud</strong>
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
