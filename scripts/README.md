<div align="center">

# 🛠️ Scripts Directory

<p align="center">
  <strong>Utility scripts for automation and testing</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-Scripts-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python Scripts"/>
  <img src="https://img.shields.io/badge/Bash-Automation-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash"/>
  <img src="https://img.shields.io/badge/Utilities-Tooling-orange?style=for-the-badge&logo=tools&logoColor=white" alt="Utilities"/>
</p>

</div>

---

This directory contains utility scripts for the project.

## Available Scripts

### test-manual-fix.py

A test utility script for verifying auto-fix workflows.

**Purpose:** Tests the manual fixing of Python syntax errors in broken_python.py

**Usage:**
```bash
python scripts/test-manual-fix.py
```

**What it does:**
- Reads the broken_python.py file
- Applies common syntax fixes (missing colons, invalid assignments, etc.)
- Validates the fixed code using AST parsing
- Reports the fixes applied

## Adding New Scripts

When adding new scripts to this directory:

1. Use descriptive names (e.g., `deploy_helper.py`, `migrate_data.sh`)
2. Add a shebang line (e.g., `#!/usr/bin/env python3`)
3. Make scripts executable: `chmod +x script_name.py`
4. Add documentation to this README
5. Include inline comments and docstrings

## Best Practices

- Keep scripts focused on a single task
- Add error handling and validation
- Use logging for debugging
- Make scripts idempotent when possible
- Test scripts before committing
