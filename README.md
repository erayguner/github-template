# 🚀 Multi-Language Repository Template

[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml)
[![Security Analysis](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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

1. **Create from template**: Use this repository as a GitHub template
2. **Setup**: `cd python && uv sync --group dev && pre-commit install`
3. **Configure**: Edit `terraform/terraform.tfvars` for cloud resources

## License

MIT License - see [LICENSE](LICENSE) for details.