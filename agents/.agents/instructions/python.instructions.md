---
description: Python project setup and dependency management using uv
applyTo: "**"
---

# Python Project Guidelines

## Package Manager: uv Only

Use `uv` for Python projects. Do not suggest another package manager unless
the user explicitly requests it.

Guide: [uv Features](https://docs.astral.sh/uv/getting-started/features/)

## New Project Setup

Start new projects with `uv init`. Prefer Python `>=3.11, <3.12` unless the
user requests otherwise:

```bash
uv init --python 3.11
```

Set `requires-python = ">=3.11, <3.12"` in `pyproject.toml` for this default.
Preserve an existing project's Python constraints.

Initialization creates:

- `pyproject.toml` - Project configuration and dependencies
- `.python-version` - Python version specification
- Basic project structure

Then add dependencies with `uv add <package>`.

## Dependency Management

Manage dependencies in `pyproject.toml` using uv. Do not create or use
`requirements.txt`. Commit `uv.lock` to preserve resolved dependencies.

```bash
# Add dependencies
uv add <package>
uv add --dev <package>

# Add a specific version
uv add "package==1.2.3"

# Remove dependencies
uv remove <package>

# Sync the project environment
uv sync
```

## Settings and Secrets: Dynaconf Preferred

Prefer `dynaconf` for application settings and secrets management.

```bash
uv add dynaconf
uv run dynaconf init
```

Creates layered configuration boilerplate:

- `settings.toml` - Default settings
- `.secrets.toml` - Local secrets; ensure this file is git-ignored
- `config.py` - Settings loader

Example:

```python
from config import settings

print(settings.SOME_SETTING)
```

Guidelines:

- Use Dynaconf for environment-based configuration (`dev`/`test`/`prod`).
- Keep secrets out of source code. Load them through environment variables or local secret files.
- Layer defaults, environment-specific overrides, and local secrets.
- Avoid ad-hoc configuration parsing when Dynaconf fits.

## Running Tools and Scripts

Use `uv run` for scripts and tools that need project dependencies:

```bash
uv run script.py
uv run streamlit run app.py

# Add project development tools, then run them
uv add --dev pytest mypy
uv run pytest
uv run mypy .
```

Use `uvx <tool>` for standalone tools. Its isolated environment does not
include the project's dependencies.

## Code Formatting

Prefer Ruff for formatting and linting:

```bash
uvx ruff format .
uvx ruff check .  # Check without modifying
```

If Ruff is already declared as a project dependency, use `uv run ruff format .`
and `uv run ruff check .` to use the project's version.

## Project Structure

Print directory trees as nested Markdown bullet lists using ASCII characters.
A typical project after initialization and dependency synchronization:

- `project/`
  - `.venv/` - Virtual environment (created by sync/run; git-ignored)
  - `.python-version` - Python version specification
  - `pyproject.toml` - Project configuration and dependencies
  - `uv.lock` - Resolved dependencies
  - `.gitignore` - Git ignore rules
  - `README.md` - Documentation
  - `main.py` - Default application entry point

Packaged projects initialized with `uv init --package` use a source layout:

- `project/`
  - `src/`
    - `<module_name>/`
      - `__init__.py` - Package source

## Forbidden Commands and Patterns

Unless explicitly requested by the user, do not suggest:

- `pip install` or `python -m pip`
- `pipenv`, `poetry`, or `conda`
- Creating or using `requirements.txt`, including `uv pip install -r requirements.txt`
- Manual virtual environment creation with `uv venv`; use `uv init` for new projects and `uv sync` for existing projects

## Code Style

- Strongly prefer type hints where appropriate.
- Follow PEP 8; format and lint with Ruff.
- Write docstrings for functions and classes.
- Keep functions focused and modular.
- Run `uvx ruff format .` before committing, or `uv run ruff format .` when Ruff is a project dependency.

## Troubleshooting

### uv Command Not Found

Check the OS and use the appropriate installation command:

- Windows: `winget install --id=astral-sh.uv -e`
- macOS with Homebrew: `brew install uv`

After installation, open a new terminal and verify `uv --version`. If an
integrated terminal still cannot find uv, restart its host application to
refresh PATH.

### SSL or Corporate Certificate Errors

For certificate errors during Python or dependency installation, configure the
trusted corporate CA using uv's [certificate guidance](https://docs.astral.sh/uv/concepts/authentication/certificates/).

If a temporary bypass is explicitly needed, scope it to the failing host:

```bash
uv sync --allow-insecure-host <host>
```

This disables certificate verification for that host. Do not make it the
default or apply it to unrelated hosts.
