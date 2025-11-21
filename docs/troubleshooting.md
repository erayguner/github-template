# Troubleshooting Guide

## CI/CD Auto-Fix Workflow Issues

**Last Updated:** 2025-11-06

---

## Quick Diagnosis

### Is your workflow failing? Start here:

```bash
# Check recent workflow runs
gh run list --workflow=auto-fix.yml --limit 5

# View specific run
gh run view <run-id>

# See detailed logs
gh run view <run-id> --log

# Check workflow status
gh workflow view auto-fix.yml
```

---

## Common Issues

### 1. Auto-Fix Workflow Not Triggering

**Symptoms:**
- CI fails but auto-fix doesn't run
- No auto-fix workflow appears in Actions tab

**Possible Causes:**

#### A. Workflow name mismatch
```bash
# Check CI workflow name
grep "^name:" .github/workflows/ci.yml
# Output should be: name: Basic CI

# Check auto-fix reference
grep "workflows:" .github/workflows/auto-fix.yml
# Output should be: workflows: ["Basic CI"]
```

**Solution:**
```bash
# Update auto-fix.yml to match exact CI workflow name
# Edit line 5 in auto-fix.yml:
workflows: ["<exact-name-from-ci.yml>"]
```

#### B. Branch name filter blocking execution
```yaml
# auto-fix.yml line 38 prevents recursive execution
!startsWith(github.event.workflow_run.head_branch, 'claude-auto-fix-ci-')
```

**Solution:**
- Don't create branches starting with `claude-auto-fix-ci-`
- If testing, use different branch prefix

#### C. Workflow_run permission issue
```bash
# Check repository settings
Settings → Actions → General → Workflow permissions
# Should be: "Read and write permissions"
```

**Solution:**
```bash
# Enable workflow_run triggers:
Settings → Actions → General → Workflow permissions
→ Select "Read and write permissions"
→ Check "Allow GitHub Actions to create and approve pull requests"
```

---

### 2. Missing API Key Error

**Symptoms:**
```
Error: Missing required API keys. Please set either ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN
```

**Diagnosis:**
```bash
# Check if secrets are set
gh secret list

# Should see:
# ANTHROPIC_API_KEY  Updated YYYY-MM-DD
# or
# CLAUDE_CODE_OAUTH_TOKEN  Updated YYYY-MM-DD
```

**Solution:**
```bash
# Set the API key
gh secret set ANTHROPIC_API_KEY

# Or use OAuth token
gh secret set CLAUDE_CODE_OAUTH_TOKEN

# Verify it's set
gh secret list | grep -E "ANTHROPIC|CLAUDE"
```

**Test API key validity:**
```bash
# Export your key
export ANTHROPIC_API_KEY="sk-ant-..."

# Test with curl
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "content-type: application/json" \
     https://api.anthropic.com/v1/messages \
     -d '{
       "model": "claude-3-haiku-20240307",
       "max_tokens": 10,
       "messages": [{"role": "user", "content": "test"}]
     }'

# Should return JSON response, not 401 Unauthorized
```

---

### 3. Claude Fails to Make Fixes

**Symptoms:**
- Auto-fix runs but Claude step fails
- No changes pushed despite CI failures

**Possible Causes:**

#### A. API rate limiting
```bash
# Check logs for rate limit errors
gh run view <run-id> --log | grep -i "rate limit"
```

**Solution:**
```bash
# Wait for rate limit to reset (typically 1 minute)
# Or upgrade Anthropic API tier for higher limits

# Monitor usage:
# Visit: https://console.anthropic.com/account/billing
```

#### B. Claude timeout
```bash
# Check for timeout in logs
gh run view <run-id> --log | grep -i "timeout"
```

**Solution:**
```yaml
# Increase timeout in auto-fix.yml
timeout-minutes: 30  # Increase to 45 if complex repo
```

#### C. Permission denied for file modifications
```bash
# Check logs for permission errors
gh run view <run-id> --log | grep -i "permission denied"
```

