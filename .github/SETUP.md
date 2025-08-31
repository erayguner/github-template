# 🔧 Repository Setup Guide

This guide helps you configure the Claude Auto-Fix CI workflow for your repository.

## 📋 Quick Setup Checklist

- [ ] Configure GitHub Secrets
- [ ] Set up branch protection rules
- [ ] Test the workflow
- [ ] Configure repository permissions

## 🔑 Required GitHub Secrets

Navigate to **Settings → Secrets and Variables → Actions** and add:

### Required
- `ANTHROPIC_API_KEY`: Your Claude API key for intelligent auto-fixes
  - Get from: https://console.anthropic.com/
  - Permissions: Full API access

### Optional (Recommended)
- `GITHUB_TOKEN`: Already provided by GitHub
  - Used for: Commits, PRs, and API access
  - Auto-configured with proper permissions

### 2. Workflow Configuration

The workflow is automatically configured to:
- ✅ Trigger on failed CI runs for pull requests
- ✅ Support manual triggers with custom options
- ✅ Handle both same-repo and fork scenarios
- ✅ Auto-detect and fix multiple languages (Python, Terraform, Shell, JS/TS, YAML)

### 3. Permissions Setup

Ensure your repository has these permissions:
```yaml
permissions:
  contents: write
  pull-requests: write
  actions: read
  id-token: write
```

## 🎯 How It Works

### Automatic Triggers
1. **PR CI Failures**: Automatically runs when any CI workflow fails on a PR
2. **Workflow Dependencies**: Links to your main CI workflow (currently set to "Basic CI")

### Manual Triggers
Use the "Actions" tab to manually trigger:
- **pr_branch**: Target branch to fix (required)
- **base_branch**: Base branch (default: main)
- **force_run**: Run even if no failures detected

### Fix Process
1. **Detection**: Analyzes failed CI jobs and error logs
2. **Language-Specific Fixes**: Applies targeted fixes for:
   - 🐍 **Python**: Syntax, imports, formatting, tests
   - 🏗️ **Terraform**: HCL syntax, resources, validation
   - 📜 **Shell**: Bash syntax, variables, shellcheck issues
   - 🟨 **JavaScript/TypeScript**: ESLint, formatting, type errors
   - 📄 **YAML**: Indentation, GitHub Actions syntax
3. **Verification**: Re-runs language-specific checks
4. **Commit**: Creates detailed commit with fixes
5. **PR/Comment**: Either pushes directly or creates PR with fixes

## 🔄 Branch Strategies

### Same Repository PRs
- Fixes are pushed directly to the PR branch
- Adds comment to the original PR with details

### Fork PRs
- Creates new fix branch: `claude-auto-fix-ci-{branch}-{run-id}-{timestamp}`
- Creates separate PR with fixes
- Links back to original PR

## ⚙️ Configuration Options

### Update CI Workflow Name
In `.github/workflows/auto-fix.yml`, update line 5:
```yaml
workflows: ["Your CI Workflow Name"]  # Change this to match your CI workflow
```

### Language-Specific Settings
The workflow automatically detects and configures tools for:
- **Python**: flake8, black, pytest, py_compile
- **Node.js**: eslint, prettier, typescript, npm scripts
- **Terraform**: terraform fmt, validate
- **Shell**: shellcheck, bash syntax
- **Go**: gofmt, go vet, staticcheck
- **Rust**: rustfmt, clippy

## 🚨 Troubleshooting

### Common Issues

#### "Missing required API keys"
- Ensure `ANTHROPIC_API_KEY` is set in repository secrets
- Verify the secret name is exactly `ANTHROPIC_API_KEY`

#### "No PR associated with workflow run"
- This happens for pushes to main branch (not PRs)
- Use manual trigger instead: provide `pr_branch` parameter

#### "Failed to create PR" (for forks)
- Check that `PAT_TOKEN` has sufficient permissions
- Ensure base branch exists and is accessible

#### Claude fixes failed
- Complex issues may require manual intervention
- Check the logs for specific error details
- API rate limits or connectivity issues

#### No changes committed
- Claude determined no fixes were needed
- Issues may require human review
- Check if files are in .gitignore

### Debug Mode
Enable debug logging by setting environment variable:
```yaml
env:
  ACTIONS_RUNNER_DEBUG: true
  ACTIONS_STEP_DEBUG: true
```

## 📊 Monitoring

### Success Indicators
- ✅ Commit pushed to branch
- ✅ PR comment or new PR created
- ✅ Language-specific verification passed

### Check Results
1. **Actions Tab**: View workflow run details
2. **PR Comments**: See summary of fixes applied
3. **Commit History**: Review detailed commit messages
4. **Artifacts**: Download reports for analysis

## 🔐 Security Considerations

### API Key Management
- Never commit API keys to the repository
- Use repository secrets only
- Rotate keys periodically

### Code Review
- Always review auto-generated fixes
- Verify fixes don't introduce security issues
- Test changes before merging

### Permissions
- Limit PAT_TOKEN scope to minimum required
- Use repository secrets, not environment variables
- Consider using GITHUB_TOKEN when possible

## 📝 Customization

### Modify Fix Prompts
Edit the `prompt` section in the workflow to:
- Add custom coding standards
- Include specific linting rules
- Add project-specific requirements

### Add Language Support
Extend the verification section to support additional languages:
```yaml
# Add new language verification
if find . -name "*.xyz" | head -1 | grep -q "\.xyz$"; then
  echo "🔧 Checking XYZ files..."
  # Add your language-specific checks
fi
```

### Custom Commit Messages
Modify the commit message template in the workflow:
```yaml
COMMIT_MSG="chore(ci): your custom message format"
```

## 📚 Examples

### Manual Trigger for Feature Branch
```
pr_branch: feature/new-api
base_branch: develop
force_run: true
```

### Testing with Fork
1. Fork the repository
2. Create PR from fork
3. Let CI fail
4. Workflow creates fix PR automatically

## 🆘 Support

### Getting Help
1. Check the [workflow logs](../../actions) for detailed error messages
2. Review this setup guide for common issues
3. Verify all required secrets are configured
4. Test with manual trigger first

### Reporting Issues
Include in your report:
- Repository name and setup
- Workflow run ID and logs
- Error messages and screenshots
- Steps to reproduce

---

🤖 **Ready to go?** The workflow is pre-configured and will activate automatically on the next CI failure!