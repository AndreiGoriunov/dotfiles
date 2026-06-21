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
```

For Windows GlazeWM, use the PowerShell Stow helper so links are visible to
Windows apps:

```powershell
.\stow-win.ps1 --simulate --verbose --target "$HOME" glazewm
.\stow-win.ps1 --target "$HOME" glazewm
```

From another directory, pass the repo path explicitly:

```powershell
D:\dev\dotfiles\stow-win.ps1 --dir "D:\dev\dotfiles" --target "$HOME" glazewm
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
```

On PowerShell, use:

```powershell
Get-Item "$HOME/.zshrc"
Get-Item "$HOME\.glzr" | Format-List FullName,LinkType,Target
```

## Unlink

```sh
stow --target "$HOME" -D zsh codex
stow --target "$HOME" -D aerospace
```

Remove the Windows GlazeWM junction from PowerShell:

```powershell
.\stow-win.ps1 --target "$HOME" -D glazewm
```

## GlazeWM Profiles

Keep GlazeWM configs in one package under `.glzr/glazewm/`, such as:

```text
config.yaml
config-work.yaml
config-personal.yaml
merged.yaml
```

Use `GLAZEWM_CONFIG_PATH` to choose the default config:

```powershell
[Environment]::SetEnvironmentVariable("GLAZEWM_CONFIG_PATH", "$HOME\.glzr\glazewm\config-work.yaml", "User")
```

Restart GlazeWM after changing the environment variable. To test a config
without changing the default, pass it at startup:

```powershell
glazewm.exe start --config="C:\path\to\config-work.yaml"
```

## Notes

- Do not install `aerospace` on Windows.
- Do not install `glazewm` on macOS.
- If Stow reports conflicts, move or back up the existing target files first.
