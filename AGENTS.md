# Repository Instructions

This is a personal dotfiles repo managed with GNU Stow.

## Stow Layout

- Treat each top-level directory as a Stow package.
- Keep package contents laid out exactly as they should appear under `$HOME`.
- Prefer documenting install steps with `stow --target "$HOME" <package>` from the repo root.
- Use `stow --simulate --verbose --target "$HOME" <package>` when checking link behavior.
- Use `stow --target "$HOME" -D <package>` when documenting unlink behavior.

## Platform Boundaries

- `aerospace/` is macOS-only. Do not apply it to Windows examples or workflows.
- `glazewm/` is Windows-only. Do not apply it to macOS examples or workflows.
- Keep OS-specific notes explicit when adding README or setup instructions.

## Editing

- Keep documentation concise and command-focused.
- Do not add secrets, machine-local paths, logs, or generated cache files.
- Preserve existing package names unless the user asks for a repo layout change.
