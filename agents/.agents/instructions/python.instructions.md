---
description: Python conventions, tooling, and dependency management with uv
applyTo: "**/*.py,**/pyproject.toml,**/uv.lock"
---

# Python project guidelines

## Setup

- For new projects, target Python 3.12+ with `requires-python = ">=3.12"`. Preserve existing Python constraints unless asked to change them.
- Initialize packaged applications with `uv init --package --python 3.12`; use `--lib` for libraries or `--no-package` for simple un-packaged applications.
- Use `src/<package>/` for packaged code and `tests/` for tests. Preserve existing layouts.

## Dependencies and execution

- Manage dependencies with `uv add`, `uv add --dev`, and `uv remove`. Commit `pyproject.toml` and `uv.lock`.
- Use `uv sync` to manage the project environment and `uv run` for project commands.
- Use `uvx` only for standalone tools that do not need project dependencies.
- Do not use pip, pipenv, poetry, conda, requirements.txt, or manually created virtual environments.

## Tooling

- Required development dependencies: pytest, pytest-cov, ruff, mypy.
- Optional development dependency: commitizen for version bumping. Configure `version_provider = "uv"` under `[tool.commitizen]` in `pyproject.toml`.
- Configure tools in `pyproject.toml`. Enable Ruff import-sorting rules (`I`).
- Format with `uv run ruff format .`.
- Verify changes with `uv run ruff check .`, `uv run mypy .`, and relevant `uv run pytest` tests. Report checks not run.

## Application libraries

- Use Dynaconf for application configuration, PySide6 for desktop GUIs, and FastAPI with Uvicorn for APIs. Add dependencies only when relevant.
- Dynaconf supports named configuration environments via `environments=True`; enable only when needed.
- Load secrets from environment variables or git-ignored local secret files. Never commit secrets.

## Code

- Annotate function parameters, return values, and class attributes. Annotate local variables when inference is insufficient.
- Use built-in generics and `X | None`. Avoid `Any` unless required by dynamic behavior.
- Follow PEP 8 and project Ruff configuration.
- Keep functions focused; document public APIs and non-obvious behavior.

## Dependencies and CI

- Declare directly used third-party dependencies; do not rely on transitive dependencies. Prefer the standard library when sufficient.
- Separate runtime dependencies, development dependency groups, and optional runtime extras.
- In CI, use `uv sync --locked` and `uv run --locked` for checks. Include `ruff format --check`.

## Design and reliability

- Keep business logic independent of GUI, API, and CLI entry points. Avoid abstractions for hypothetical requirements.
- Use async only when beneficial; keep blocking work off event loops and GUI threads.
- Catch specific exceptions, preserve diagnostic context, and never silently swallow unexpected failures.
- Use logging for diagnostics; exclude secrets and sensitive data.
- Avoid reliance on the working directory. Use `pathlib` for paths and `importlib.resources` for packaged assets; keep mutable data outside the installed package.

## Testing

- Keep unit tests deterministic and independent of external services. Mock external boundaries rather than implementation details.
- Add regression tests for bug fixes where practical; separate integration tests when useful.
