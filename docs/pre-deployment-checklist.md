# Pre-Deployment Checklist

## CI/CD Auto-Fix Workflow Deployment Guide

**Last Updated:** 2025-11-06
**Status:** Production Ready

---

## Quick Start

```bash
# 1. Set required secrets
gh secret set ANTHROPIC_API_KEY
gh secret set PAT_TOKEN  # Optional but recommended

# 2. Clean up formatting (recommended)
sed -i '' 's/[[:space:]]*$//' .github/workflows/*.yml
echo '' >> .github/workflows/ci.yml
echo '' >> .github/workflows/security.yml

# 3. Test workflows
gh workflow run test-auto-fix.yml -f test_type=all -f create_issues=true

# 4. Deploy
git add .github/workflows/
git commit -m "chore(ci): deploy auto-fix workflows"
git push
```

---

## Detailed Checklist

### Phase 1: Prerequisites ✅

#### 1.1 Repository Settings

- [ ] **Branch Protection Configured**
  ```bash
  # Check current protection
  gh api repos/{owner}/{repo}/branches/main/protection

  # Recommended settings:
  - Require pull request reviews
  - Require status checks (CI, Security)
  - Allow specific actors to bypass (for auto-fix bot)
  ```

- [ ] **Actions Enabled**
  ```bash
  # Verify Actions are enabled
  gh api repos/{owner}/{repo} --jq .has_pages

  # Enable if needed:
  Settings → Actions → General → Allow all actions
  ```

- [ ] **Workflow Permissions Set**
  ```bash
  # Navigate to: Settings → Actions → General → Workflow permissions
  # Select: Read and write permissions
  # Check: Allow GitHub Actions to create and approve pull requests
  ```

#### 1.2 Required Secrets

- [ ] **ANTHROPIC_API_KEY** (Required)
  ```bash
  # Set API key
  gh secret set ANTHROPIC_API_KEY

  # Verify
  gh secret list | grep ANTHROPIC

  # Test validity
  curl -H "x-api-key: sk-ant-..." \
       -H "anthropic-version: 2023-06-01" \
       -H "content-type: application/json" \
       https://api.anthropic.com/v1/messages \
       -d '{"model":"claude-3-haiku-20240307","max_tokens":10,"messages":[{"role":"user","content":"test"}]}'
  ```

- [ ] **PAT_TOKEN** (Recommended)
  ```bash
  # Generate token with these permissions:
  # - repo (full control)
  # - workflow (update workflows)

  # Set token
  gh secret set PAT_TOKEN

  # Verify
  gh secret list | grep PAT
  ```

- [ ] **Alternative: CLAUDE_CODE_OAUTH_TOKEN**
  ```bash
  # If not using ANTHROPIC_API_KEY
  gh secret set CLAUDE_CODE_OAUTH_TOKEN
  ```

#### 1.3 Local Validation

- [ ] **YAML Syntax Check**
  ```bash
  # Install yamllint
  pip install yamllint

  # Check all workflows
  yamllint -d '{extends: relaxed}' .github/workflows/*.yml

  # Fix issues
  sed -i '' 's/[[:space:]]*$//' .github/workflows/*.yml
  echo '' >> .github/workflows/ci.yml
  echo '' >> .github/workflows/security.yml
  ```

- [ ] **Workflow Structure Validation**
  ```bash
  # Python validation (requires PyYAML)
  python3 << 'EOF'
  import yaml
  import sys

  workflows = [
      '.github/workflows/ci.yml',
      '.github/workflows/security.yml',
      '.github/workflows/auto-fix.yml'
  ]

  for wf in workflows:
      try:
          with open(wf) as f:
              yaml.safe_load(f)
          print(f"✅ {wf}: Valid")
      except Exception as e:
          print(f"❌ {wf}: {e}")
          sys.exit(1)

  print("\n✅ All workflows valid!")
  EOF
  ```

