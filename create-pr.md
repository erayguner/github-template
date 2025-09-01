# Test Auto-Fix Workflow PR

## Purpose
This PR tests the auto-fix workflow by introducing multiple syntax errors that should trigger:

1. **CI Failure** - Basic CI workflow will fail due to Python syntax errors
2. **Auto-Fix Activation** - Workflow should trigger automatically on CI failure  
3. **Claude Code Fixes** - Claude should fix all syntax errors with new permissions
4. **Automatic Commit** - Fixed code should be committed and pushed back to this branch

## Syntax Errors Introduced

### Line 4: Missing colon in function definition
```python
def greet(name)   # Missing colon - should trigger auto-fix
```

### Line 16: Invalid assignment syntax  
```python
result divide(10, 0)  # Invalid syntax - should trigger auto-fix
```

### Line 25: Missing colon in test function
```python
def test_multiply()   # Missing colon - should trigger auto-fix
```

### Line 9: Non-existent import
```python
import non_existent_module
```

## Expected Auto-Fix Workflow Steps

1. ✅ **PR Created** - This PR with syntax errors
2. ⏳ **CI Runs** - Basic CI workflow executes and fails  
3. ⏳ **Auto-Fix Triggers** - Auto-fix workflow activates on CI failure
4. ⏳ **Claude Fixes Code** - Claude Code action applies fixes with new permissions
5. ⏳ **Changes Committed** - Fixed code is committed back to this branch
6. ⏳ **CI Re-runs** - CI runs again on fixed code and passes
7. ⏳ **PR Comment** - Auto-fix workflow adds explanation comment

## Testing the Improvements

This tests the recent fixes:
- ✅ Claude Code action permissions (`acknowledge-dangerously-skip-permissions-responsibility`)
- ✅ Broader workflow trigger conditions (removed PR-only restriction)
- ✅ PAT_TOKEN support for workflow re-triggering
- ✅ Enhanced PR comments explaining changes

**Branch:** test-auto-fix-pr → main