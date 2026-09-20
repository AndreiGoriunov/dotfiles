$scriptPath = (Join-Path $PSScriptRoot 'glaze_autotile.py').Replace('\', '/')
$pythonwPath = (Join-Path $PSScriptRoot '.venv/Scripts/pythonw.exe').Replace('\', '/')

Get-CimInstance Win32_Process -Filter "Name = 'pythonw.exe'" |
  Where-Object {
    $_.ExecutablePath -and
    $_.ExecutablePath.Replace('\', '/') -eq $pythonwPath -and
    $_.CommandLine -and
    $_.CommandLine.Replace('\', '/') -like "*$scriptPath*"
  } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -ErrorAction SilentlyContinue }
