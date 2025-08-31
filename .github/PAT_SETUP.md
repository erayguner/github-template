# Personal Access Token (PAT) Setup for Auto-Fix Workflow

## Why is PAT needed?

The default `GITHUB_TOKEN` has security restrictions that prevent triggering new workflow runs from automated commits. This is to prevent infinite loops of workflows triggering each other.

When Claude pushes fixes to a branch, the CI workflow won't automatically re-run with the default token.

## Setting up PAT_TOKEN

1. **Create a Personal Access Token:**
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token (classic)
   - Select scopes:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)
     - ✅ `write:packages` (if using packages)

2. **Add as Repository Secret:**
   - Go to your repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `PAT_TOKEN`
   - Value: Your generated token

## What happens with PAT_TOKEN

✅ **With PAT_TOKEN:**
- Claude pushes fixes → CI automatically re-runs → Tests pass ✅
- Full automated workflow cycle

❌ **Without PAT_TOKEN:**
- Claude pushes fixes → CI doesn't re-run → Manual trigger needed
- Still works, but requires manual intervention

## Security Notes

- PAT tokens have broader permissions than GITHUB_TOKEN
- Only add to trusted repositories
- Regularly rotate tokens
- Consider using fine-grained PATs for better security

## Alternative: Manual Trigger

If you don't want to use PAT, you can manually trigger CI after Claude pushes fixes:
- Go to Actions tab → Select your CI workflow → Run workflow