- [ ] **Action Versions Current**
  ```bash
  # Check for outdated actions (requires jq)
  grep -h "uses:" .github/workflows/*.yml | \
    grep -v "^#" | \
    sort -u | \
    while read -r line; do
      action=$(echo "$line" | awk '{print $2}')
      echo "Checking: $action"
    done

  # Update if needed:
  # actions/checkout@v4 → actions/checkout@v5
  # etc.
  ```

---

### Phase 2: Workflow Configuration ✅

#### 2.1 CI Workflow (`ci.yml`)

- [ ] **Verify Workflow Name**
  ```bash
  # Must match exactly in auto-fix.yml
  grep "^name:" .github/workflows/ci.yml
  # Should output: name: Basic CI

  # Verify auto-fix references it correctly
  grep "workflows:" .github/workflows/auto-fix.yml
  # Should output: workflows: ["Basic CI"]
  ```

- [ ] **Validate Triggers**
  ```yaml
  on:
    push:
      branches: [main]  # Check this matches your default branch
    pull_request:
      branches: [main]
  ```

- [ ] **Check Tool Versions**
  ```yaml
  # Python version
  run: uv python install 3.11  # Update if needed

  # Terraform version
  terraform_version: ~1.6.0  # Update if needed
  ```

#### 2.2 Security Workflow (`security.yml`)

- [ ] **Schedule Configuration**
  ```yaml
  schedule:
    - cron: '0 2 * * *'  # 2 AM UTC daily
  # Adjust timezone if needed: https://crontab.guru
  ```

- [ ] **Security Tools Enabled**
  ```bash
  # CodeQL should be enabled in repository settings
  # Settings → Security → Code security and analysis → CodeQL analysis
  ```

#### 2.3 Auto-Fix Workflow (`auto-fix.yml`)

- [ ] **Workflow Trigger Configured**
  ```yaml
  workflow_run:
    workflows: ["Basic CI"]  # Must match ci.yml name exactly
    types: [completed]
  ```

- [ ] **Branch Strategy Settings**
  ```yaml
  env:
    MAX_RETRY_ATTEMPTS: 3
    CLEANUP_THRESHOLD: 10  # Adjust based on repository activity
  ```

- [ ] **Claude Configuration**
  ```yaml
  claude_args: "--max-turns 15 --model claude-sonnet-4-20250514"
  # Adjust model and turns based on complexity
  ```

- [ ] **Permission Acknowledgement**
  ```yaml
  acknowledge-dangerously-skip-permissions-responsibility: "true"
  # Required for auto-fix functionality
  ```

---

### Phase 3: Testing ✅

#### 3.1 Dry Run Tests

- [ ] **Test Workflow Syntax**
  ```bash
  # GitHub doesn't provide local workflow validation
  # Best practice: commit to test branch first

  git checkout -b test-workflows
  git add .github/workflows/
  git commit -m "test: validate workflow syntax"
  git push -u origin test-workflows

  # Check for syntax errors in Actions tab
  ```

- [ ] **Test Auto-Fix Workflow (Manual Trigger)**
  ```bash
  # Create test branch with intentional errors
  git checkout -b test-auto-fix

  # Create test file with errors
  cat > test_errors.py << 'EOF'
  # Intentional syntax error
  def broken_function()
      return "missing colon"

  # Formatting issue
  def  poorly_formatted(x,y,  z  ):
      result=x+y*z
      return result
  EOF

  git add test_errors.py
  git commit -m "test: add file with errors"
  git push -u origin test-auto-fix

  # Create PR
  gh pr create --title "Test Auto-Fix" --body "Testing auto-fix workflow"

  # Wait for CI to fail
  gh run watch

  # Auto-fix should trigger automatically
  # Or trigger manually:
  gh workflow run auto-fix.yml -f pr_branch=test-auto-fix -f force_run=true
  ```

