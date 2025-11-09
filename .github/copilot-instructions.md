# copilot-instructions.md

<!-- ai_meta start -->
**Parsing Rules**
- Process infrastructure and application patterns in sequential order
- Use exact patterns and templates provided in this file
- Follow MUST/ALWAYS/REQUIRED directives strictly
- Do not invent architectural patterns not defined here
- Prefer existing repository conventions over generic examples

**File Conventions**
- encoding: UTF-8
- line_endings: LF
- indent: 2 spaces (HCL/YAML), 2 or 4 spaces (Python per existing style) 
- terraform extensions: .tf for configs, .tfvars for variable sets
- python packaging: pyproject.toml (single source of truth)
- terraform root structure: single root with optional aws.tf / gcp.tf split
<!-- ai_meta end -->

This repository is a multi-language template combining Terraform (multi-cloud: AWS + GCP optional) and Python (UV + Ruff) with automated CI/CD, security scanning, and fast developer workflows.

## Project Status (Updated 2025-11-06)

Current State:
- ✅ Terraform root: multi-cloud scaffolding present (aws.tf, gcp.tf, conditional enable flags)
- ✅ Providers: AWS + Google optional via `enable_aws`, `enable_gcp`
- ✅ Tooling: UV for Python dependency management, Ruff for lint/format
- ✅ Security: tfsec SARIF present, secret detection (to integrate via pre-commit)
- ✅ Documentation: Terraform & Python READMEs + multi-cloud guide
- ✅ Testing: Python tests (`python/src/tests` + root `src/test_main.py`) basic coverage
- ✅ Version Pinning: Managed through `pyproject.toml` and `uv.lock`
- ✅ Conditional Terraform patterns: count-based resource enablement

Recent Updates:
- Multi-cloud guide added (`terraform/README-MultiCloud.md`)
- Python fast toolchain integration (UV/Ruff)
- Initial tfsec scan output (`python/tfsec.sarif`)

Repository Reference: local workspace (template form)

## Agent Communication Guidelines

Core Rules:
- REVIEW / ANALYZE / CHECK / EXAMINE: Read-only. Provide feedback without editing files.
- IMPLEMENT / ADD / CREATE / FIX / CHANGE / REFACTOR: Requires file modifications. Confirm intent when ambiguous; otherwise proceed with high-fidelity implementation aligned to this file.
- IMPROVE / OPTIMIZE / REFACTOR (performance or structure): Clarify target scope if not explicit; prefer incremental safe changes.
- MANDATORY WAIT (Only if user explicitly requests options): Present numbered options then wait. If system-level autonomy overrides, proceed with safest well-documented option.

Communication Flow:
1. Identify intent (review vs change).
2. For review: produce structured findings (Summary, Strengths, Issues, Recommendations).
3. For implementation: list actionable steps → execute atomically → validate (lint/tests) → report status.
4. When options requested: Offer A), B), C), D), Other approach. Stop and await selection.

## Terraform Guidelines (Multi-Cloud Root)

Design Principles:
- Single root configuration with conditional resource creation.
- Providers always declared; resources guarded by `count` / `for_each` based on enable flags.
- Keep variable validation strict to fail early.
- Avoid separate workspaces; prefer directory or variable separation (already using flags & potential env-specific tfvars).

Root File Layout (actual / expected):
```
terraform/
├── main.tf            # Core provider configuration + locals
├── aws.tf             # AWS resources (optional; ensure conditional counts)
├── gcp.tf             # GCP resources (optional; ensure conditional counts)
├── variables.tf       # All input variables (selection + validation)
├── outputs.tf         # Output values (use conditional expressions)
├── versions.tf        # Required providers & constraints
├── providers.tf       # Strategy / commentary (keep lightweight)
├── MULTI_CLOUD_SUMMARY.md # Overview & usage patterns
├── terraform.tfvars.example # Example configuration values
└── README*.md         # Terraform documentation
```

Provider Strategy (REQUIRED):
- Always declare `provider "aws"` and `provider "google"`; skip validations when disabled.
- Do not wrap provider blocks in conditional logic (unsupported); instead set inert values or skip validations.

Conditional Resource Pattern:
```hcl
resource "aws_vpc" "main" {
  count = var.enable_aws ? 1 : 0
  cidr_block = var.vpc_cidr
  tags = merge(local.common_tags, { Cloud = "aws" })
}

resource "google_compute_network" "main" {
  count = var.enable_gcp ? 1 : 0
  name  = "${var.project_name}-gcp-vpc"
  auto_create_subnetworks = false
  labels = merge(local.common_labels, { cloud = "gcp" })
}
```

Variable Validation Pattern:
```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
```

Output Pattern (Conditional Safety):
```hcl
output "vpc_id" {
  description = "ID of the AWS VPC (when AWS enabled)"
  value       = var.enable_aws ? aws_vpc.main[0].id : null
}
```

State Management:
- Template intentionally leaves backend blocks commented; user must configure (S3 or GCS). Do not auto-insert unverified bucket names.
- MUST document backend choice in README when enabling.

Naming Conventions:
- AWS: `${var.project_name}-${var.environment}-aws-${resource_type}`
- GCP: `${var.project_name}-${var.environment}-gcp-${purpose}`

Security & Scanning:
- Recommend tfsec & (optionally) Checkov integration in CI.
- Secrets: encourage pre-commit `detect-secrets` baseline addition (missing currently).

## Python Guidelines (UV + Ruff)

Structure Expectations:
- `python/pyproject.toml` defines dependency groups (dev, test, docs, etc.).
- Use Ruff for lint + format (avoid mixing Black/isort unless declared).
- Tests: place unit tests under `python/src/tests` or `python/tests` consistently; unify path if divergence occurs.
- Avoid requirements*.txt (migration instructions already present). Remove if redundant.

