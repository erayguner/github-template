# Security Remediation Checklist

**Priority**: IMMEDIATE ACTION REQUIRED
**Due Date**: Within 7 days
**Owner**: DevOps/Security Team

---

## 🔴 CRITICAL (Complete This Week)

### 1. Remove Dangerous Claude Permissions ⚠️ HIGH SEVERITY

**File**: `.github/workflows/auto-fix.yml`
**Lines**: 249-362

**Current State**:
```yaml
acknowledge-dangerously-skip-permissions-responsibility: "true"
claude_args: "--dangerously-skip-permissions"
```

**Required Changes**:
```yaml
# REMOVE these dangerous flags:
- acknowledge-dangerously-skip-permissions-responsibility
- --dangerously-skip-permissions from claude_args

# ADD validation step:
- name: Validate Claude changes before commit
  run: |
    # Security scan modified files
    changed_files=$(git diff --name-only HEAD)

    # Block changes to sensitive paths
    if echo "$changed_files" | grep -qE '(\.github/|deploy/|secrets/|\.env)'; then
      echo "::error::Claude attempted to modify sensitive files!"
      exit 1
    fi

    # Run security scanners
    if echo "$changed_files" | grep -q '\.py$'; then
      pip install bandit
      bandit -r . -f json -o bandit-report.json
      if jq '.results | length > 0' bandit-report.json; then
        echo "::error::Security issues detected in Python files"
        exit 1
      fi
    fi
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 2. Reduce Workflow Permissions ⚠️ HIGH SEVERITY

**File**: `.github/workflows/auto-fix.yml`
**Lines**: 22-26

**Current State**:
```yaml
permissions:
  contents: write       # TOO BROAD
  pull-requests: write
  actions: read
  id-token: write      # UNNECESSARY
```

**Required Changes**:
```yaml
permissions:
  contents: read        # ✅ DOWNGRADE to read-only
  pull-requests: write  # ✅ KEEP for comments
  actions: read         # ✅ OK
  # ❌ REMOVE id-token unless using OIDC

# Add job-level permissions for specific needs:
jobs:
  auto-fix:
    permissions:
      contents: write  # Only when committing
      pull-requests: write
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 3. Fix Secret Exposure in Logs ⚠️ HIGH SEVERITY

**File**: `.github/workflows/auto-fix.yml`
**Lines**: 65-72, 360

**Current State**:
```yaml
if [ -z "${{ secrets.ANTHROPIC_API_KEY }}" ]; then
  echo "::error::Missing required API keys..."
fi
```

**Required Changes**:
```yaml
- name: Verify Claude API key exists
  env:
    HAS_ANTHROPIC_KEY: ${{ secrets.ANTHROPIC_API_KEY != '' }}
    HAS_OAUTH_TOKEN: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN != '' }}
  run: |
    if [ "$HAS_ANTHROPIC_KEY" != "true" ] && [ "$HAS_OAUTH_TOKEN" != "true" ]; then
      echo "::error::Required API authentication not configured."
      echo "::error::Set either ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN"
      exit 1
    fi
    echo "✅ API authentication verified"
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 4. Rotate All Secrets 🔑 CRITICAL

**Required Actions**:

1. **ANTHROPIC_API_KEY**:
   - [ ] Generate new API key at https://console.anthropic.com
   - [ ] Update in GitHub: Settings → Secrets → Actions
   - [ ] Delete old key from Anthropic console
   - [ ] Document rotation in security log

2. **PAT_TOKEN** (if exists):
   - [ ] Create fine-grained PAT with minimal scopes:
     - `contents: write` (ONLY for this repo)
     - `pull_requests: write` (ONLY for this repo)
   - [ ] Set expiration to 30 days
   - [ ] Replace in GitHub secrets
   - [ ] Revoke old token

3. **CLAUDE_CODE_OAUTH_TOKEN** (if exists):
   - [ ] Regenerate OAuth token
   - [ ] Update in GitHub secrets
   - [ ] Revoke old token

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

## 🟡 HIGH PRIORITY (Complete Within 2 Weeks)

### 5. Pin All Actions to Commit SHA

**Files**: All workflow files in `.github/workflows/`

**Current State**: Actions use version tags (vulnerable to tag poisoning)

**Required Tool**:
```bash
# Install action version pinning tool
npm install -g @github/dependency-graph-action