- [ ] **Test Comprehensive Validation**
  ```bash
  # Run the test-auto-fix workflow
  gh workflow run test-auto-fix.yml \
    -f test_type=all \
    -f create_issues=true

  # Monitor execution
  gh run watch

  # Review results in Actions tab
  # Should detect 23+ error types
  ```

#### 3.2 Integration Tests

- [ ] **Test Claude Integration**
  ```bash
  # Verify API connectivity
  python3 << 'EOF'
  import os
  from anthropic import Anthropic

  client = Anthropic(api_key=os.environ.get('ANTHROPIC_API_KEY'))

  try:
      response = client.messages.create(
          model="claude-3-haiku-20240307",
          max_tokens=50,
          messages=[{"role": "user", "content": "Respond with 'OK' if you receive this."}]
      )
      print(f"✅ Claude API: {response.content[0].text}")
  except Exception as e:
      print(f"❌ Claude API error: {e}")
  EOF
  ```

- [ ] **Test Fork PR Scenario**
  ```bash
  # Create fork (if you have one) and test
  # Or simulate fork behavior by checking logic:

  # Review auto-fix.yml lines 114-123 for fork detection
  # Verify branch creation logic (lines 168-185)
  ```

- [ ] **Test Same-Repo PR Scenario**
  ```bash
  # This is the standard PR flow
  # Create branch from same repo
  git checkout -b same-repo-test
  echo "def test(): pass" > test.py
  git add test.py
  git commit -m "test: same-repo PR"
  git push -u origin same-repo-test
  gh pr create --title "Test Same Repo" --body "Testing same-repo flow"
  ```

#### 3.3 Edge Case Testing

- [ ] **Test No API Key Scenario**
  ```bash
  # Temporarily remove secret (in a test repo!)
  gh secret remove ANTHROPIC_API_KEY
  gh secret remove CLAUDE_CODE_OAUTH_TOKEN

  # Trigger workflow - should fail gracefully with clear error
  gh workflow run auto-fix.yml -f pr_branch=test

  # Restore secrets
  gh secret set ANTHROPIC_API_KEY
  ```

- [ ] **Test No Changes Scenario**
  ```bash
  # Create PR with no actual errors
  git checkout -b no-errors-test
  echo "def valid_function():\n    return True" > valid.py
  git add valid.py
  git commit -m "test: valid code"
  git push -u origin no-errors-test
  gh pr create --title "Test No Errors" --body "Should pass CI"

  # CI should pass, auto-fix should not trigger
  ```

- [ ] **Test Concurrent PRs**
  ```bash
  # Create multiple PRs with errors simultaneously
  for i in {1..3}; do
    git checkout -b concurrent-test-$i
    echo "def error$i() return 'syntax error'" > test$i.py
    git add test$i.py
    git commit -m "test: concurrent PR $i"
    git push -u origin concurrent-test-$i
    gh pr create --title "Concurrent Test $i" --body "Testing concurrent auto-fixes" &
  done
  wait

  # Each should get unique fix branch (timestamp-based)
  # Monitor: gh run list --workflow=auto-fix.yml
  ```

---

### Phase 4: Security Validation ✅

#### 4.1 Secret Security

- [ ] **Verify Secrets Not in Logs**
  ```bash
  # Review recent workflow runs
  gh run list --workflow=auto-fix.yml --limit 5

  # View logs for each run
  gh run view <run-id> --log

  # Search for any leaked secrets (should find none)
  gh run view <run-id> --log | grep -i "sk-ant-" || echo "✅ No secrets leaked"
  ```

- [ ] **Check Secret Masking**
  ```bash
  # Secrets should appear as ***
  # Verify in Actions tab → Workflow run → Logs
  # Look for lines containing secret references
  ```

#### 4.2 Permission Validation

- [ ] **Verify Minimal Permissions**
  ```yaml
  # ci.yml should have:
  permissions:
    contents: read
    security-events: write

  # auto-fix.yml should have:
  permissions:
    contents: write
    pull-requests: write
    actions: read
    id-token: write

  # No additional unnecessary permissions
  ```

