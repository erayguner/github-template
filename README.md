<div align="center">

# 🚀 Multi-Language Repository Template

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![UV](https://img.shields.io/badge/UV-DE5FE9?style=for-the-badge&logo=python&logoColor=white)](https://docs.astral.sh/uv/)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-web-services&logoColor=white)](https://aws.amazon.com)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com)

[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml)
[![Security Analysis](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml)
[![Pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![GitLeaks](https://img.shields.io/badge/secrets-gitLeaks-orange.svg?style=for-the-badge)](https://github.com/gitleaks/gitleaks)
[![Dependabot](https://img.shields.io/badge/dependabot-enabled-blue?logo=dependabot&style=for-the-badge)](https://github.com/dependabot)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/YOUR_USERNAME/YOUR_REPO.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/releases)
[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/YOUR_REPO.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/YOUR_USERNAME/YOUR_REPO.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)

</div>

---

## 📖 Overview

A **production-ready** GitHub repository template supporting **Terraform** and **Python** projects with enterprise-grade security, automated CI/CD pipelines, and modern development workflows for 2024/2025.

### ✨ **What Makes This Template Special**

🛡️ **Security-First**: CodeQL, Dependabot auto-updates, GitLeaks, SLSA attestations  
⚡ **Ultra-Fast**: Ruff linting (150-1000x faster than traditional tools)  
🌩️ **Multi-Cloud**: AWS, GCP, or hybrid infrastructure support  
🔄 **Zero-Config**: Automatic project type detection and conditional workflows  
🏗️ **Enterprise-Ready**: OIDC authentication, branch protection, compliance checking

## 🌟 **Features & Capabilities**

<div align="center">

| 🏗️ **Infrastructure** | 🐍 **Python** | 🔒 **Security** | 🔄 **CI/CD** |
|:---:|:---:|:---:|:---:|
| Multi-cloud Terraform | UV package manager | CodeQL scanning | GitHub Actions |
| AWS + GCP support | Ruff linting | GitLeaks secrets | OIDC authentication |
| Auto-documentation | Type checking | Vulnerability scanning | Automated testing |
| Security scanning | Test automation | SLSA attestations | Performance monitoring |

</div>

### 🛠️ **Core Features**

- **🌐 Multi-Language Support**: Terraform and Python project configurations with intelligent detection
- **☁️ Multi-Cloud Support**: AWS, Google Cloud Platform, or hybrid deployments  
- **⚡ Ultra-Fast Tooling**: UV package manager (10-100x faster) + Ruff linting (150-1000x faster)
- **🔐 Enterprise Security**: CodeQL, Dependabot auto-updates, GitLeaks secrets, container security
- **🚀 Modern CI/CD**: Conditional workflows, OIDC authentication, automated deployments
- **📋 Smart Automation**: Project type detection, adaptive workflows, compliance checking

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

## 🛠 Supported Project Types

### Terraform Projects
- **Multi-Cloud Support**: AWS, GCP, or both
- **Formatting**: `terraform fmt`
- **Validation**: `terraform validate` (per cloud provider)
- **Security**: `tfsec`, `checkov`
- **Documentation**: `terraform-docs`
- **Linting**: `tflint`
- **Provider Options**: 
  - AWS: VPC, Subnets, Security Groups, EC2
  - GCP: VPC Network, Subnets, Firewall Rules, Compute Engine

### Python Projects
- **Package Manager**: `uv` (10-100x faster than pip)
- **Formatting & Linting**: `ruff` (150-1000x faster, replaces Black, isort, Flake8)
- **Type Checking**: `mypy`
- **Security**: `bandit`, `safety`
- **Testing**: `pytest`, `coverage`
- **Dependency Groups**: dev, test, docs, profiling, api

## 🚀 **Quick Start**

<div align="center">

### **Get Started in 3 Steps**

</div>

### 1️⃣ **Create Repository**
```bash
# Use this template on GitHub or clone directly
gh repo create my-project --template YOUR_USERNAME/YOUR_REPO
cd my-project
```

### 2️⃣ **Setup Development Environment**
```bash
# Install UV (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python and dependencies (10-100x faster than pip!)
cd python && uv sync --group dev

# Setup pre-commit hooks
uv tool install pre-commit
pre-commit install

# For Terraform projects
cd ../terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

### 3️⃣ **Configure Cloud Authentication (Optional)**
<details>
<summary><strong>🔒 OIDC Setup (Recommended)</strong></summary>

**AWS OIDC:**
```bash
# Set repository variables:
AWS_ROLE_ARN=arn:aws:iam::ACCOUNT:role/GitHubActions
```

**GCP OIDC:**
```bash
# Set repository variables:
GCP_WORKLOAD_IDENTITY_PROVIDER=projects/123/locations/global/workloadIdentityPools/pool/providers/provider
GCP_SERVICE_ACCOUNT=github-actions@project.iam.gserviceaccount.com
GCP_PROJECT_ID=your-project-id
```
</details>

---

<div align="center">

**🎉 You're Ready!** Push your first commit and watch the magic happen ✨

[![Deploy](https://img.shields.io/badge/Deploy-Now-success?style=for-the-badge&logo=rocket)](https://github.com/YOUR_USERNAME/YOUR_REPO/generate)

</div>

## 📋 Configuration

The repository automatically detects project type and applies appropriate configurations:

- **Pre-commit hooks** adapt based on detected languages
- **GitHub Actions** run conditional workflows  
- **Security scanning** includes language-specific tools
- **Documentation** generation matches project requirements

## 🔧 Customization

Modify these files to customize for your needs:
- `.pre-commit-config.yaml` - Adjust hooks and tool versions
- `.github/workflows/ci.yml` - Modify CI/CD pipeline
- `PROJECT_TYPE` - Set in GitHub repository variables

## 📖 Documentation

See individual directories for detailed documentation:
- [Terraform Setup](./terraform/README.md)
- [Python Setup](./python/README.md)
- [GitHub Actions](./docs/github-actions.md)
- [Pre-commit Hooks](./docs/pre-commit.md)

---

## 📊 **Performance & Metrics**

<div align="center">

| Metric | Traditional Tools | This Template | Improvement |
|:---:|:---:|:---:|:---:|
| **Package Install** | 30-300s | 1-10s | **10-100x faster** |
| **Linting Speed** | 30-60s | 0.1-0.5s | **150-1000x faster** |
| **Security Scans** | Manual | Automated | **100% coverage** |
| **Setup Time** | Hours | Minutes | **10x faster** |
| **CI/CD Speed** | 15-20min | 3-6min | **3-5x faster** |

</div>

---

## 🏆 **Why Choose This Template?**

<div align="center">

[![Security](https://img.shields.io/badge/Security-Enterprise_Grade-critical?style=flat-square&logo=shield)](./SECURITY.md)
[![Performance](https://img.shields.io/badge/Performance-Ultra_Fast-success?style=flat-square&logo=zap)](#performance--metrics)
[![Compliance](https://img.shields.io/badge/Compliance-SLSA_L3-blue?style=flat-square&logo=checkmarx)](./docs/compliance.md)
[![Modern](https://img.shields.io/badge/Stack-2024/2025-orange?style=flat-square&logo=stack-overflow)](./docs/tech-stack.md)

</div>

✅ **Production-Ready** - Battle-tested configurations  
✅ **Zero-Config** - Works out of the box  
✅ **Enterprise Security** - Meets compliance requirements  
✅ **Developer Friendly** - Modern tooling and workflows  
✅ **Future-Proof** - Latest 2024/2025 best practices  

---

## 🤖 **Automated Dependency Management**

### **Dependabot Configuration**

The template includes comprehensive **Dependabot** configuration for automated security updates:

📦 **Multi-Ecosystem Support:**
- **Python**: Weekly updates with grouped PRs (dependencies, testing tools, linting tools)
- **Terraform**: Weekly provider and module updates
- **GitHub Actions**: Weekly action version updates  
- **Docker**: Weekly base image updates
- **npm**: Weekly JavaScript dependency updates

🔒 **Security Features:**
- **Vulnerability Alerts**: Automatic PRs for security issues
- **Grouped Updates**: Reduces PR noise while maintaining security
- **Smart Scheduling**: Spread across weekdays to avoid conflicts
- **Security Tagging**: All PRs tagged for security tracking

**Benefits:**
- 🚀 **Stay Current**: Never miss critical security updates
- 🛡️ **Reduce Risk**: Automated vulnerability patching
- ⏰ **Save Time**: No manual dependency management
- 📊 **Track Progress**: Clear labeling and review assignment

---

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guidelines](./CONTRIBUTING.md) for details.

<div align="center">

[![Contributors](https://img.shields.io/github/contributors/YOUR_USERNAME/YOUR_REPO.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/graphs/contributors)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

</div>

---

## 📄 **License**

<div align="center">

This template is available under the MIT License.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Made with ❤️ for the developer community**

</div>