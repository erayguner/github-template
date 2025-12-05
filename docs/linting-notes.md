# Linting Configuration Notes

This document explains the linting tools configured in this repository and important conventions for contributors.

## Overview

This repository uses multiple linters to ensure code quality and security:

| Tool | Purpose | Configuration File |
|------|---------|-------------------|
| **TFLint** | Terraform linting | `.tflint.hcl` |
| **tfsec** | Terraform security scanning | (uses defaults) |
| **Checkov** | Infrastructure as Code security | (uses defaults) |
| **Terrascan** | Terraform policy scanning | `.terrascan.toml` |
| **Gitleaks** | Secret detection | `.gitleaks.toml` |
| **yamllint** | YAML linting | `.yamllint.yml` |
| **actionlint** | GitHub Actions validation | (uses defaults) |
| **Ruff** | Python linting/formatting | `pyproject.toml` |
| **detect-secrets** | Secret baseline scanning | `.secrets.baseline` |

## TFLint Configuration

**File:** `.tflint.hcl`

### Key Settings

```hcl
config {
  # Use call_module_type instead of deprecated 'module' (v0.54.0+)
  call_module_type = "local"
  force = false
}
```

### Plugins

- **AWS Plugin** (`tflint-ruleset-aws`): Validates AWS resource configurations
- **Google Plugin** (`tflint-ruleset-google`): Validates GCP resource configurations

### Running TFLint

```bash
# Initialize plugins
cd terraform
tflint --init --config ../.tflint.hcl

# Run linting
tflint --config ../.tflint.hcl --recursive
```

### Important Notes

1. TFLint should only run in directories containing `.tf` files
2. The `call_module_type = "local"` setting replaces the deprecated `module = true`
3. Plugins are auto-installed on `tflint --init`

## Gitleaks Configuration

**File:** `.gitleaks.toml`

### Configuration Structure

```toml
[extend]
useDefault = true  # Extend default rules

[allowlist]
paths = [...]      # Paths to ignore
regexes = [...]    # Patterns to ignore
stopwords = [...]  # Words to ignore

[[rules]]          # Custom detection rules
```

### Custom Rules

The configuration includes custom rules for:
- GCP service account keys
- GCP API keys
- Terraform Cloud tokens

### Important Notes

1. Entropy detection is handled by default gitleaks rules
2. Per-rule entropy can be added using the `entropy` field in rule definitions
3. **Do not** use `[rules.entropy]` as a global section (invalid in v8.x)

Example of per-rule entropy:
```toml
[[rules]]
id = "high-entropy-string"
regex = '''[a-zA-Z0-9+/]{40,}'''
entropy = 4.5  # Entropy threshold for this rule
```

## yamllint Configuration

**File:** `.yamllint.yml`

### Key Rules

| Rule | Setting | Notes |
|------|---------|-------|
| `line-length` | max: 200 | Relaxed for readability |
| `indentation` | 2 spaces | Standard YAML indent |
| `quoted-strings` | only-when-needed | Avoid redundant quotes |
| `truthy` | warning level | Allows yes/no/on/off |

### Quoted Strings Convention

**DO NOT** quote simple strings unnecessarily:

```yaml
# Bad - redundant quotes
name: "my-app"
version: "1.0.0"

# Good - no quotes needed
name: my-app
version: 1.0.0
```

**DO** quote strings when needed:

```yaml
# Quote when containing special characters
description: "This: needs quotes"
path: "/path/with spaces"
pattern: "*.yaml"  # Glob patterns need quotes
```

## Terrascan Configuration

**File:** `.terrascan.toml`

### Skipped Rules

The following rules are skipped for this template repository:

| Rule ID | Name | Reason |
|---------|------|--------|
| `AC_AWS_0321` | networkPort80ExposedToprivate | Template demonstrates VPC-restricted HTTP |
| `AC_AWS_0322` | networkPort443ExposedToprivate | Template demonstrates VPC-restricted HTTPS |

