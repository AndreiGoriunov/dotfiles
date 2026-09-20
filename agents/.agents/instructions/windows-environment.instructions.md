---
description: Windows 11 and PowerShell 7+ defaults for shell commands, paths, and examples, with portable formatting conventions.
applyTo: "**"
---

# Windows Development Environment

## System Environment

- Default to Windows 11 and PowerShell 7+ (`pwsh`) for Windows workflows.
- Follow an explicitly specified target OS or shell. Keep macOS and Linux instructions labeled for those platforms.
- Avoid legacy `cmd.exe` syntax unless explicitly requested.

## Path Conventions

- Prefer forward slashes (`/`) in project code, configuration, documentation, and examples when the consuming tool supports them.
- Use backslashes only when required by a command, API, or path format.
- Use path-handling libraries for paths constructed in code; avoid machine-specific absolute paths.
- Quote paths containing spaces and use PowerShell cmdlets' `-LiteralPath` parameter when paths may contain wildcard characters.

## Shell Commands

When providing PowerShell commands:

- Prefer PowerShell cmdlets such as `Get-ChildItem`, `Select-Object`, and `Test-Path`.
- Use `Get-Command` instead of `which` or `where` to locate executables.
- Use PowerShell environment variable syntax, such as `$env:PATH`.
- Use forward slashes in paths when supported by the command.
