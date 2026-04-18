---
description: Python project setup and dependency management using uv
applyTo: '**'
---

# Python Project Guidelines

## Package Manager: uv Only

**ALWAYS use `uv` for Python projects. Never suggest alternatives.**

Guide: [UV Features](https://docs.astral.sh/uv/getting-started/features/)

## New Project Setup

**ALWAYS start new projects with:**
```bash
uv init
```
Prefer python version `>=3.11, <3.12` (unless explicitly requested otherwise).
This creates:
- `pyproject.toml` - Project configuration and dependencies
- `.python-version` - Python version specification
- Basic project structure

Then add dependencies:
```bash
uv add <package>
```

## Dependency Management

**CRITICAL: NEVER use `requirements.txt`**

```bash
# Add dependencies
uv add <package>
uv add <package> --dev  # Development dependencies

# Add specific version
uv add "package==1.2.3"

# Remove dependencies
uv remove <package>

# Sync dependencies
uv sync
```

All dependencies are managed in `pyproject.toml`.

## Settings and Secrets: Dynaconf Preferred

**ALWAYS prefer `dynaconf` for application settings and secrets management.**

Use:
```bash
uv add dynaconf
```
Initialize `dynaconf` within the project using:
```bash
uv run dynaconf init
```
This will create boilerplate configuration files for layered settings management:
- `settings.toml` (default settings)
- `.secrets.toml` (local secrets, ensure git-ignored)
- `config.py` (loads settings in code)

Example usage in code:
```python
from config import settings
print(settings.SOME_SETTING)
```

Guidelines:
- Use `dynaconf` for environment-based configuration (dev/test/prod).
- Keep secrets out of source code and load them through environment variables or local secret files.
- Use layered configuration (for example: defaults, environment-specific overrides, and local secrets).
- Avoid ad-hoc config parsing when `dynaconf` can handle the settings model.

## Running Tools and Scripts

```bash
# Run Python scripts
uv run script.py
uv run streamlit run app.py

# Run tools without installing (preferred for dev tools)
uvx ruff format . # Code formatter (PREFERRED)
uvx ruff check .  # Linter
uvx pytest        # Testing
uvx mypy .        # Type checking
```

## Code Formatting

**ALWAYS use `uvx ruff format` as the preferred formatter:**
```bash
uvx ruff format .
uvx ruff check .  # Check without modifying
```

## Project Structure

Standard Python project structure (created by `uv init`):
```
project/
├── .venv/              # Virtual environment (git-ignored)
├── .python-version     # Python version (e.g., 3.11)
├── pyproject.toml      # Project config & dependencies
├── .gitignore         # Git ignore file
├── README.md          # Documentation
└── src/ or *.py or <module_name>/      # Source code
```

## Forbidden Commands and Patterns

❌ **NEVER suggest:**
- `pip install`
- `python -m pip`
- `pipenv`
- `poetry` (unless explicitly requested)
- `conda`
- `requirements.txt` (NEVER create or use)
- `uv pip install -r requirements.txt`
- Manual virtual environment creation with `uv venv` (use `uv init` instead for new projects only. Else `uv sync`.)

✅ **ALWAYS use:**
- `uv init` (for new projects)
- `uv add <package>` (for dependencies)
- `uv run <command>`
- `uvx <tool>` (for one-off tool execution)
- `pyproject.toml` (for dependency management, managed by uv)
- `uvx ruff` (preferred formatter)

## Code Style

- Use type hints where appropriate (strong preference for type hints)
- Follow PEP 8 (enforce with `uvx ruff`)
- Write docstrings for functions and classes
- Keep functions focused and modular
- Format code with `uvx ruff` before committing

## Troubleshooting

**UV command not found**

Check which OS you are using and run the appropriate installation command:
- Windows: `winget install --id=astral-sh.uv  -e`
- Homebrew (macOS): `brew install uv`

IMPORTANT: Once the command is installed, stop the current chat session and ask the user to restart VS Code by closing it and reopening it. This ensures the new command is available in the terminal.

**SSL certificate errors or Corporate Certificate Errors**
Can occur during managed python version installations or dependencies.
This can occur in corporate environments with self-signed certificates. To bypass SSL certificate errors, you can run the uv command with a flag to ignore SSL certificate errors:

Run the uv command with a flag to ignore SSL certificate errors:
```bash
<uv command> --allow-insecure-host <host>
```
E.g., host can be "pypi.org", "github.com", etc., depending on where the SSL error is occurring.