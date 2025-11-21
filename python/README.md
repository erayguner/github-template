<div align="center">

# ⚡ Python Project Setup

<p align="center">
  <strong>Modern Python development with UV package manager and Ruff linting</strong><br/>
  <em>10-100x faster than traditional tooling</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.11+"/>
  <img src="https://img.shields.io/badge/UV-Package_Manager-DE5FE9?style=for-the-badge&logo=astral&logoColor=white" alt="UV"/>
  <img src="https://img.shields.io/badge/Ruff-Linter-D7FF64?style=for-the-badge&logo=ruff&logoColor=black" alt="Ruff"/>
  <img src="https://img.shields.io/badge/pytest-Testing-0A9EDC?style=for-the-badge&logo=pytest&logoColor=white" alt="pytest"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/mypy-Type_Checking-2A6DB2?style=flat-square&logo=python&logoColor=white" alt="mypy"/>
  <img src="https://img.shields.io/badge/bandit-Security-black?style=flat-square&logo=python&logoColor=white" alt="bandit"/>
  <img src="https://img.shields.io/badge/coverage-Reports-success?style=flat-square&logo=codecov&logoColor=white" alt="coverage"/>
</p>

</div>

---

This directory contains a modern Python project setup with **UV** package manager and **Ruff** for ultra-fast development workflows.

## 🚀 **Why UV + Ruff?**

- **UV**: 10-100x faster than pip for package installation and management
- **Ruff**: 150-1000x faster than traditional Python tools (Black, Flake8, isort)
- **Modern Standards**: Uses pyproject.toml and dependency groups
- **Enterprise Ready**: Security scanning, type checking, comprehensive testing

## 🔄 **Linting & Quality Pipeline**

Our code quality workflow integrates multiple tools that work together seamlessly:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Code Quality Pipeline                             │
└─────────────────────────────────────────────────────────────────────────┘

    Your Code (*.py)
         │
         ├──────────────┬──────────────┬──────────────┬──────────────┐
         ▼              ▼              ▼              ▼              ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
    │  Ruff   │   │  mypy   │   │ Bandit  │   │ pytest  │   │ Safety  │
    │ Linter  │   │  Type   │   │Security │   │  Tests  │   │  Deps   │
    └─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
         │              │              │              │              │
         ├──────────────┼──────────────┼──────────────┼──────────────┤
         ▼              ▼              ▼              ▼              ▼

    • Style         • Types       • Vulns       • Coverage    • CVEs
    • Format        • Annotations • Hardcoded   • Unit Tests  • Outdated
    • Imports       • Contracts   • Injection   • Integration • Licenses
    • Complexity    • Generics    • Crypto      • Mocking     • Conflicts

         │              │              │              │              │
         └──────────────┴──────────────┴──────────────┴──────────────┘
                                     │
                                     ▼
                          ┌──────────────────┐
                          │  Pre-commit Hook │
                          │  (GitLeaks etc.) │
                          └──────────────────┘
                                     │
                                     ▼
                          ┌──────────────────┐
                          │   CI/CD Pipeline │
                          │   (GitHub Actions)│
                          └──────────────────┘
                                     │
                                     ▼
                              ✅ Production Ready
```

### **Tool Responsibilities**

| Tool | Purpose | What It Checks | Speed |
|------|---------|----------------|-------|
| **Ruff** | Linting & Formatting | Style, imports, complexity, best practices | ⚡ 150-1000x faster |
| **mypy** | Type Checking | Type hints, type safety, contracts | 🔍 Static analysis |
| **Bandit** | Security Scanning | SQL injection, hardcoded secrets, crypto | 🛡️ Security focused |
| **pytest** | Testing | Unit tests, integration, coverage | 🧪 Runtime validation |
| **Safety** | Dependency Security | Known vulnerabilities in packages | 📦 CVE database |
| **Pre-commit** | Git Hooks | Secrets, large files, syntax | 🚫 Prevention |

### **Replaced Legacy Tools**

Ruff alone replaces these 8+ tools:
- ❌ **Black** → ✅ Ruff Format
- ❌ **Flake8** → ✅ Ruff Check
- ❌ **isort** → ✅ Ruff Check (I rules)
- ❌ **pyupgrade** → ✅ Ruff Check (UP rules)
- ❌ **pydocstyle** → ✅ Ruff Check (D rules)
- ❌ **pylint** → ✅ Ruff Check (PL rules)
- ❌ **autoflake** → ✅ Ruff Check (F rules)
- ❌ **pycodestyle** → ✅ Ruff Check (E/W rules)

## 🛠️ **Quick Start**

### 1. **Install UV**
```bash
# Install UV (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with pip
pip install uv
```

### 2. **Setup Project**
```bash
# Install all dependencies (dev, test, docs groups)
uv sync --group dev --group test --group docs

# Or install specific groups only
uv sync --group dev  # Development tools only
```

### 3. **Development Workflow**
```bash
# Add new dependencies
uv add requests httpx  # Production dependencies
uv add --dev pytest black  # Development dependencies

# Run tests
uv run pytest

# Run linting and formatting
uv run ruff check --fix  # Lint and fix issues
uv run ruff format      # Format code