# Or manually get SHAs:
gh api repos/actions/checkout/commits/v5 --jq '.sha'
```

**Required Changes**:

```yaml
# ❌ BEFORE (vulnerable):
uses: actions/checkout@v5
uses: astral-sh/setup-uv@v6
uses: hashicorp/setup-terraform@v3
uses: anthropics/claude-code-action@v1

# ✅ AFTER (secure):
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v5
uses: astral-sh/setup-uv@a427adbf0b0e6e0e98f1acc3da08dc2056b28b8c  # v6
uses: hashicorp/setup-terraform@651471c36a6092792c552e8b1bef71e592b462d8  # v3
uses: anthropics/claude-code-action@<VERIFY-SHA-FIRST>  # v1

# Add comment with version tag for maintainability
```

**Files to Update**:
- [ ] `.github/workflows/auto-fix.yml`
- [ ] `.github/workflows/ci.yml`
- [ ] `.github/workflows/security.yml`
- [ ] `.github/workflows/test-auto-fix.yml`
- [ ] `.github/workflows/test-claude-action.yml`
- [ ] `.github/workflows/test-trigger-fix.yml`

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 6. Add Input Validation

**File**: `.github/workflows/auto-fix.yml`
**Lines**: 8-20

**Required Addition**:
```yaml
- name: Validate workflow inputs
  if: github.event_name == 'workflow_dispatch'
  run: |
    # Validate pr_branch format
    if [ -n "${{ inputs.pr_branch }}" ]; then
      BRANCH="${{ inputs.pr_branch }}"

      # Check valid characters
      if ! echo "$BRANCH" | grep -qE '^[a-zA-Z0-9/_-]+$'; then
        echo "::error::Invalid branch name: contains illegal characters"
        exit 1
      fi

      # Prevent path traversal
      if echo "$BRANCH" | grep -q '\.\.'; then
        echo "::error::Path traversal attempt detected"
        exit 1
      fi

      # Length limit
      if [ ${#BRANCH} -gt 100 ]; then
        echo "::error::Branch name too long (max 100 characters)"
        exit 1
      fi
    fi

    # Validate base_branch
    BASE="${{ inputs.base_branch }}"
    if ! echo "$BASE" | grep -qE '^(main|master|develop|staging)$'; then
      echo "::error::Invalid base branch: $BASE"
      exit 1
    fi
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 7. Enable Dependabot for GitHub Actions

**File**: Create `.github/dependabot.yml`

**Required Content**:
```yaml
version: 2
updates:
  # GitHub Actions dependencies
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    commit-message:
      prefix: "chore(deps)"
      include: "scope"
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
    open-pull-requests-limit: 10

  # Python dependencies (if applicable)
  - package-ecosystem: "pip"
    directory: "/python"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(deps)"
    groups:
      security:
        patterns:
          - "bandit"
          - "safety"
          - "cryptography"
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 8. Implement SBOM Generation

**File**: `.github/workflows/ci.yml`

**Required Addition**:
```yaml
- name: Generate Software Bill of Materials
  uses: anchore/sbom-action@v0
  with:
    artifact-name: sbom.spdx.json
    format: spdx-json

- name: Upload SBOM
  uses: actions/upload-artifact@v4
  with:
    name: sbom
    path: sbom.spdx.json
    retention-days: 90

- name: Scan SBOM for vulnerabilities
  uses: anchore/scan-action@v3
  with:
    sbom: sbom.spdx.json
    fail-build: true
    severity-cutoff: high
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

## 🟢 MEDIUM PRIORITY (Complete Within 30 Days)

### 9. Enable Branch Protection Rules

**Location**: GitHub Repository Settings → Branches

**Required Rules for `main` branch**:
- [ ] Require pull request reviews (min 1 approver)
- [ ] Require status checks to pass:
  - [ ] CI checks
  - [ ] Security scans
  - [ ] Code quality checks
- [ ] Require conversation resolution
- [ ] Require signed commits
- [ ] Require linear history
- [ ] Include administrators (enforce for everyone)
- [ ] Restrict who can push:
  - [ ] Only allow through PRs
  - [ ] Block force pushes
  - [ ] Block deletions

**CODEOWNERS for Workflows**:
Create `.github/CODEOWNERS`:
```
# Security team must review workflow changes
/.github/workflows/ @security-team @devops-team

# Require security review for sensitive files
/terraform/ @security-team
*.tf @security-team
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 10. Add Security Monitoring Workflow

**File**: Create `.github/workflows/security-monitoring.yml`

**Required Content**:
```yaml
name: Security Monitoring

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

permissions:
  contents: read
  security-events: write

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 100  # Check recent commits

      - name: Scan for leaked secrets
        run: |
          # Check commit messages for potential secrets
          git log -100 --pretty=format:"%s %b" | \
            grep -iE '(password|api[_-]?key|secret|token|credential)' > potential_leaks.txt || true

          if [ -s potential_leaks.txt ]; then
            echo "::warning::Potential secret references in commit messages"
            cat potential_leaks.txt
          fi

      - name: Check for permission escalation
        run: |
          # Detect workflow permission changes
          git diff HEAD~1 HEAD -- .github/workflows/ | \
            grep -E '^\+.*permissions:' > permission_changes.txt || true

          if [ -s permission_changes.txt ]; then
            echo "::warning::Workflow permissions modified"
            cat permission_changes.txt
          fi

      - name: Audit action versions
        run: |
          # Find unpinned actions
          find .github/workflows -name "*.yml" -exec grep -H 'uses:.*@v[0-9]' {} \; > unpinned.txt || true

          if [ -s unpinned.txt ]; then
            echo "::warning::Unpinned actions detected"
            cat unpinned.txt
          fi

      - name: Check for vulnerable dependencies
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy.sarif'

      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy.sarif'
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 11. Implement Audit Logging

**File**: `.github/workflows/audit-log.yml`

**Purpose**: Track all security-relevant events

```yaml
name: Audit Logging

on:
  workflow_run:
    workflows: ["*"]
    types: [completed]

jobs:
  log:
    runs-on: ubuntu-latest
    steps:
      - name: Log workflow execution
        run: |
          # Create audit log entry
          cat > audit-entry.json <<EOF
          {
            "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
            "event": "${{ github.event_name }}",
            "workflow": "${{ github.event.workflow_run.name }}",
            "actor": "${{ github.actor }}",
            "conclusion": "${{ github.event.workflow_run.conclusion }}",
            "run_id": "${{ github.run_id }}"
          }
          EOF

          # Send to logging service (configure your endpoint)
          # curl -X POST https://your-logging-service.com/api/logs \
          #   -H "Content-Type: application/json" \
          #   -d @audit-entry.json

          # For now, just output
          cat audit-entry.json
```

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

### 12. Security Training & Documentation

**Required Documentation**:

1. **Security Policy** (`.github/SECURITY.md`):
   - [ ] Vulnerability reporting process
   - [ ] Supported versions
   - [ ] Security contact information
   - [ ] Incident response plan

2. **Contributing Guidelines** (`CONTRIBUTING.md`):
   - [ ] Security review requirements
   - [ ] Workflow modification process
   - [ ] Secret handling guidelines
   - [ ] Code of conduct

3. **Workflow Security Guidelines** (`docs/workflow-security.md`):
   - [ ] Permission model documentation
   - [ ] Action approval process
   - [ ] Secret rotation schedule
   - [ ] Security testing requirements

**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

## 📊 Progress Tracking

### Overall Completion
- Critical Items: 0/4 (0%)
- High Priority: 0/4 (0%)
- Medium Priority: 0/4 (0%)
- **Total: 0/12 (0%)**

### Security Score Progression
- Current: **7.2/10** ⚠️
- After Critical: **8.5/10** (estimated)
- After High Priority: **9.0/10** (estimated)
- After Medium Priority: **9.5/10** (estimated)

---

## 🚨 Escalation Process

**If blocked or need help**:
1. Review detailed findings in `docs/security-audit-report.md`
2. Consult GitHub Actions Security Hardening Guide
3. Contact security team: security@yourcompany.com
4. Create issue with label `security` for tracking

---

## ✅ Verification Steps

After completing each item:

1. **Test the fix**:
   ```bash
   # Trigger the workflow manually
   gh workflow run <workflow-name>

   # Monitor the run
   gh run watch
   ```

2. **Verify no regression**:
   - Check that existing functionality still works
   - Run all CI/CD pipelines
   - Review workflow run logs

3. **Document the change**:
   - Update this checklist
   - Add entry to CHANGELOG.md
   - Update security documentation

4. **Peer review**:
   - Create PR with changes
   - Request security team review
   - Wait for approval before merging

---

**Last Updated**: 2025-11-06
**Next Review Date**: 2025-12-06
