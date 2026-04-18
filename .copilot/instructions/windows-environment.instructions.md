---
description: "Use when generating code, configuration files, documentation, examples, shell commands, or any file paths. Enforces Windows 11 with PowerShell 7+ and POSIX-style forward slashes for cross-platform compatibility."
applyTo: "**"
---

# Windows Development Environment

## System Environment

- Primary OS: **Windows 11**
- Default shell: **PowerShell 7+** (`pwsh`)
- Avoid legacy `cmd.exe` syntax unless explicitly requested

## Path Conventions (CRITICAL)

**In all project code, configuration files, documentation, and examples:**

✅ **Always use POSIX-style forward slashes (`/`)**

❌ **Never hardcode Windows-style backslashes (`\`)**

**Rationale:** Forward slashes work on Windows and are required for cross-platform compatibility.

## Shell Commands

When providing PowerShell commands:
- Prefer PowerShell cmdlets: `Get-ChildItem`, `Select-Object`, `Test-Path`
- Use `Get-Command` instead of `which` or `where`
- Use forward slashes in paths when possible
- Only use backslashes if the command explicitly requires it