# Type checking
uv run mypy src/

# Security scanning
uv run bandit -r src/
uv run safety check

# Run the application
uv run python -m src.main
```

## 📦 **Dependency Groups**

This project uses UV's dependency groups for better organization:

### **Development (`dev`)**
- `pytest`, `pytest-cov`, `pytest-mock` - Testing framework
- `ruff` - Linting and formatting (replaces Black, isort, Flake8)
- `mypy` - Type checking
- `bandit`, `safety` - Security scanning
- `pre-commit` - Git hooks
- `ipython`, `rich` - Development utilities

### **Testing (`test`)**
- `pytest`, `pytest-cov`, `pytest-mock` - Core testing tools
- `coverage` - Coverage reporting
- `factory-boy`, `faker` - Test data generation

### **Documentation (`docs`)**
- `sphinx` - Documentation generator
- `sphinx-rtd-theme` - ReadTheDocs theme
- `sphinx-autodoc-typehints` - Type hint documentation

### **Profiling (`profiling`)**
- `py-spy` - CPU profiling
- `memory-profiler` - Memory profiling

### **API Testing (`api`)**
- `httpx` - HTTP client
- `pytest-httpx` - HTTP testing

## 🔧 **Configuration**

### **UV Configuration**
- `pyproject.toml` - Project metadata and dependencies
- `uv.lock` - Locked dependency versions
- `.python-version` - Python version specification

### **Ruff Configuration**
- Configured in `pyproject.toml` under `[tool.ruff]`
- Replaces Black, isort, Flake8, and more
- Includes 800+ lint rules with smart defaults

### **Testing Configuration**
- `[tool.pytest.ini_options]` in `pyproject.toml`
- Coverage reporting configured
- Multiple test markers (unit, integration, slow)

## 📋 **Common Commands**

```bash
# Package management
uv add <package>              # Add production dependency
uv add --dev <package>        # Add development dependency
uv remove <package>           # Remove dependency
uv sync                       # Install all dependencies
uv lock                       # Update lock file

# Development
uv run pytest                 # Run tests
uv run pytest --cov=src       # Run tests with coverage
uv run ruff check             # Check for issues
uv run ruff check --fix       # Fix issues automatically
uv run ruff format            # Format code
uv run mypy src/              # Type checking

# Tools
uv tool install <tool>        # Install global tool
uv tool run <tool>            # Run tool without installing
uv python install 3.12       # Install Python version
uv venv                       # Create virtual environment

# Building
uv build                      # Build package (wheel + sdist)
uv build --wheel              # Build wheel only
```

## 🏗️ **Project Structure**

```
python/
├── src/                      # Source code
│   ├── __init__.py
│   ├── main.py              # Entry point
│   ├── config/              # Configuration
│   └── utils/               # Utilities
├── tests/                   # Test files
│   ├── __init__.py
│   ├── test_main.py
│   ├── conftest.py          # Pytest configuration
│   └── benchmarks/          # Performance tests
├── docs/                    # Documentation
├── pyproject.toml           # Project configuration
├── uv.lock                  # Dependency lock file
├── .python-version          # Python version
└── README.md               # This file
```

## ⚡ **Performance Comparison**

| Operation | pip | UV | Improvement |
|-----------|-----|----|-----------| 
| Install 100 packages | 45s | 1.2s | **37x faster** |
| Create venv | 3s | 0.04s | **80x faster** |
| Dependency resolution | 15s | 0.5s | **30x faster** |
| Cold cache install | 60s | 8s | **7.5x faster** |
| Warm cache install | 30s | 0.3s | **100x faster** |

## 🔒 **Security Features**

- **Dependency scanning** with `safety`
- **Code security** with `bandit`
- **Secret detection** in pre-commit hooks
- **Vulnerability monitoring** with Dependabot
- **SBOM generation** for supply chain security

## 🧪 **Testing**

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=src --cov-report=html

# Run specific test types
uv run pytest -m "unit"           # Unit tests
uv run pytest -m "integration"    # Integration tests
uv run pytest -m "not slow"       # Skip slow tests

# Run benchmarks
uv run pytest tests/benchmarks/ --benchmark-json=results.json
```

## 📚 **Migration from pip**

If you're migrating from a pip-based project:

```bash
# Convert requirements.txt to pyproject.toml
uv add $(cat requirements.txt | grep -v '#' | tr '\n' ' ')

# Convert requirements-dev.txt to dev group
uv add --dev $(cat requirements-dev.txt | grep -v '#' | tr '\n' ' ')

# Remove old files (optional)
rm requirements*.txt
```

## 🤝 **Contributing**

1. Install UV: `curl -LsSf https://astral.sh/uv/install.sh | sh`
2. Clone repository: `git clone <repo>`
3. Install dependencies: `uv sync --group dev`
4. Install pre-commit: `pre-commit install`
5. Make changes and run tests: `uv run pytest`
6. Submit pull request

## 📖 **Resources**

- [UV Documentation](https://docs.astral.sh/uv/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Python Packaging Guide](https://packaging.python.org/)
- [pytest Documentation](https://docs.pytest.org/)

---

**Made with ⚡ UV and 🔥 Ruff for blazing-fast Python development**