**Solution:**
```yaml
# Verify auto-fix.yml has write permissions
permissions:
  contents: write  # Required
  pull-requests: write  # Required
```

#### D. Complex issues Claude can't fix
```bash
# Review what Claude attempted
gh run view <run-id> --log | grep -A 20 "Claude - Attempt"
```

**Solution:**
- Review the error types in CI logs
- Add specific error patterns to Claude's prompt in auto-fix.yml
- For very complex issues, manual intervention may be required

---

### 4. Push Fails After Fixes

**Symptoms:**
```
Error: failed to push some refs
Permission denied (publickey)
```

**Possible Causes:**

#### A. Missing write permissions
```yaml
# Check auto-fix.yml permissions section
permissions:
  contents: write  # Must be present
```

**Solution:**
```yaml
# Add to auto-fix.yml if missing
permissions:
  contents: write
  pull-requests: write
```

#### B. PAT_TOKEN missing for workflow triggering
```bash
# Check if PAT_TOKEN is set
gh secret list | grep PAT_TOKEN
```

**Solution:**
```bash
# Generate PAT with these scopes:
# - repo (full control)
# - workflow (update workflows)

# Create at: https://github.com/settings/tokens/new

# Set the secret
gh secret set PAT_TOKEN

# Paste the token when prompted
```

#### C. Branch protection blocking push
```bash
# Check branch protection rules
gh api repos/{owner}/{repo}/branches/main/protection
```

**Solution:**
```bash
# Option 1: Add bypass for GitHub Actions
Settings → Branches → Branch protection rules → main
→ "Allow specified actors to bypass required pull requests"
→ Add "github-actions[bot]"

# Option 2: Use separate fix branches (already implemented)
# Auto-fix creates claude-auto-fix-ci-* branches for forks
```

---

### 5. YAML Syntax Errors

**Symptoms:**
```
Error: .github/workflows/auto-fix.yml: unexpected workflow syntax
```

**Diagnosis:**
```bash
# Check YAML syntax
yamllint .github/workflows/*.yml

# Or use Python
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/auto-fix.yml'))"
```

**Common YAML Issues:**

#### A. Indentation errors
```yaml
# Wrong - inconsistent indentation
jobs:
  test:
   runs-on: ubuntu-latest
    steps:

# Correct - 2-space indentation
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
```

#### B. Missing colons
```yaml
# Wrong
permissions
  contents: write

# Correct
permissions:
  contents: write
```

#### C. Unquoted special characters
```yaml
# Wrong - unquoted $
run: echo ${{ secrets.API_KEY }}

# Correct - quoted
run: echo "${{ secrets.API_KEY }}"
```

**Solution:**
```bash
# Fix formatting
sed -i '' 's/[[:space:]]*$//' .github/workflows/auto-fix.yml

# Add newline at EOF
echo '' >> .github/workflows/auto-fix.yml

# Validate
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/auto-fix.yml')); print('✅ Valid')"
```

---

### 6. No PR Associated Error

**Symptoms:**
```
Error: No PR associated with this workflow run
```

**Cause:**
- Auto-fix triggered on push to main (not a PR)
- workflow_run event doesn't have PR context

**Solution:**
- This is expected behavior for non-PR events
- Auto-fix only works on PRs
- For main branch pushes, CI runs but auto-fix is skipped
- To fix issues on main: create a PR with fixes manually

---

### 7. Fork PR Not Getting Fixes

**Symptoms:**
- Fork PR fails CI
- Auto-fix runs but doesn't create PR

**Diagnosis:**
```bash
# Check if fork was detected
gh run view <run-id> --log | grep "same_repo"
# Should see: same_repo: false
```

**Possible Causes:**

#### A. Fix branch creation failed
```bash
# Check logs for branch creation
gh run view <run-id> --log | grep "Creating fix branch"
```

**Solution:**
```bash
# Verify repository has room for new branches
# Check if cleanup job is running (removes old fix branches)
gh run list --workflow=auto-fix.yml | grep cleanup
```

