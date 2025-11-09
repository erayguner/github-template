.PHONY: help setup setup-python setup-terraform install-hooks test test-python test-terraform lint lint-python lint-terraform format format-python format-terraform clean clean-python clean-terraform validate validate-all security pre-commit

# Default target - show help
help:
	@echo "🚀 Multi-Language Repository Template - Makefile Commands"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup              - Complete project setup (Python + Terraform + hooks)"
	@echo "  make setup-python       - Setup Python environment with UV"
	@echo "  make setup-terraform    - Setup Terraform environment"
	@echo "  make install-hooks      - Install pre-commit hooks"
	@echo ""
	@echo "Testing Commands:"
	@echo "  make test               - Run all tests (Python + Terraform)"
	@echo "  make test-python        - Run Python tests with coverage"
	@echo "  make test-terraform     - Run Terraform validation"
	@echo ""
	@echo "Linting Commands:"
	@echo "  make lint               - Run all linters (Python + Terraform)"
	@echo "  make lint-python        - Run Python linters (Ruff)"
	@echo "  make lint-terraform     - Run Terraform linters (fmt + validate)"
	@echo ""
	@echo "Formatting Commands:"
	@echo "  make format             - Format all code (Python + Terraform)"
	@echo "  make format-python      - Format Python code with Ruff"
	@echo "  make format-terraform   - Format Terraform code"
	@echo ""
	@echo "Security Commands:"
	@echo "  make security           - Run security checks (Bandit + detect-secrets)"
	@echo "  make pre-commit         - Run all pre-commit hooks"
	@echo ""
	@echo "Validation Commands:"
	@echo "  make validate-all       - Run all validation checks"
	@echo ""
	@echo "Cleanup Commands:"
	@echo "  make clean              - Clean all temporary files"
	@echo "  make clean-python       - Clean Python cache and virtual env"
	@echo "  make clean-terraform    - Clean Terraform state and cache"

# ============================================================================
# Setup Commands
# ============================================================================

setup: setup-python setup-terraform install-hooks
	@echo "✅ Complete setup finished!"

setup-python:
	@echo "🐍 Setting up Python environment..."
	@cd python && uv sync --group dev
	@echo "✅ Python environment ready!"

setup-terraform:
	@echo "🏗️  Setting up Terraform..."
	@if [ ! -f terraform/terraform.tfvars ]; then \
		cp terraform/terraform.tfvars.example terraform/terraform.tfvars; \
		echo "📝 Created terraform.tfvars - please configure it before applying!"; \
	fi
	@cd terraform && terraform init -backend=false
	@echo "✅ Terraform ready!"

install-hooks:
	@echo "🪝 Installing pre-commit hooks..."
	@pre-commit install
	@echo "✅ Pre-commit hooks installed!"

# ============================================================================
# Testing Commands
# ============================================================================

test: test-python test-terraform
	@echo "✅ All tests passed!"

test-python:
	@echo "🧪 Running Python tests..."
	@cd python && uv run pytest --cov=src --cov-report=term-missing --cov-report=html

test-terraform:
	@echo "🔍 Validating Terraform..."
	@cd terraform && terraform init -backend=false && terraform validate

# ============================================================================
# Linting Commands
# ============================================================================

lint: lint-python lint-terraform
	@echo "✅ All linting passed!"

lint-python:
	@echo "🔍 Linting Python code..."
	@cd python && uv run ruff check .

lint-terraform:
	@echo "🔍 Linting Terraform code..."
	@cd terraform && terraform fmt -check -diff -recursive

# ============================================================================
# Formatting Commands
# ============================================================================

format: format-python format-terraform
	@echo "✅ All code formatted!"

format-python:
	@echo "✨ Formatting Python code..."
	@cd python && uv run ruff check --fix . && uv run ruff format .

format-terraform:
	@echo "✨ Formatting Terraform code..."
	@cd terraform && terraform fmt -recursive

# ============================================================================
# Security Commands
# ============================================================================

security:
	@echo "🔒 Running security checks..."
	@echo "Running Bandit security scan..."
	@cd python && uv run bandit -r src/ -f screen
	@echo "Running detect-secrets..."
	@detect-secrets scan --baseline .secrets.baseline
	@echo "✅ Security checks completed!"

pre-commit:
	@echo "🪝 Running pre-commit hooks..."
	@pre-commit run --all-files

# ============================================================================
# Validation Commands
# ============================================================================

validate-all: lint test security
	@echo "✅ All validation checks passed!"

# ============================================================================
# Cleanup Commands
# ============================================================================

clean: clean-python clean-terraform
	@echo "🧹 Cleanup completed!"

clean-python:
	@echo "🧹 Cleaning Python cache..."
	@find python -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find python -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find python -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find python -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	@find python -type f -name "*.pyc" -delete 2>/dev/null || true
	@rm -rf python/htmlcov python/.coverage 2>/dev/null || true
	@echo "✅ Python cache cleaned!"

clean-terraform:
	@echo "🧹 Cleaning Terraform cache..."
	@find terraform -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find terraform -type f -name "*.tfstate*" -delete 2>/dev/null || true
	@find terraform -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "✅ Terraform cache cleaned!"

# ============================================================================
# Quick Commands
# ============================================================================

# Quick check before committing
check: lint test
	@echo "✅ Quick check passed! Ready to commit."

# Development workflow
dev: clean format test
	@echo "✅ Development cycle completed!"
