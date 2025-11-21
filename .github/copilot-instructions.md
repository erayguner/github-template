## AI Coding Agent Instructions

Focus: Multi-cloud Terraform (AWS/GCP) + Python (UV + Ruff) + Markdown docs. Make precise, minimal changes aligned with existing patterns; never introduce new frameworks or stylistic tool stacks.

### 1. Architecture Snapshot
- Terraform (`terraform/`): unified root; enable flags `enable_aws`, `enable_gcp` gate resources via `count` ternaries. Providers always declared (see `aws.tf`, `gcp.tf`).
- Python (`python/`): single package; entry `src/main.py`; tests in `src/tests/`; dependency truth = `pyproject.toml` + `uv.lock` only.
- Documentation (`docs/`): operational guides, multi-cloud usage, examples; treat as authoritative for workflow patterns.

### 2. Core Workflows
- Python (dev): `cd python && uv sync --group dev && uv run ruff check . && uv run pytest`.
- Terraform (infra): `cd terraform && terraform fmt -recursive && terraform validate && terraform plan -var="enable_aws=..." -var="enable_gcp=..."`.
- Security: `tfsec ./terraform` (report stored in `python/tfsec.sarif` for now).
- Update loop: modify → run gates (section 7) → commit.

### 3. Terraform Patterns (Strict)
- Conditional resource: `count = var.enable_aws ? 1 : 0` (never use `for_each` for simple on/off toggles).
- Conditional outputs: `value = var.enable_aws ? aws_vpc.main[0].id : null` (avoid unguarded indexing).
- Locals for shared tags/labels: define `locals { common_tags = { Project = var.project_name Environment = var.environment } }` then `tags = merge(local.common_tags, { Cloud = "aws" })`.
- Variable validation: always include `validation { condition ... error_message ... }` for enums (see `environment`).
- Backend blocks: leave commented placeholders; do NOT auto-populate buckets.
- Adding a new AWS/GCP resource: 1) add guarded resource with `count` 2) add conditional output if externally referenced 3) update docs only if user-facing.
- Common pitfalls to avoid: referencing `[0]` on empty guarded resources; missing `null` fallback in outputs; introducing provider blocks conditionally.

### 4. Python Patterns
- Dependency add: `uv add <pkg>` or `uv add --dev <pkg>` (never edit lock manually; never reintroduce `requirements*.txt`).
- Imports: prefer absolute package imports (`from python.src.util.foo import bar`) only if package structure demands; keep internal utilities under `python/src/util/`.
- Style: Ruff handles lint + format; run `uv run ruff format .` only after checks pass.
- Tests: place test file `test_<name>.py` in `python/src/tests/`; mirror module name; assert minimal public behavior; avoid broad integration harnesses.
- Adding utility module: create `python/src/util/<name>.py` with typed functions + short docstrings; add targeted test; run workflow.
- Error handling: raise descriptive exceptions; avoid bare `except`; prefer `ValueError` / custom small exception class only if repeated.
- Type hints: all public function params + return types; prefer `list[str]` over `List[str]` (PEP 585 style).

### 5. Markdown Documentation Conventions
- Location: only under `docs/` (guides), `terraform/` (infra-specific notes), root README for high-level overview.
- File naming: lowercase words, hyphen-separated (`deployment-quick-reference.md`).
- Content scope: each doc focused (quick reference vs workflows vs troubleshooting). Do NOT duplicate authoritative command sequences—link to existing docs when expanding.
- Adding new doc: ensure unique purpose; include opening summary paragraph; cross-link related docs using relative paths (e.g. `[Troubleshooting](../docs/troubleshooting.md)`).
- Examples folder: keep `.tfvars.example` files minimal; update only when new required variables introduced.

### 6. Commit Messages (Conventional Commits)
- Format examples: `feat(terraform): add guarded subnet`, `fix(python): null handling in main`, `docs(markdown): clarify multi-cloud enable flags`.
- BREAKING CHANGE footer only when removing or renaming variables/resources consumed externally.

### 7. Quality Gates (Order)
1. Terraform: `terraform fmt -recursive` → `terraform validate` → optional `terraform plan`.
2. Python: `uv run ruff check .` → `uv run ruff format .` → `uv run pytest -q`.
3. Security: `tfsec ./terraform` (optionally later: detect-secrets, bandit, safety).
4. Commit after success (no partial commits of failing states).

### 8. Do / Avoid Summary
- DO: guard every cloud resource; strict variable validation; concise outputs; keep docs single-purpose; use UV for deps.
- AVOID: conditional provider blocks; unchecked resource indexing; adding new formatting tools; sprawling integration tests; duplicating command lists across docs.

### 9. Troubleshooting Fast Map
- Terraform null index: ensure `count` guard + conditional output ternary.
- Provider auth error: flip enable flag off or fix credentials; do not delete provider block.
- Python import failure: run `uv sync --group dev`; check path under `src/`.
- Lint auto-fix missing: run `uv run ruff format .` (format stage after check).

### 10. Review vs Implement Flow
- Review request keywords ("review", "analyze"): output sections (Summary / Strengths / Issues / Recommendations) only.
- Implement keywords ("add", "create", "fix"): list atomic steps → patch file(s) → run gates → report status → solicit follow-up.

### 11. Expansion Examples
- New AWS subnet: duplicate existing VPC tagging style; guard with `count`; add output `subnet_id` with ternary; update multi-cloud summary if externally relevant.
- New Python CLI flag: modify `main.py`; add parsing function; test flag behavior; keep side-effects minimal.
- New doc: `docs/<topic>-guide.md` referencing existing quick reference rather than re-copying commands.

### 12. Command Cheat Sheet
```bash
# Python full cycle
cd python && uv sync --group dev && uv run ruff check . && uv run pytest

# Terraform plan (AWS only)
cd terraform && terraform fmt -recursive && terraform validate && terraform plan -var="enable_aws=true" -var="enable_gcp=false"

# Terraform plan (GCP only)
terraform plan -var="enable_aws=false" -var="enable_gcp=true" -var="gcp_project_id=YOUR_PROJECT"

# Security scan
tfsec ./terraform
```

### 13. Safe Editing Principles
- Prefer editing existing files (avoid creating new unless pattern requires).
- Keep patches minimal & localized; avoid stylistic rewrites.
- Never introduce alternative dependency managers (pip, poetry) or duplicate requirement files.

### 14. Feedback Loop
If unclear requirements or conflicting patterns appear, pause and request clarification with concrete options (A/B). Otherwise proceed with smallest compliant change.

---
Provide feedback if deeper detail is needed for any section; expansions should stay within current toolchain + patterns.
