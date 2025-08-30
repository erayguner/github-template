# Pull Request Template

## Description

Brief description of changes and motivation.

## Type of Change

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Maintenance/refactoring
- [ ] 🔒 Security improvement
- [ ] ⚡ Performance improvement

## Project Type

- [ ] 🏗️ Terraform infrastructure
- [ ] 🐍 Python code
- [ ] 🔄 GitHub Actions workflow
- [ ] ⚙️ Pre-commit configuration
- [ ] 📋 Template/configuration

## Checklist

### Code Quality
- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Code is properly commented (if complex)
- [ ] No debugging code left in changes

### Testing
- [ ] New tests added for new functionality
- [ ] All existing tests pass
- [ ] Test coverage maintained or improved
- [ ] Manual testing completed (if applicable)

### Security
- [ ] No secrets or credentials committed
- [ ] Security implications considered and documented
- [ ] Dependencies updated if needed
- [ ] Security scanning tools pass

### Infrastructure (Terraform)
- [ ] Terraform validate passes
- [ ] Terraform plan reviewed
- [ ] tfsec/Checkov security scans pass
- [ ] No sensitive values in code

### Python
- [ ] Ruff linting and formatting applied
- [ ] Type hints added where appropriate
- [ ] mypy type checking passes
- [ ] pytest tests pass with coverage

### Documentation
- [ ] README updated (if needed)
- [ ] Code comments updated
- [ ] API documentation updated (if applicable)
- [ ] CHANGELOG updated

## Testing Instructions

Please describe the tests that you ran to verify your changes:

1. **Unit Tests**: 
   ```bash
   # Commands to run unit tests
   ```

2. **Integration Tests**:
   ```bash
   # Commands to run integration tests
   ```

3. **Manual Testing**:
   ```
   # Steps for manual verification
   ```

## Screenshots (if applicable)

Add screenshots to help explain your changes.

## Breaking Changes

If this is a breaking change, please describe:
1. What breaks
2. How users should update their code
3. Migration guide (if needed)

## Additional Notes

Any additional information, concerns, or questions for reviewers.

## Reviewer Notes

- [ ] Code review completed
- [ ] Architecture/design approved
- [ ] Security review completed (if applicable)
- [ ] Performance impact assessed
- [ ] Documentation adequate

---

**By submitting this PR, I confirm that:**
- [ ] I have read and agree to the contribution guidelines
- [ ] I have tested my changes thoroughly
- [ ] I understand that this will be publicly visible