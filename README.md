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

Preview first:

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

## Unlink

```sh
stow --target "$HOME" -D zsh codex
stow --target "$HOME" -D aerospace
stow --target "$HOME" -D glazewm
```

## Notes

- Do not install `aerospace` on Windows.
- Do not install `glazewm` on macOS.
- If Stow reports conflicts, move or back up the existing target files first.