- [ ] **Test Permission Boundaries**
  ```bash
  # Auto-fix should NOT be able to:
  # - Modify workflow files in .github/workflows/
  # - Access other repositories
  # - Modify branch protection rules

  # Verify by reviewing auto-fix.yml prompt (lines 304-305)
  grep "DON'T.*workflows" .github/workflows/auto-fix.yml
  ```

#### 4.3 Code Injection Prevention

- [ ] **Verify Input Validation**
  ```bash
  # Check that user inputs are validated
  # Review auto-fix.yml lines 74-126 (PR determination logic)
  # Should handle malicious inputs gracefully
  ```

- [ ] **Test Command Injection**
  ```bash
  # Create PR with special characters in branch name
  git checkout -b "test-;-injection"
  echo "test" > test.txt
  git add test.txt
  git commit -m "test: injection attempt"
  git push -u origin "test-;-injection" 2>&1 || echo "Branch name sanitized"

  # Auto-fix should handle safely with proper quoting
  ```

---

### Phase 5: Performance Validation ✅

#### 5.1 Execution Time

- [ ] **Benchmark CI Workflow**
  ```bash
  # Run CI multiple times and measure
  for i in {1..5}; do
    START=$(date +%s)
    gh workflow run ci.yml
    # Wait for completion
    gh run watch --exit-status
    END=$(date +%s)
    echo "Run $i: $((END - START))s"
  done

  # Target: <5 minutes for typical repository
  ```

- [ ] **Benchmark Auto-Fix Workflow**
  ```bash
  # Measure auto-fix execution time
  # Create PR with errors and monitor

  START=$(date +%s)
  # Create PR with errors (from earlier tests)
  # Wait for auto-fix completion
  gh run watch --exit-status
  END=$(date +%s)

  echo "Auto-fix duration: $((END - START))s"
  # Target: <10 minutes including Claude analysis
  ```

#### 5.2 Resource Usage

- [ ] **Monitor Actions Minutes**
  ```bash
  # Check repository Actions usage
  gh api repos/{owner}/{repo}/actions/billing

  # Set up alerts if approaching limits:
  # Settings → Billing → Usage alerts
  ```

- [ ] **Optimize for Cost**
  ```bash
  # Review conditional execution
  grep "if: hashFiles" .github/workflows/ci.yml

  # Ensure steps only run when necessary
  # Prevents wasted Actions minutes
  ```

---

### Phase 6: Documentation ✅

#### 6.1 Internal Documentation

- [ ] **Update README**
  ```bash
  # Add workflow badges
  cat >> README.md << 'EOF'

  ## CI/CD Status

  ![CI](https://github.com/{owner}/{repo}/workflows/Basic%20CI/badge.svg)
  ![Security](https://github.com/{owner}/{repo}/workflows/Security%20Checks/badge.svg)
  ![Auto-Fix](https://github.com/{owner}/{repo}/workflows/Auto%20Fix%20CI%20Failures/badge.svg)

  EOF
  ```

- [ ] **Document Setup Process**
  ```bash
  # Create CONTRIBUTING.md with workflow info
  cat > CONTRIBUTING.md << 'EOF'
  # Contributing Guidelines

  ## Automated CI/CD

  This repository uses automated workflows:
  - **CI**: Runs on every PR
  - **Auto-Fix**: Automatically fixes CI failures
  - **Security**: Daily security scans

  ### Auto-Fix Workflow
  If your PR fails CI, the auto-fix workflow will:
  1. Analyze the failure
  2. Apply fixes automatically
  3. Push to your branch (same-repo) or create a fix PR (fork)

  EOF
  ```

- [ ] **Create Troubleshooting Guide**
  ```bash
  # Link to docs/troubleshooting.md (created separately)
  ```

#### 6.2 Team Communication