#### B. PR creation failed
```bash
# Check for PR creation errors
gh run view <run-id> --log | grep "Create PR for fixes"
```

**Solution:**
```yaml
# Ensure permissions allow PR creation
permissions:
  pull-requests: write  # Required for fork PRs
```

---

### 8. Workflow Takes Too Long

**Symptoms:**
- Workflow runs for 20+ minutes
- Eventually times out

**Diagnosis:**
```bash
# Check execution time
gh run view <run-id> --json timing --jq '.timing'
```

**Possible Causes:**

#### A. Claude analysis too slow
```bash
# Check Claude step duration
gh run view <run-id> --log | grep -A 5 "Claude - Attempt"
```

**Solution:**
```yaml
# Reduce max turns in auto-fix.yml
claude_args: "--max-turns 10"  # Down from 15

# Or use faster model
--model claude-3-haiku-20240307  # Instead of sonnet
```

#### B. Large repository
```bash
# Check repository size
du -sh .
```

**Solution:**
```yaml
# Add checkout depth limit
- uses: actions/checkout@v5
  with:
    fetch-depth: 1  # Only latest commit
```

#### C. Too many files to analyze
```bash
# Check file count
find . -name "*.py" | wc -l
```

**Solution:**
```yaml
# Update Claude prompt to focus on specific files
# auto-fix.yml line 256-360
prompt: |
  Focus only on files that failed linting:
  ${{ steps.details.outputs.failed_details }}
```

---

### 9. Security Scan False Positives

**Symptoms:**
- Security workflow flags non-issues
- TruffleHog finds false positive secrets

**Diagnosis:**
```bash
# Review security scan results
gh run view <run-id> --log | grep -i "secret"
```

**Solution:**

#### A. Exclude false positives
```yaml
# Add to .trufflehog.yml
allow:
  paths:
    - "test/*"  # Exclude test files
    - "docs/*"  # Exclude documentation

  patterns:
    - "EXAMPLE_API_KEY"  # Exclude example keys
```

#### B. Update tfsec configuration
```yaml
# Create tfsec.yml
exclude:
  - AWS001  # Specific rule to exclude
```

#### C. Ignore specific CodeQL alerts
```yaml
# In ci.yml, add query filters
- uses: github/codeql-action/init@v3
  with:
    queries: +security-extended,-js/incomplete-url-scheme-check
```

---

### 10. Cleanup Job Not Running

**Symptoms:**
- Many old `claude-auto-fix-ci-*` branches accumulate
- Repository gets cluttered

**Diagnosis:**
```bash
# Check cleanup job execution
gh run list --workflow=auto-fix.yml --json conclusion | \
  jq '[.[] | select(.conclusion != null)] | length'
```

**Solution:**

#### A. Manually trigger cleanup
```bash
# Delete old fix branches
git branch -r | grep "claude-auto-fix-ci-" | \
  head -n -10 | \
  sed 's/origin\///' | \
  xargs -I {} git push origin --delete {}
```

#### B. Adjust cleanup threshold
```yaml
# In auto-fix.yml
env:
  CLEANUP_THRESHOLD: 5  # Keep fewer branches
```

#### C. Force cleanup job
```yaml
# Modify cleanup condition in auto-fix.yml (line 382)
if: always()  # Run regardless of previous job status
```

---

## Advanced Troubleshooting

### Debug Mode

Enable verbose logging:

```yaml
# Add to any workflow step
- name: Debug step
  run: |
    set -x  # Enable bash debug mode
    echo "Current directory: $(pwd)"
    echo "Files: $(ls -la)"
    echo "Git status: $(git status)"
    # ... rest of step
```

### Inspect GitHub Context

```yaml
- name: Dump GitHub context
  run: |
    echo "Event: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
    echo "SHA: ${{ github.sha }}"
    echo "Actor: ${{ github.actor }}"
    echo "Repository: ${{ github.repository }}"

    # Full context
    echo '${{ toJSON(github) }}' | jq .
```