### Production Recommendations

When using this template in production:

1. **Remove skip rules** from `.terrascan.toml`
2. **Restrict security group CIDRs** to specific IP ranges
3. **Consider removing HTTP (port 80)** entirely and using HTTPS only
4. **Add load balancer** with WAF for public-facing services

### Running Terrascan

```bash
# Scan only terraform directory
terrascan scan -d terraform/

# With custom config
terrascan scan -d terraform/ --config-path .terrascan.toml
```

## Pre-commit Hooks

**File:** `.pre-commit-config.yaml`

### Hook Categories

1. **Basic checks**: trailing whitespace, YAML/JSON validation
2. **Python**: Ruff linting and formatting
3. **Security**: detect-secrets, Gitleaks
4. **Terraform**: fmt, validate, TFLint, Checkov, tfsec
5. **YAML**: yamllint
6. **Shell**: shellcheck
7. **GitHub Actions**: actionlint

### Running Pre-commit

```bash
# Install hooks
pre-commit install

# Run all hooks
pre-commit run --all-files

# Run specific hook
pre-commit run terraform_tflint --all-files
```

### CI Skip List

Some hooks are skipped in CI (pre-commit.ci) because they require local tooling:

- `terraform_validate` - Requires Terraform binary
- `terraform_tflint` - Requires TFLint binary
- `terraform_checkov` - Requires Checkov
- `terraform_tfsec` - Requires tfsec
- `gitleaks` - Requires gitleaks binary

## MegaLinter Configuration

**File:** `.mega-linter.yml`

### Disabled Linters

| Linter | Reason |
|--------|--------|
| `SPELL_LYCHEE` | Broken template URLs in documentation |
| `SPELL_CSPELL` | Too many false positives |
| `YAML_V8R` | GitHub Actions schema issues |
| `MARKDOWN_MARKDOWNLINT` | Conflicts with documentation style |
| `REPOSITORY_GRYPE/TRIVY/KICS` | Duplicate security scanning |

### Terraform-specific Settings

```yaml
TERRAFORM_TFLINT_ARGUMENTS: "--config .tflint.hcl"
TERRAFORM_TERRASCAN_ARGUMENTS: "--skip-rules AC_AWS_0321,AC_AWS_0322"
TERRAFORM_TERRASCAN_DIRECTORY: terraform
```

## Conventions for Contributors

### Terraform

1. Use `snake_case` for all resource names
2. Add descriptions to all variables and outputs
3. Pin module versions explicitly
4. Run `terraform fmt` before committing

### YAML

1. Use 2-space indentation
2. Don't quote simple strings
3. Use double quotes when quoting is needed
4. Keep lines under 200 characters

### Secrets

1. Never commit actual secrets
2. Use `.secrets.baseline` for false positive management
3. Run `detect-secrets scan --baseline .secrets.baseline` to update baseline

### Python

1. Follow Ruff's default rules
2. Maximum line length: 88 characters
3. Use type hints where possible

## Troubleshooting

### TFLint "module" deprecation warning

If you see:
```
Warning: `module` attribute is deprecated. Use `call_module_type` instead
```

Update `.tflint.hcl`:
```hcl
config {
  call_module_type = "local"  # Instead of: module = true
}
```

### Gitleaks "entropy" parsing error

If you see:
```
Error: cannot unmarshal object into Go struct field
```

Ensure entropy is per-rule, not a global section:
```toml
# Wrong
[rules.entropy]
enabled = true

# Correct - per rule
[[rules]]
entropy = 4.5
```

### yamllint "redundantly quoted" errors

Remove unnecessary quotes from YAML values:
```yaml
# Before
key: "simple-value"

# After
key: simple-value
```

### Terrascan scanning wrong directories

Ensure `.terrascan.toml` or MegaLinter config specifies the correct directory:
```yaml
TERRAFORM_TERRASCAN_DIRECTORY: terraform
```