- [ ] **Notify Team**
  ```markdown
  # Team Notification Template

  Subject: New Auto-Fix CI/CD Workflows Deployed

  Hi team,

  We've deployed automated CI/CD workflows:

  **What Changed:**
  - CI now runs on all PRs
  - Failed CI runs trigger auto-fix workflow
  - Security scans run daily

  **How It Helps:**
  - Faster feedback on code issues
  - Automatic fixes for common problems
  - Reduced manual intervention

  **What You Need to Do:**
  - Nothing! Workflows run automatically
  - Review auto-fix PRs if your PR is from a fork
  - Check Actions tab if curious about execution

  **Documentation:**
  - Setup: docs/pre-deployment-checklist.md
  - Troubleshooting: docs/troubleshooting.md
  - Validation: docs/validation-results.md

  Questions? Reply to this thread.
  ```

---

### Phase 7: Monitoring Setup ✅

#### 7.1 GitHub Notifications

- [ ] **Enable Workflow Notifications**
  ```bash
  # Settings → Notifications → GitHub Actions
  # Enable:
  # - Failed workflow runs
  # - Successful workflow runs (optional)
  ```

- [ ] **Set Up Email Alerts**
  ```bash
  # Settings → Notifications → Email preferences
  # Configure workflow notification preferences
  ```

#### 7.2 Metrics Dashboard

- [ ] **Track Key Metrics**
  ```bash
  # Create monitoring script
  cat > scripts/monitor-workflows.sh << 'EOF'
  #!/bin/bash

  echo "=== Workflow Metrics ==="
  echo ""

  # CI success rate
  TOTAL_CI=$(gh run list --workflow=ci.yml --limit 100 --json conclusion | jq length)
  SUCCESS_CI=$(gh run list --workflow=ci.yml --limit 100 --json conclusion | jq '[.[] | select(.conclusion=="success")] | length')
  echo "CI Success Rate: $((SUCCESS_CI * 100 / TOTAL_CI))%"

  # Auto-fix success rate
  TOTAL_FIX=$(gh run list --workflow=auto-fix.yml --limit 100 --json conclusion | jq length)
  SUCCESS_FIX=$(gh run list --workflow=auto-fix.yml --limit 100 --json conclusion | jq '[.[] | select(.conclusion=="success")] | length')
  echo "Auto-Fix Success Rate: $((SUCCESS_FIX * 100 / TOTAL_FIX))%"

  # Average execution time
  echo ""
  echo "Recent CI runs:"
  gh run list --workflow=ci.yml --limit 5

  EOF

  chmod +x scripts/monitor-workflows.sh
  ```

#### 7.3 Alert Configuration

- [ ] **Set Up Failure Alerts**
  ```bash
  # Use GitHub's built-in notifications
  # Or integrate with:
  # - Slack (via Actions)
  # - Email (via Settings)
  # - PagerDuty (for critical workflows)
  ```

---

### Phase 8: Rollout Strategy ✅

#### 8.1 Gradual Rollout

- [ ] **Phase 1: Test Branch**
  ```bash
  # Deploy to test branch first
  git checkout -b deploy-workflows
  git add .github/workflows/
  git commit -m "chore(ci): deploy auto-fix workflows"
  git push -u origin deploy-workflows

  # Test for 1-2 days
  # Monitor: gh run list
  ```

- [ ] **Phase 2: Staging (if applicable)**
  ```bash
  # If you have a staging environment
  # Test there before production
  ```

- [ ] **Phase 3: Production**
  ```bash
  # Merge to main after successful testing
  gh pr create --title "Deploy Auto-Fix Workflows" \
               --body "See validation: docs/validation-results.md"

  # After review and approval:
  gh pr merge --merge
  ```

#### 8.2 Rollback Plan