### Test Claude Locally

```bash
# Install Claude CLI
npm install -g claude-code-action

# Test with local repository
claude-code \
  --prompt "Fix Python syntax errors in test.py" \
  --api-key "$ANTHROPIC_API_KEY" \
  --max-turns 5
```

### Workflow Logs Analysis

```bash
# Download logs for offline analysis
gh run view <run-id> --log > workflow-log.txt

# Search for specific errors
grep -i "error" workflow-log.txt

# Extract timing information
grep "##\[group\]" workflow-log.txt

# Find all Claude responses
grep -A 50 "Claude - Attempt" workflow-log.txt
```

---

## Error Code Reference

### GitHub Actions Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 1 | Generic failure | Check logs for specific error |
| 128 | Git error | Check git configuration |
| 137 | Out of memory | Reduce concurrent operations |
| 143 | Timeout | Increase `timeout-minutes` |

### Auto-Fix Specific Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "No PR associated" | Push to main, not PR | Expected - only works on PRs |
| "Missing API keys" | Secrets not set | Set ANTHROPIC_API_KEY secret |
| "Permission denied" | Insufficient permissions | Add `contents: write` |
| "Could not create PR" | PR already exists or permissions | Check existing PRs |
| "Push failed after X attempts" | Branch protection or conflicts | Check protection rules |

---

## Performance Optimization

### Reduce Workflow Execution Time

1. **Use shallow clones:**
   ```yaml
   - uses: actions/checkout@v5
     with:
       fetch-depth: 1
   ```

2. **Cache dependencies:**
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.cache/pip
       key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
   ```

3. **Skip unnecessary steps:**
   ```yaml
   if: hashFiles('**/*.py') != ''  # Only run if Python files exist
   ```

4. **Parallelize jobs:**
   ```yaml
   strategy:
     matrix:
       check: [lint, security, test]
   ```

---

## Getting Help

### Self-Service

1. **Check validation results:** `docs/validation-results.md`
2. **Review workflow logs:** Actions tab → Failed run
3. **Search existing issues:** GitHub Issues tab

### Documentation

- **Setup Guide:** `docs/pre-deployment-checklist.md`
- **Validation Report:** `docs/validation-results.md`
- **This Guide:** `docs/troubleshooting.md`

### Support Channels

1. **GitHub Issues:** For bugs and feature requests
2. **GitHub Discussions:** For questions and community support
3. **Workflow Logs:** Always include when reporting issues

---

## Reporting Issues

When opening a GitHub issue, include:

1. **Workflow run ID:**
   ```bash
   gh run list --workflow=auto-fix.yml --limit 1
   ```

2. **Workflow logs:**
   ```bash
   gh run view <run-id> --log > logs.txt
   # Attach logs.txt to issue
   ```

3. **Repository configuration:**
   ```bash
   # Workflow file
   cat .github/workflows/auto-fix.yml

   # Secrets (names only, not values!)
   gh secret list
   ```

4. **Expected vs actual behavior**

5. **Steps to reproduce**

---

## Checklist for Debugging

When troubleshooting, work through this checklist:

- [ ] Verified secrets are set (`gh secret list`)
- [ ] Checked workflow permissions (Settings → Actions)
- [ ] Reviewed workflow logs (`gh run view <run-id> --log`)
- [ ] Validated YAML syntax (`yamllint .github/workflows/*.yml`)
- [ ] Confirmed workflow name matches in auto-fix.yml
- [ ] Tested API key validity (curl test)
- [ ] Checked branch protection rules
- [ ] Verified no syntax errors in workflows
- [ ] Reviewed recent changes to workflow files
- [ ] Tested with manual workflow dispatch
- [ ] Checked repository Actions quotas
- [ ] Reviewed GitHub Actions status page

---

**Last Updated:** 2025-11-06
**Version:** 1.0.0
**Next Review:** After first month of usage

**For urgent issues:** Check GitHub Actions status page: https://www.githubstatus.com/
