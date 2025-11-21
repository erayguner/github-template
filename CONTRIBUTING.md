# Contributing to Multi-Language Repository Template

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🎯 Ways to Contribute

- 🐛 **Bug Reports**: Submit detailed bug reports with reproduction steps
- ✨ **Feature Requests**: Propose new features or improvements
- 📖 **Documentation**: Improve or expand documentation
- 💻 **Code**: Submit bug fixes or new features
- 🔍 **Code Review**: Review pull requests from other contributors

## 🚀 Getting Started

### Prerequisites

- Python 3.11+ with UV package manager
- Terraform 1.10+
- Git
- Pre-commit hooks

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/erayguner/github-template.git
   cd github-template
   ```

2. **Setup Python Environment**
   ```bash
   cd python
   uv sync --group dev
   ```

3. **Install Pre-commit Hooks**
   ```bash
   pre-commit install
   ```

4. **Verify Setup**
   ```bash
   # Run Python tests
   cd python
   uv run pytest

   # Validate Terraform
   cd terraform
   terraform init -backend=false
   terraform validate
   ```

## 📝 Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Changes

- Write clean, well-documented code
- Follow existing code style and conventions
- Add tests for new functionality
- Update documentation as needed

### 3. Run Tests and Linters

```bash
# Python
cd python
uv run ruff check .
uv run ruff format .
uv run pytest --cov=src

# Terraform
cd terraform
terraform fmt -recursive
terraform validate
```

### 4. Commit Changes

```bash
git add .
git commit -m "type: brief description"
```

**Commit Message Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Build process or auxiliary tool changes

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub with:
- Clear description of changes
- Reference to related issues
- Screenshots (if applicable)

## 🧪 Testing Guidelines

### Python Tests

- Write tests for all new functionality
- Maintain or improve code coverage (target: >80%)
- Use pytest fixtures and parametrization
- Mark slow tests with `@pytest.mark.slow`

### Terraform Tests

- Validate all Terraform configurations
- Test with both AWS and GCP provider configurations
- Ensure backward compatibility

## 📋 Code Style Guidelines

### Python

- Follow PEP 8 (enforced by Ruff)
- Use type hints for all function signatures
- Write docstrings for public functions and classes
- Maximum line length: 88 characters
- Use descriptive variable names

### Terraform

- Use terraform fmt for formatting
- Follow HashiCorp's style guide
- Use meaningful resource names
- Document all variables and outputs
- Use locals for complex logic

### Documentation

- Use clear, concise language
- Include code examples
- Update README.md for user-facing changes
- Use proper Markdown formatting

## 🔒 Security

- Never commit secrets or credentials
- Run pre-commit hooks (includes secret detection)
- Report security vulnerabilities privately (see SECURITY.md)
- Follow principle of least privilege

## 📦 Pull Request Process

1. **Before Submitting:**
   - Ensure all tests pass
   - Update documentation
   - Run pre-commit hooks
   - Rebase on latest main branch

2. **PR Requirements:**
   - Clear, descriptive title
   - Detailed description of changes
   - Link to related issues
   - All CI checks passing
   - At least one approval from maintainers

3. **Review Process:**
   - Maintainers will review within 3-5 business days
   - Address review comments
   - Keep PR focused and reasonably sized
   - Squash commits before merge (if requested)

## 🤝 Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## 📞 Getting Help

- 📖 Check existing documentation
- 🔍 Search existing issues
- 💬 Ask questions in discussions
- 📧 Contact maintainers

## 🏆 Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes (for significant contributions)
- Special mentions for outstanding contributions

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing! Your efforts help make this project better for everyone.** 🎉
