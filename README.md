# dotfiles

Personal dotfiles managed with GNU Stow.

## Layout

Each top-level directory is a Stow package. Run commands from this repo root and
target `$HOME`.

- `zsh` - Zsh and Oh My Zsh config
- `codex` - Codex config and agent instructions
- `aerospace` - macOS-only Aerospace config
- `glazewm` - Windows-only GlazeWM and Zebar config

## Link

Preview first. This shows what Stow would create, skip, or complain about
without changing anything:

```sh
stow --simulate --verbose --target "$HOME" zsh codex
```

Link common config:

```sh
stow --target "$HOME" zsh codex
```

Link platform-specific config:

```sh
# macOS
stow --target "$HOME" aerospace

# Windows
stow --target "$HOME" glazewm
```

## Check Existing Links

Use a verbose dry run for one package:

```sh
stow --simulate --verbose=2 --target "$HOME" zsh
```

Useful output:

- `LINK: ...` means Stow would create a new link.
- `Skipping ... as it already points to ...` means the link is already correct.
- `CONFLICT` means a real file or different link already exists at the target.

Check the actual symlink target directly:

```sh
ls -l "$HOME/.zshrc"
ls -l "$HOME/.config/aerospace/aerospace.toml"
ls -ld "$HOME/.glzr"
```

On PowerShell, use:

```powershell
Get-Item "$HOME/.zshrc"
Get-Item "$HOME/.glzr"
```

## Unlink

```sh
stow --target "$HOME" -D zsh codex
stow --target "$HOME" -D aerospace
stow --target "$HOME" -D glazewm
```

## GlazeWM Profiles

If work and personal Windows machines need different GlazeWM configs, split them
into separate packages:

```text
glazewm-common/
glazewm-work/
glazewm-personal/
```

Then install only the matching profile:

```sh
# Work Windows machine
stow --target "$HOME" glazewm-common glazewm-work

# Personal Windows machine
stow --target "$HOME" glazewm-common glazewm-personal
```

Do not let two packages contain the same target file, such as
`.glzr/glazewm/config.yaml`, unless you are intentionally replacing one profile
with another.

## Notes

- Do not install `aerospace` on Windows.
- Do not install `glazewm` on macOS.
- If Stow reports conflicts, move or back up the existing target files first.
