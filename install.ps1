<#
.SYNOPSIS
  atelier installer for Windows PowerShell 5.1+ / PowerShell 7.
.DESCRIPTION
  Copies skills\, personal\, agents\ and global\CLAUDE.md into ~\.claude.
  Anything it would replace is first copied to ~\.claude\atelier-backups\<timestamp>\.
.EXAMPLE
  .\install.ps1 -DryRun
  .\install.ps1 -NoPersonal
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$NoPersonal,
  [switch]$NoClaudeMd,
  [string]$ClaudeHome = $(if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' })
)
$ErrorActionPreference = 'Stop'

$Repo = $PSScriptRoot
if (-not (Test-Path (Join-Path $Repo 'skills')) -or -not (Test-Path (Join-Path $Repo 'agents'))) {
  throw "Run from the atelier repo (skills\ and agents\ not found next to install.ps1)."
}
if ([string]::IsNullOrWhiteSpace($ClaudeHome)) { throw "ClaudeHome is empty." }
$ClaudeHome = [System.IO.Path]::GetFullPath($ClaudeHome)
if ($ClaudeHome -eq [System.IO.Path]::GetPathRoot($ClaudeHome)) { throw "Refusing to install into a drive root: $ClaudeHome" }

$Stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $ClaudeHome (Join-Path 'atelier-backups' $Stamp)
$script:Count = 0

function Say([string]$Msg) {
  if ($DryRun) { Write-Host "[dry-run] $Msg" } else { Write-Host $Msg }
}

function Install-Item([string]$Src, [string]$Dst, [string]$Rel) {
  if (Test-Path -LiteralPath $Dst) {
    $bk = Join-Path $Backup $Rel
    Say "backup   $Dst -> $bk"
    if (-not $DryRun) {
      New-Item -ItemType Directory -Force -Path (Split-Path $bk -Parent) | Out-Null
      Copy-Item -LiteralPath $Dst -Destination $bk -Recurse -Force
    }
    Say "replace  $Dst"
    if (-not $DryRun) {
      $item = Get-Item -LiteralPath $Dst -Force
      if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        # junction or symlink: remove the link only, never its target
        $item.Delete()
      } else {
        Remove-Item -LiteralPath $Dst -Recurse -Force
      }
    }
  } else {
    Say "install  $Dst"
  }
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Dst -Parent) | Out-Null
    Copy-Item -LiteralPath $Src -Destination $Dst -Recurse -Force
  }
  $script:Count++
}

Write-Host "atelier: installing from $Repo into $ClaudeHome"
if ($DryRun) { Write-Host "atelier: DRY RUN - nothing will be written" }

Get-ChildItem -LiteralPath (Join-Path $Repo 'skills') -Directory | ForEach-Object {
  Install-Item $_.FullName (Join-Path $ClaudeHome "skills\$($_.Name)") "skills\$($_.Name)"
}
$personal = Join-Path $Repo 'personal'
if (-not $NoPersonal -and (Test-Path $personal)) {
  Get-ChildItem -LiteralPath $personal -Directory | ForEach-Object {
    Install-Item $_.FullName (Join-Path $ClaudeHome "skills\$($_.Name)") "skills\$($_.Name)"
  }
}
Get-ChildItem -LiteralPath (Join-Path $Repo 'agents') -Filter '*.md' -File | ForEach-Object {
  Install-Item $_.FullName (Join-Path $ClaudeHome "agents\$($_.Name)") "agents\$($_.Name)"
}
if (-not $NoClaudeMd) {
  Install-Item (Join-Path $Repo 'global\CLAUDE.md') (Join-Path $ClaudeHome 'CLAUDE.md') 'CLAUDE.md'
}

Write-Host "atelier: $($script:Count) item(s) processed."
if (-not $DryRun -and (Test-Path $Backup)) { Write-Host "atelier: backups in $Backup" }
Write-Host "atelier: hooks are opt-in - see hooks\README.md. Restart Claude Code to pick up new agents."