- [ ] **Document Rollback Procedure**
  ```bash
  # In case of issues, disable workflows:

  # Option 1: Disable via UI
  # Settings → Actions → Disable workflow

  # Option 2: Rename workflow files
  git mv .github/workflows/auto-fix.yml .github/workflows/auto-fix.yml.disabled
  git commit -m "chore(ci): disable auto-fix temporarily"
  git push

  # Option 3: Revert commit
  git revert <commit-hash>
  git push
  ```

---

### Phase 9: Post-Deployment ✅

#### 9.1 First Week Monitoring

- [ ] **Day 1-3: Intensive Monitoring**
  ```bash
  # Check workflow runs every few hours
  gh run list --limit 20

  # Review any failures
  gh run view <run-id> --log

  # Track metrics
  ./scripts/monitor-workflows.sh
  ```

- [ ] **Day 4-7: Regular Monitoring**
  ```bash
  # Daily metrics review
  # Weekly summary to team
  ```

#### 9.2 Fine-Tuning

- [ ] **Adjust Claude Parameters**
  ```yaml
  # Based on first week results, adjust:
  claude_args: "--max-turns 15"  # Increase if complex issues not resolved
  # or
  claude_args: "--max-turns 10"  # Decrease if hitting API limits
  ```

- [ ] **Optimize Cleanup Threshold**
  ```yaml
  env:
    CLEANUP_THRESHOLD: 10  # Adjust based on branch accumulation
  ```

- [ ] **Update Error Patterns**
  ```yaml
  # If Claude misses specific errors, update prompt in auto-fix.yml
  # Add new error codes to the detection list
  ```

#### 9.3 Team Feedback

- [ ] **Collect Feedback**
  ```markdown
  # Send survey to team:

  1. Have you seen the auto-fix workflow in action?
  2. Did it successfully fix your CI failures?
  3. Any issues or concerns?
  4. Suggestions for improvement?
  ```

- [ ] **Iterate Based on Feedback**
  ```bash
  # Implement improvements based on team input
  # Update documentation as needed
  ```

---

## Final Checklist Summary

### Critical (Must Complete)

- [ ] Set `ANTHROPIC_API_KEY` or `CLAUDE_CODE_OAUTH_TOKEN`
- [ ] Set `PAT_TOKEN` (recommended)
- [ ] Verify workflow permissions in repository settings
- [ ] Test workflows with intentional errors
- [ ] Document setup for team

### Important (Should Complete)

- [ ] Fix YAML formatting issues
- [ ] Set up monitoring and alerts
- [ ] Create rollback plan
- [ ] Update README with badges
- [ ] Test edge cases

### Nice to Have (Can Complete Later)

- [ ] Optimize CI job parallelization
- [ ] Add dependency review
- [ ] Set up metrics dashboard
- [ ] Integrate with Slack/PagerDuty
- [ ] Create video tutorial for team

---

## Success Criteria

✅ **Deployment is successful if:**

1. CI workflow runs on every PR
2. Security workflow runs on push and daily
3. Auto-fix workflow triggers on CI failures
4. Claude successfully fixes common errors (>80% success rate)
5. No secrets leaked in logs
6. Team understands new workflows
7. Monitoring is in place

---

## Quick Reference Commands

```bash
# View workflow status
gh run list --limit 10

# Trigger manual test
gh workflow run test-auto-fix.yml -f test_type=all

# Check secrets
gh secret list

# Monitor specific run
gh run watch <run-id>

# View logs
gh run view <run-id> --log

# Disable workflow (emergency)
gh workflow disable auto-fix.yml

# Re-enable workflow
gh workflow enable auto-fix.yml
```

---

## Support

If you encounter issues during deployment:

1. **Check validation report:** `docs/validation-results.md`
2. **Review troubleshooting guide:** `docs/troubleshooting.md`
3. **Check workflow logs:** Actions tab → Failed run → View logs
4. **Search issues:** GitHub repository issues
5. **Open new issue:** Provide workflow run ID and error logs

---

**Checklist Version:** 1.0.0
**Last Updated:** 2025-11-06
**Next Review:** After first week of deployment
