---
description: Python project setup + dependency management with uv
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

Prefer Python `>=3.11, <3.12` unless user asks otherwise.
Creates:

- `pyproject.toml` - project config + deps
- `.python-version` - Python version spec
- basic project structure

Then add deps:

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

All deps live in `pyproject.toml`.

## Settings and Secrets: Dynaconf Preferred

**ALWAYS prefer `dynaconf` for app settings + secrets.**

Use:

```bash
uv add dynaconf
```

Init in project with:

```bash
uv run dynaconf init
```

Creates layered config boilerplate:

- `settings.toml` (default settings)
- `.secrets.toml` (local secrets, ensure git-ignored)
- `config.py` (loads settings in code)

Example usage in code:

```python
from config import settings
print(settings.SOME_SETTING)
```

Guidelines:

- Use `dynaconf` for env-based config (`dev`/`test`/`prod`).
- Keep secrets out of source code. Load through env vars or local secret files.
- Use layered config: defaults, env-specific overrides, local secrets.
- Avoid ad-hoc config parsing if `dynaconf` fits.

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

**ALWAYS use `uv run ruff format` as the preferred formatter:**

```bash
uvx ruff format .
uvx ruff check .  # Check without modifying
```

## Project Structure

Standard Python project structure from `uv init`:

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
- Manual virtual environment creation with `uv venv` (`uv init` for new projects only; else `uv sync`)

✅ **ALWAYS use:**

- `uv init` (for new projects)
- `uv add <package>` (for dependencies)
- `uv run <command>`
- `uvx <tool>` (for one-off tool execution)
- `pyproject.toml` (for dependency management, managed by uv)
- `uvx ruff` (preferred formatter)

## Code Style

- Use type hints where appropriate
- Follow PEP 8 (enforce with `uv run ruff`)
- Write docstrings for functions and classes
- Keep functions focused and modular
- Format code with `uv run ruff` before committing

## Troubleshooting

### UV command not found

Check OS, run install command:

- Windows: `winget install --id=astral-sh.uv  -e`
- Homebrew (macOS): `brew install uv`

IMPORTANT: After install, stop current chat session. Restart VS Code by closing + reopening it. This ensures command is available in terminal.

### SSL certificate errors or Corporate Certificate Errors

Can happen during managed Python installs or dependency installs in corp environments with self-signed certs. To bypass:

```bash
<uv command> --allow-insecure-host <host>
```

Host can be `pypi.org`, `github.com`, etc., depending where SSL error happens.
