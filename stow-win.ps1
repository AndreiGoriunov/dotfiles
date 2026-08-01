#!/usr/bin/env pwsh
param(
  [switch] $D,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $RemainingArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Usage {
  @"
Usage:
  .\stow-win.ps1 [options] <package> [package...]

Options:
      --dir <path>       Package directory. Defaults to the current directory.
  -t, --target <path>    Target directory. Defaults to `$HOME.
  -D, --delete          Remove links for the package instead of creating them.
  -n, --simulate        Print actions without changing the filesystem.
      --no              Alias for --simulate.
  -v, --verbose         Print actions. Repeatable.
      --verbose=N       Set verbosity level.
  -h, --help            Show this help.

Examples:
  .\stow-win.ps1 --simulate --verbose --target `$HOME glazewm
  .\stow-win.ps1 --dir D:\dev\dotfiles --target `$HOME glazewm
  .\stow-win.ps1 --target `$HOME glazewm
  .\stow-win.ps1 --target `$HOME -D glazewm
"@
}

function Convert-ToFullPath {
  param([Parameter(Mandatory)][string] $Path)

  $expanded = [Environment]::ExpandEnvironmentVariables($Path)
  if ([System.IO.Path]::IsPathRooted($expanded)) {
    return [System.IO.Path]::GetFullPath($expanded)
  }

  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $expanded))
}

function Test-IsLink {
  param([Parameter(Mandatory)][System.IO.FileSystemInfo] $Item)

  return (($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Get-LinkTarget {
  param([Parameter(Mandatory)][System.IO.FileSystemInfo] $Item)

  if (-not (Test-IsLink $Item)) {
    return $null
  }

  try {
    $target = $Item.Target
    if ($target -is [array]) {
      return ($target | Select-Object -First 1)
    }
    return $target
  } catch {
    return $null
  }
}

function Resolve-LinkTarget {
  param(
    [Parameter(Mandatory)][string] $LinkPath,
    [string] $Target
  )

  if ([string]::IsNullOrWhiteSpace($Target)) {
    return $null
  }

  if ([System.IO.Path]::IsPathRooted($Target)) {
    return [System.IO.Path]::GetFullPath($Target)
  }

  $linkParent = Split-Path -Parent $LinkPath
  return [System.IO.Path]::GetFullPath((Join-Path $linkParent $Target))
}

function Test-SamePath {
  param(
    [string] $Left,
    [string] $Right
  )

  if ([string]::IsNullOrWhiteSpace($Left) -or [string]::IsNullOrWhiteSpace($Right)) {
    return $false
  }

  $leftFull = [System.IO.Path]::GetFullPath($Left).TrimEnd('\', '/')
  $rightFull = [System.IO.Path]::GetFullPath($Right).TrimEnd('\', '/')
  return [string]::Equals($leftFull, $rightFull, [System.StringComparison]::OrdinalIgnoreCase)
}

function Write-Action {
  param(
    [Parameter(Mandatory)][string] $Message,
    [int] $MinimumVerbosity = 1
  )

  if ($script:VerboseLevel -ge $MinimumVerbosity -or $script:Simulate) {
    Write-Host $Message
  }
}

$dir = (Get-Location).Path
$target = $HOME
$delete = [bool]$D
$simulate = $false
$verboseLevel = 0
$packages = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $RemainingArgs.Count; $i++) {
  $arg = $RemainingArgs[$i]

  switch -Regex ($arg) {
    "^(--help|-h)$" {
      Show-Usage
      exit 0
    }
    "^--dir$" {
      if ($i + 1 -ge $RemainingArgs.Count) {
        throw "Missing value for $arg."
      }
      $i++
      $dir = $RemainingArgs[$i]
      continue
    }
    "^--dir=(.+)$" {
      $dir = $Matches[1]
      continue
    }
    "^(--target|-t)$" {
      if ($i + 1 -ge $RemainingArgs.Count) {
        throw "Missing value for $arg."
      }
      $i++
      $target = $RemainingArgs[$i]
      continue
    }
    "^--target=(.+)$" {
      $target = $Matches[1]
      continue
    }
    "^(--delete|-D)$" {
      $delete = $true
      continue
    }
    "^(--simulate|--no|-n)$" {
      $simulate = $true
      continue
    }
    "^(--verbose|-v)$" {
      $verboseLevel++
      continue
    }
    "^--verbose=(\d+)$" {
      $verboseLevel = [int]$Matches[1]
      continue
    }
    default {
      if ($arg.StartsWith("-")) {
        throw "Unknown option: $arg"
      }
      $packages.Add($arg)
    }
  }
}

if ($packages.Count -eq 0) {
  Show-Usage
  throw "At least one package is required."
}

$repoRoot = Convert-ToFullPath $dir
$targetRoot = Convert-ToFullPath $target
$script:VerboseLevel = $verboseLevel
$script:Simulate = $simulate

if (-not (Test-Path -LiteralPath $repoRoot -PathType Container)) {
  throw "Package directory does not exist: $repoRoot"
}

if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
  throw "Target directory does not exist: $targetRoot"
}

$operations = [System.Collections.Generic.List[object]]::new()
$conflicts = [System.Collections.Generic.List[string]]::new()
$plannedDestinations = @{}

foreach ($package in $packages) {
  $packagePath = Join-Path $repoRoot $package
  if (-not (Test-Path -LiteralPath $packagePath -PathType Container)) {
    throw "Package does not exist or is not a directory: $package"
  }

  Get-ChildItem -LiteralPath $packagePath -Force | ForEach-Object {
    $source = $_.FullName
    $destination = Join-Path $targetRoot $_.Name
    $existing = Get-Item -LiteralPath $destination -Force -ErrorAction SilentlyContinue
    $destinationKey = [System.IO.Path]::GetFullPath($destination).TrimEnd('\', '/').ToLowerInvariant()

    if ($delete) {
      if ($null -eq $existing) {
        $operations.Add([pscustomobject]@{
          Action = "Skip"
          Message = "MISSING: $destination"
          MinimumVerbosity = 2
        })
        return
      }

      if (-not (Test-IsLink $existing)) {
        $conflicts.Add("CONFLICT: $destination exists and is not a link")
        return
      }

      $resolvedTarget = Resolve-LinkTarget -LinkPath $destination -Target (Get-LinkTarget $existing)
      if (-not (Test-SamePath $resolvedTarget $source)) {
        $conflicts.Add("CONFLICT: $destination points to $resolvedTarget")
        return
      }

      $operations.Add([pscustomobject]@{
        Action = "Unlink"
        Destination = $destination
        Message = "UNLINK: $destination"
        MinimumVerbosity = 1
      })
      return
    }

    if ($plannedDestinations.ContainsKey($destinationKey)) {
      $conflicts.Add("CONFLICT: $destination is provided by both $($plannedDestinations[$destinationKey]) and $source")
      return
    }
    $plannedDestinations[$destinationKey] = $source

    if ($null -ne $existing) {
      if (Test-IsLink $existing) {
        $resolvedTarget = Resolve-LinkTarget -LinkPath $destination -Target (Get-LinkTarget $existing)
        if (Test-SamePath $resolvedTarget $source) {
          $operations.Add([pscustomobject]@{
            Action = "Skip"
            Message = "Skipping $destination as it already points to $source"
            MinimumVerbosity = 1
          })
        } else {
          $conflicts.Add("CONFLICT: $destination points to $resolvedTarget")
        }
      } else {
        $conflicts.Add("CONFLICT: $destination exists and is not a link")
      }
      return
    }

    $operations.Add([pscustomobject]@{
      Action = "Link"
      Destination = $destination
      Source = $source
      IsContainer = $_.PSIsContainer
      Message = "LINK: $destination => $source"
      MinimumVerbosity = 1
    })
  }
}

if ($conflicts.Count -gt 0) {
  foreach ($conflict in $conflicts) {
    Write-Host $conflict
  }

  if ($simulate) {
    Write-Host "WARNING: in simulation mode so not modifying filesystem."
  }

  exit 1
}

foreach ($operation in $operations) {
  Write-Action $operation.Message $operation.MinimumVerbosity

  if ($simulate -or $operation.Action -eq "Skip") {
    continue
  }

  if ($operation.Action -eq "Unlink") {
    Remove-Item -LiteralPath $operation.Destination -Force
    continue
  }

  if ($operation.IsContainer) {
    New-Item -ItemType Junction -Path $operation.Destination -Target $operation.Source | Out-Null
  } else {
    New-Item -ItemType SymbolicLink -Path $operation.Destination -Target $operation.Source | Out-Null
  }
}

if ($simulate) {
  Write-Host "WARNING: in simulation mode so not modifying filesystem."
}
