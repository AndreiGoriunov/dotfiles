[CmdletBinding(SupportsShouldProcess)]
param()

function Resolve-AutoTilePath([string] $Path) {
  if (-not [IO.Path]::IsPathRooted($Path)) { return $null }
  $resolved = [IO.Path]::GetFullPath($Path.Replace('/', '\'))

  # Resolve links in parent directories too (for example, the Stow .glzr junction).
  # GetFullPath and Resolve-Path alone do not resolve junction targets.
  for ($depth = 0; $depth -lt 32; $depth++) {
    $item = Get-Item -LiteralPath $resolved -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $null }
    while ($item -and -not $item.LinkType) {
      $parentPath = Split-Path -Parent $item.FullName
      if (-not $parentPath) { $item = $null; break }
      $item = Get-Item -LiteralPath $parentPath -Force -ErrorAction SilentlyContinue
    }
    if (-not $item) { return $resolved }
    if ($item.LinkType -notin @('Junction', 'SymbolicLink')) { return $null }
    $target = @($item.Target)[0]
    if (-not [IO.Path]::IsPathRooted($target)) {
      $target = Join-Path (Split-Path -Parent $item.FullName) $target
    }
    $resolved = [IO.Path]::GetFullPath($target + $resolved.Substring($item.FullName.Length))
  }
  throw 'Too many links while resolving the AutoTile path.'
}

$scriptPath = Resolve-AutoTilePath (Join-Path $PSScriptRoot 'glaze_autotile.py')
if (-not $scriptPath) { throw 'Cannot resolve the AutoTile script path.' }

# The venv launcher and its base-Python child both run this exact script.
# Match the script argument, not the interpreter location or a path substring.
$commandPattern = '^\s*(?:"[^"]*"|\S+)\s+(?:"(?<script>[^"]+)"|(?<script>\S+))(?:\s|$)'
Get-CimInstance Win32_Process -Filter "Name = 'pythonw.exe'" -ErrorAction Stop |
  ForEach-Object {
    if ($_.CommandLine -match $commandPattern) {
      $processScript = Resolve-AutoTilePath $Matches.script
      if ($processScript -eq $scriptPath -and $PSCmdlet.ShouldProcess("AutoTile PID $($_.ProcessId)", 'Stop process')) {
        $processId = $_.ProcessId
        try {
          Stop-Process -Id $processId -ErrorAction Stop
        } catch {
          # Stopping the child can also make its launcher exit.
          if (Get-Process -Id $processId -ErrorAction SilentlyContinue) { throw }
        }
      }
    }
  }
