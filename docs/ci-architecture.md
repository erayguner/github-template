# CI/CD Architecture

This document describes the modular GitHub Actions CI pipeline architecture used in this repository.

## Overview

The CI pipeline uses independent, parallel workflows for maximum efficiency and clarity. Each workflow focuses on a specific domain, making it easy to identify and debug failures.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Push/Pull Request                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           │                         │                         │
           ▼                         ▼                         ▼
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│    Terraform     │    │      YAML        │    │   Actionlint     │
│   (6 parallel    │    │   (2 parallel    │    │   (validates     │
│     jobs)        │    │     jobs)        │    │    workflows)    │
└──────────────────┘    └──────────────────┘    └──────────────────┘
           │                         │                         │
           ▼                         ▼                         ▼
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│    Security      │    │  Dependencies    │    │   Dockerfile     │
│   (6 parallel    │    │   (5 parallel    │    │   (2 parallel    │
│     jobs)        │    │     jobs)        │    │     jobs)        │
└──────────────────┘    └──────────────────┘    └──────────────────┘
           │
           ▼
┌──────────────────┐
│     Python       │
│   (3 parallel    │
│     jobs)        │
└──────────────────┘
```

## Workflow Layout

All workflows are located in `.github/workflows/` and run in parallel on `ubuntu-latest`.

| Workflow | File | Trigger Paths | Jobs |
|----------|------|---------------|------|
| Terraform | `terraform.yml` | `terraform/**` | 6 |
| YAML | `yaml.yml` | `*.yaml`, `*.yml` | 2 |
| Actionlint | `actionlint.yml` | `.github/workflows/**` | 1 |
| Security | `security.yml` | All files | 6 |
| Dependencies | `dependencies.yml` | Package files | 5 |
| Dockerfile | `dockerfile.yml` | `Dockerfile*`, `docker/**` | 2 |
| Python | `python.yml` | `*.py`, `pyproject.toml` | 3 |

## What Each Workflow Checks

### Terraform Validation (`terraform.yml`)

Validates Infrastructure as Code for correctness and security.

| Job | Tool | Purpose |
|-----|------|---------|
| `terraform-fmt` | `terraform fmt` | Code formatting consistency |
| `terraform-validate` | `terraform validate` | HCL syntax and configuration |
| `tflint` | TFLint | Best practices, deprecated syntax |
| `terrascan` | Terrascan | Policy-as-code compliance |
| `tfsec` | tfsec | Security misconfigurations |
| `checkov` | Checkov | Infrastructure security |

### YAML Validation (`yaml.yml`)

Ensures YAML files are properly formatted.

| Job | Tool | Purpose |
|-----|------|---------|
| `yamllint` | yamllint | YAML syntax and style |
| `prettier` | Prettier | Consistent formatting |

### GitHub Actions Validation (`actionlint.yml`)

Validates GitHub Actions workflow files.

| Job | Tool | Purpose |
|-----|------|---------|
| `actionlint` | actionlint | Workflow syntax, expressions, actions |

### Security Scanning (`security.yml`)

Comprehensive secret detection and vulnerability scanning.

| Job | Tool | Purpose |
|-----|------|---------|
| `gitleaks` | Gitleaks | Secret detection in git history |
| `trivy-fs` | Trivy | Filesystem vulnerability scanning |
| `trivy-config` | Trivy | IaC configuration scanning |
| `trufflehog` | TruffleHog | High-entropy secret detection |
| `bandit` | Bandit | Python security linting |
| `codeql` | CodeQL | Semantic code analysis (SAST) |

### Dependency Scanning (`dependencies.yml`)

Generates SBOMs and scans for vulnerable dependencies.

| Job | Tool | Purpose |
|-----|------|---------|
| `sbom` | Syft | Software Bill of Materials |
| `trivy-sbom` | Trivy | SBOM vulnerability analysis |
| `pip-audit` | pip-audit | Python dependency vulnerabilities |
| `grype` | Grype | Container/dependency vulnerabilities |
| `license-check` | pip-licenses | License compliance |

### Dockerfile Linting (`dockerfile.yml`)

Validates container build files.

| Job | Tool | Purpose |
|-----|------|---------|
| `hadolint` | Hadolint | Dockerfile best practices |
| `trivy-dockerfile` | Trivy | Container security issues |

### Python (`python.yml`)

Python code quality and testing.

| Job | Tool | Purpose |
|-----|------|---------|
| `ruff` | Ruff | Linting and formatting |
| `mypy` | mypy | Type checking |
| `pytest` | pytest | Unit tests with coverage |

## Running Checks Locally

### Prerequisites

```bash
# Install pre-commit
pip install pre-commit

# Install pre-commit hooks
pre-commit install
```

### Run All Pre-commit Hooks

```bash
pre-commit run --all-files
```

### Run Individual Tools

```bash
# Terraform
cd terraform
terraform fmt -check -recursive
terraform validate
tflint --init && tflint --recursive

# Security
gitleaks detect --source . --verbose
trivy fs .
detect-secrets scan --baseline .secrets.baseline

# YAML
yamllint .

# Python
ruff check .
ruff format --check .
mypy .
pytest --cov

# Dockerfile
hadolint Dockerfile

# GitHub Actions
actionlint
```

## Security Reasoning

### Multi-Layer Secret Detection

We use multiple secret detection tools because each has different strengths:

| Tool | Strength |
|------|----------|
| **Gitleaks** | Git-aware, scans full history, extensive rule set |
| **TruffleHog** | Entropy-based detection, finds novel patterns |
| **detect-secrets** | Baseline support, reduces false positives |

### Defense in Depth for IaC

Multiple Terraform security scanners catch different issues:

| Tool | Focus |
|------|-------|
| **tfsec** | AWS/Azure/GCP-specific security rules |
| **Checkov** | CIS benchmarks, compliance frameworks |
| **Terrascan** | OPA policies, cross-cloud coverage |

### SBOM and Supply Chain Security

- **Syft** generates a comprehensive Software Bill of Materials
- **Grype** and **Trivy** scan the SBOM for known vulnerabilities
- **pip-audit** uses PyPI's vulnerability database
- **License checks** ensure compliance with OSS licenses

### CodeQL for Semantic Analysis

CodeQL performs deep semantic analysis that catches vulnerabilities traditional linters miss:
- SQL injection
- XSS
- Path traversal
- Unsafe deserialization

## Configuration Files

| File | Purpose |
|------|---------|
| `.tflint.hcl` | TFLint rules and plugins |
| `.yamllint.yml` | YAML linting rules |
| `.gitleaks.toml` | Secret detection rules |
| `.terrascan.toml` | Terrascan skip rules |
| `.secrets.baseline` | Known false positives |
| `pyproject.toml` | Python tooling config |

## Adding New Workflows

1. Create a new workflow file in `.github/workflows/`
2. Use path filters to trigger only on relevant changes
3. Run jobs in parallel where possible
4. Upload SARIF results to GitHub Security tab
5. Add corresponding pre-commit hook
6. Document in this file

## Troubleshooting

### Workflow Not Triggering

Check path filters in the workflow file match your changed files:

```yaml
on:
  push:
    paths:
      - "terraform/**"  # Only triggers on terraform changes
```

### False Positives in Security Scans

1. For Gitleaks: Add to `.gitleaks.toml` allowlist
2. For detect-secrets: Update `.secrets.baseline`
3. For Terrascan: Add skip rule to `.terrascan.toml`
4. For Trivy: Add `.trivyignore` file

### Pre-commit Hooks Failing

Some hooks require local tools. Install them or skip in CI:

```yaml
# In .pre-commit-config.yaml
ci:
  skip: [terraform_validate, gitleaks]
```

## Migration from MegaLinter

This repository previously used MegaLinter. The modular approach provides:

| Benefit | Description |
|---------|-------------|
| **Faster feedback** | Parallel workflows complete faster |
| **Clearer failures** | Each workflow shows specific issues |
| **Easier maintenance** | Update individual tools independently |
| **Better caching** | Each workflow caches its own dependencies |
| **Granular triggers** | Only run relevant checks per change |
