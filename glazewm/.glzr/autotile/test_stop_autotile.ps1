$ErrorActionPreference = 'Stop'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('autotile-test-' + [guid]::NewGuid())
$sourceHelper = Join-Path $PSScriptRoot 'stop_autotile.ps1'

try {
  $realRoot = New-Item -ItemType Directory -Path (Join-Path $fixture 'real directory')
  $otherRoot = New-Item -ItemType Directory -Path (Join-Path $fixture 'other')
  $link = New-Item -ItemType Junction -Path (Join-Path $fixture 'linked') -Target $realRoot.FullName
  Copy-Item -LiteralPath $sourceHelper -Destination $realRoot.FullName
  $realScript = Join-Path $realRoot.FullName 'glaze_autotile.py'
  $linkedScript = (Join-Path $link.FullName 'glaze_autotile.py').Replace('\', '/')
  $otherScript = Join-Path $otherRoot.FullName 'glaze_autotile.py'
  Set-Content -LiteralPath $realScript -Value ''
  Set-Content -LiteralPath $otherScript -Value ''
  Set-Content -LiteralPath ($realScript + '.backup') -Value ''

  $testState = @{ stopped = @(); fakeProcesses = @() }
  $testState.fakeProcesses = @(
    @{ ProcessId = 1; CommandLine = '"C:\venv\pythonw.exe" "' + $linkedScript + '"' }
    @{ ProcessId = 2; CommandLine = '"C:\uv\pythonw.exe" "' + $realScript + '"' }
    @{ ProcessId = 3; CommandLine = 'pythonw.exe "' + $otherScript + '"' }
    @{ ProcessId = 4; CommandLine = 'pythonw.exe "' + $realScript + '.backup"' }
    @{ ProcessId = 5; CommandLine = 'pythonw.exe -c "' + $realScript + '"' }
    @{ ProcessId = 6; CommandLine = $null }
    @{ ProcessId = 7; CommandLine = 'pythonw.exe glaze_autotile.py' }
  ) | ForEach-Object { [pscustomobject] $_ }

  function Get-CimInstance { param($Filter, $ErrorAction, $ClassName) $testState.fakeProcesses }
  function Stop-Process { param($Id, $ErrorAction) $testState.stopped += $Id }

  foreach ($helperRoot in @($realRoot.FullName, $link.FullName)) {
    $testState.stopped = @()
    & (Join-Path $helperRoot 'stop_autotile.ps1') -Confirm:$false
    if (($testState.stopped -join ',') -ne '1,2') {
      throw "Wrong process selection from ${helperRoot}: $($testState.stopped)"
    }
    $testState.stopped = @()
    & (Join-Path $helperRoot 'stop_autotile.ps1') -WhatIf
    if ($testState.stopped.Count) { throw 'WhatIf stopped a process.' }
  }
  Write-Output 'Passed: launcher/child, junction paths, spaces, unrelated scripts, suffixes, -c, missing command line, relative paths, and WhatIf.'
} finally {
  # Unlink the known test junction before removing the temporary fixture.
  if ($link) { [IO.Directory]::Delete($link.FullName) }
  if ([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase)) {
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
  }
}