Code Quality:
- Keep functions small & documented with docstrings (Google style or NumPy style acceptable; be consistent).
- Use type hints across public functions. Run `ruff check` + `mypy` for validation.

Performance Practices:
- Prefer async for high-latency IO (HTTP calls) using `httpx` if present.
- Avoid premature micro-optimizations; measure with pytest benchmarks or profiling group dependencies.

Dependency Management:
- Add new libs via `uv add` or `uv add --dev`; never edit lock file by hand.
- Group-specific installs: `uv sync --group dev --group test` etc.

## Commit Message Standard (Conventional Commits REQUIRED)
Examples:
- feat(terraform): add conditional google network
- fix(python): resolve NoneType error in main entry
- docs(multi-cloud): clarify backend configuration options
- chore(ci): integrate tfsec scan into pipeline

Breaking Change Footer:
```
BREAKING CHANGE: removes legacy variable aws_region_default
```

## Documentation Requirements
- Terraform root README must include: structure diagram, quick start, variable examples, security scanning guidance.
- Python README must list core dev workflow (already satisfied).
- Multi-cloud README must remain aligned with variable names (`enable_aws`, `enable_gcp`, `cloud_provider`).
- When adding new prompt/agent/instructions files, follow checklists (retained below).

## Testing Guidelines
Python:
- Minimum: Ensure `pytest -q` passes before committing.
- Add coverage threshold (suggest 80%+) in follow-up improvement (not enforced yet).
Terraform:
- Validate: `terraform fmt -recursive` + `terraform validate`.
- Optional enhancement: Add terratest or kitchen tests (not yet present).

## Performance Considerations
Terraform:
- Limit excessive `for_each` maps to keep state small.
- Prefer merging labels/tags through locals.
Python:
- Use lazy imports for heavy modules if startup time matters.

## Error Handling
Terraform:
- Use variable validation and conditional outputs to avoid referencing null resources.
Python:
- Raise explicit exceptions with context; avoid bare `except:`.

## Project Language Requirement
All infrastructure, code comments, docs, commit messages MUST be in English.

## Repository Evolution Recommendations (Non-breaking)
- Add pre-commit config to root for unified hooks (terraform fmt/validate, ruff, detect-secrets).
- Integrate GitHub Actions matrix for enabling/disabling cloud providers in plan phase.
- Add backend configuration examples with placeholders in README.

## Prompt / Instruction / Chat Mode Review Checklists (Apply Only During Code Review)

README updates:
- [ ] New file referenced from `README.md` when added.

Prompt file guide (`*.prompt.md`):
- [ ] Markdown front matter present.
- [ ] `mode` field: `agent` or `ask`.
- [ ] `description` field present, non-empty, wrapped in single quotes.
- [ ] Filename lowercase, hyphen-separated.
- [ ] Encourage `tools` usage (optional, not mandatory).
- [ ] Encourage explicit `model` specification.

Instruction file guide (`*.instructions.md`):
- [ ] Markdown front matter present.
- [ ] `description` field present, non-empty, single-quoted.
- [ ] Filename lowercase, hyphen-separated.
- [ ] `applyTo` field lists one or multiple globs (e.g. '**/*.py, **/*.tf').

Chat Mode file guide (`*.chatmode.md`):
- [ ] Markdown front matter present.
- [ ] `description` field present, non-empty, single-quoted.
- [ ] Filename lowercase, hyphen-separated.
- [ ] Encourage `tools` usage (optional).
- [ ] Encourage `model` specification.

## Usage Patterns (Multi-Cloud Recap)

Enable AWS only:
```bash
terraform plan -var="enable_aws=true" -var="enable_gcp=false"
```

Enable GCP only:
```bash
terraform plan -var="enable_aws=false" -var="enable_gcp=true" -var="gcp_project_id=my-gcp-project"
```

Enable both:
```bash
terraform plan \
  -var="enable_aws=true" \
  -var="enable_gcp=true" \
  -var="gcp_project_id=my-gcp-project"
```

## Conditional Output Example (Safety)
```hcl
output "aws_vpc_arn" {
  description = "ARN of the AWS VPC (null when AWS disabled)"
  value       = var.enable_aws ? aws_vpc.main[0].arn : null
}
```

## Backend Configuration Examples (Commented)
```hcl
# backend "s3" {
#   bucket = "my-terraform-state-bucket"
#   key    = "global/primary.tfstate"
#   region = "us-west-2"
#   dynamodb_table = "terraform-locks"
# }

# backend "gcs" {
#   bucket = "my-terraform-state-bucket"
#   prefix = "terraform/state"
# }
```

## Quality Gates (Suggested Workflow)
1. Terraform: fmt → validate → (optional plan).
2. Python: ruff check → ruff format → pytest.
3. Security: tfsec (and optionally detect-secrets, bandit, safety).
4. Commit only after all pass.

## Do / Do Not Summary
DO:
- Use conditional counts for multi-cloud resources.
- Keep variable validation strict.
- Maintain English documentation.
- Use UV for dependency management.

DO NOT:
- Add provider blocks under conditional logic.
- Reference resources when corresponding provider disabled without guards.
- Introduce unmanaged requirements.txt duplicates.

## Troubleshooting Quick Notes
- Provider auth errors: verify enable flags vs credentials; disable provider if unused.
- Null output errors: wrap references in conditional ternary expressions.
- Python import errors: ensure group dependencies installed via `uv sync --group dev --group test`.

## Change Log Policy
Use conventional commits; semantic versioning guidance: MAJOR (breaking infra layout), MINOR (new resources/tooling), PATCH (non-breaking fixes).

---
End of refactored copilot instructions for multi-cloud Terraform + Python template.
