# AutoTile for GlazeWM

Windows-only automatic tiling direction based on the focused window's aspect
ratio. Requires GlazeWM with IPC enabled and [uv](https://docs.astral.sh/uv/).

## Setup

Run these PowerShell commands from the **dotfiles repo root**:

```powershell
uv --directory .\glazewm\.glzr\autotile\ sync --locked
.\stow-win.ps1 --simulate --verbose --target "$HOME" glazewm
.\stow-win.ps1 --target "$HOME" glazewm
```

`uv sync` creates the local `.venv` and installs dependencies, including the test
tools. The project pins Python 3.14 in `.python-version`; uv can download it if
needed. Create the environment here instead of copying one from another location.

The GlazeWM config starts `.venv/Scripts/pythonw.exe` and runs
`stop_autotile.ps1` on shutdown through `%USERPROFILE%/.glzr/autotile`, which
Stow links to this directory. The stop helper derives its paths from its own
location. Restart GlazeWM after setup; reloading its config does not run startup
commands. Shutdown forcibly stops AutoTile, so unsaved statistics may be lost.

## Run manually or test

From the dotfiles repo root:

```powershell
# Run in the foreground with GlazeWM running; avoid a second AutoTile instance.
uv --directory .\glazewm\.glzr\autotile\ run --locked python glaze_autotile.py

# Run the focused tests without starting AutoTile.
uv --directory .\glazewm\.glzr\autotile\ run --locked python -m pytest
```

[`--directory`](https://docs.astral.sh/uv/reference/cli/#uv--directory) changes
the working directory before executing the command. If already in this directory,
omit that option (for example, `uv sync --locked`).
