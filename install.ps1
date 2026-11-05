<#
.SYNOPSIS
  atelier installer for Windows PowerShell 5.1+ / PowerShell 7.
.DESCRIPTION
  Copies skills\, personal\, agents\ and hooks\ into ~\.claude, merges the atelier block
  from global\CLAUDE.md into ~\.claude\CLAUDE.md and ~\AGENTS.md (the parent folder of
  -ClaudeHome). Hooks are only wired into settings.json with -WireHooks.

  Every copied file is recorded with its SHA-256 in ~\.claude\.atelier-manifest (same format
  as install.sh / sha256sum, so the two installers and the two uninstallers are interchangeable).
  Per file:
    missing                          -> installed
    identical to the repo copy       -> left alone
    unchanged since last install     -> backed up, replaced
    edited by you (hash differs from the manifest) -> KEPT; the new version is written next to
                                        it as <file>.atelier-new and a WARN line is printed.
                                        -Force backs it up and overwrites it instead.
    present but not in a manifest    -> adopted: backed up, replaced
  Files that were removed from the repo are deleted if you never edited them (backed up first).
  Anything replaced or deleted is first copied to ~\.claude\atelier-backups\<timestamp>\.
  To change a skill, edit the repo copy, not the installed one. Remove everything again with
  uninstall.ps1.
.EXAMPLE
  .\install.ps1 -DryRun
  .\install.ps1 -NoPersonal
  .\install.ps1 -Force            # overwrite files you edited (after a backup)
  .\install.ps1 -ClaudeHome D:\tmp\home\.claude   # AGENTS.md goes to D:\tmp\home\AGENTS.md
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$NoPersonal,
  [switch]$NoClaudeMd,
  [switch]$WireHooks,
  [switch]$Force,
  [string]$ClaudeHome = $(if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' })
)
$ErrorActionPreference = 'Stop'

$Repo = $PSScriptRoot
if (-not (Test-Path (Join-Path $Repo 'skills')) -or -not (Test-Path (Join-Path $Repo 'agents'))) {
  throw "Run from the atelier repo (skills\ and agents\ not found next to install.ps1)."
}
if ([string]::IsNullOrWhiteSpace($ClaudeHome)) { throw "ClaudeHome is empty." }
$ClaudeHome = [System.IO.Path]::GetFullPath($ClaudeHome).TrimEnd('\')
if ($ClaudeHome -eq [System.IO.Path]::GetPathRoot($ClaudeHome).TrimEnd('\')) { throw "Refusing to install into a drive root: $ClaudeHome" }

$Stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $ClaudeHome (Join-Path 'atelier-backups' $Stamp)
$ManifestPath = Join-Path $ClaudeHome '.atelier-manifest'

# version: VERSION file, else short git hash, else 'dev'
$Version = $null
$vf = Join-Path $Repo 'VERSION'
if (Test-Path -LiteralPath $vf) {
  $line = Get-Content -LiteralPath $vf | Select-Object -First 1
  if ($line) { $Version = "$line".Trim() }
}
if (-not $Version) {
  try { $g = & git -C $Repo rev-parse --short HEAD 2>$null; if ($LASTEXITCODE -eq 0 -and $g) { $Version = "$g".Trim() } } catch { }
}
if (-not $Version) { $Version = 'dev' }

function Say([string]$Msg) {
  if ($DryRun) { Write-Host "[dry-run] $Msg" } else { Write-Host $Msg }
}
function Get-Sha([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function ToWin([string]$Rel) { $Rel.Replace('/', '\') }

# old manifest: relative path (forward slashes) -> sha256. Entries that could escape claude-home are ignored.
$Old = @{}
if (Test-Path -LiteralPath $ManifestPath) {
  foreach ($l in [IO.File]::ReadAllLines($ManifestPath)) {
    if ($l -match '^([0-9a-fA-F]{64})  (.+)$') {
      $p = $Matches[2]
      if ($p -match '^/|:|\\|(^|/)\.\.(/|$)') { Write-Host "WARN     ignoring unsafe manifest entry: $p"; continue }
      $Old[$p] = $Matches[1].ToLowerInvariant()
    }
  }
}
$New = $Old.Clone()
$n = @{ new = 0; same = 0; update = 0; adopt = 0; force = 0; kept = 0; removed = 0 }
$KeptList = New-Object System.Collections.ArrayList
$Sources = New-Object System.Collections.ArrayList

function Add-Files([string]$Dir, [string]$RelPrefix, [bool]$Skip) {
  $base = (Get-Item -LiteralPath $Dir).FullName.TrimEnd('\')
  Get-ChildItem -LiteralPath $Dir -Recurse -File -Force | ForEach-Object {
    $sub = $_.FullName.Substring($base.Length + 1).Replace('\', '/')
    [void]$Sources.Add([pscustomobject]@{ Src = $_.FullName; Rel = "$RelPrefix/$sub"; Skip = $Skip })
  }
}

function Backup-File([string]$Dst, [string]$Rel) {
  $bk = Join-Path $Backup (ToWin $Rel)
  Say "backup   $Dst -> $bk"
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path $bk -Parent) | Out-Null
    Copy-Item -LiteralPath $Dst -Destination $bk -Force
  }
}

function Copy-File([string]$Src, [string]$Dst) {
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Dst -Parent) | Out-Null
    Copy-Item -LiteralPath $Src -Destination $Dst -Force
  }
}

function Remove-EmptyParents([string]$Path) {
  $p = Split-Path $Path -Parent
  while ($p -and $p.Length -gt $ClaudeHome.Length -and $p.StartsWith($ClaudeHome + '\') -and -not (Get-ChildItem -LiteralPath $p -Force | Select-Object -First 1)) {
    Remove-Item -LiteralPath $p -Force
    $p = Split-Path $p -Parent
  }
}

# a skill folder that is itself a junction/symlink: remove the link only (never its target), then install real files
function Unlink-SkillDir([string]$Name) {
  $d = Join-Path $ClaudeHome "skills\$Name"
  if (-not (Test-Path -LiteralPath $d)) { return }
  $item = Get-Item -LiteralPath $d -Force
  if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return }
  $bk = Join-Path $Backup "skills\$Name"
  Say "backup   $d (link) -> $bk"
  Say "unlink   $d"
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path $bk -Parent) | Out-Null
    Copy-Item -LiteralPath $d -Destination $bk -Recurse -Force
    $item.Delete()
  }
}

function Install-File([string]$Src, [string]$Rel) {
  $dst = Join-Path $ClaudeHome (ToWin $Rel)
  if (Test-Path -LiteralPath $dst -PathType Container) { Write-Host "WARN     $dst is a folder, expected a file; skipped"; return }
  $srcHash = Get-Sha $Src
  if (-not (Test-Path -LiteralPath $dst)) {
    Say "install  $dst"
    Copy-File $Src $dst
    $New[$Rel] = if ($DryRun) { $srcHash } else { Get-Sha $dst }
    $n.new++; return
  }
  $dstHash = Get-Sha $dst
  if ($dstHash -eq $srcHash) { $New[$Rel] = $dstHash; $n.same++; return }
  $rec = $Old[$Rel]
  if ($rec -and $dstHash -ne $rec -and -not $Force) {
    $alt = "$dst.atelier-new"
    Write-Host "WARN     $dst was edited by you - KEPT. New version: $alt (merge it, or re-run with -Force to overwrite)"
    Copy-File $Src $alt
    [void]$KeptList.Add($dst)
    $n.kept++; return
  }
  $kind = if (-not $rec) { 'adopt' } elseif ($dstHash -ne $rec) { 'force' } else { 'update' }
  Backup-File $dst $Rel
  Say "replace  $dst ($kind)"
  Copy-File $Src $dst
  $New[$Rel] = if ($DryRun) { $srcHash } else { Get-Sha $dst }
  $n[$kind]++
}

function Write-Manifest {
  $keys = [string[]]@($New.Keys)
  [Array]::Sort($keys, [StringComparer]::Ordinal)
  $text = "# atelier $Version`n"
  foreach ($k in $keys) { $text += "$($New[$k])  $k`n" }
  $enc = New-Object System.Text.UTF8Encoding($false)
  New-Item -ItemType Directory -Force -Path $ClaudeHome | Out-Null
  $tmp = "$ManifestPath.tmp"
  [IO.File]::WriteAllText($tmp, $text, $enc)
  Move-Item -LiteralPath $tmp -Destination $ManifestPath -Force
  [IO.File]::WriteAllText((Join-Path $ClaudeHome '.atelier-version'), "$Version`n", $enc)
}

Write-Host "atelier: installing from $Repo into $ClaudeHome"
if ($DryRun) { Write-Host "atelier: DRY RUN - nothing will be written" }

$skillDirs = @()
Get-ChildItem -LiteralPath (Join-Path $Repo 'skills') -Directory | ForEach-Object {
  $skillDirs += [pscustomobject]@{ Dir = $_.FullName; Name = $_.Name; Skip = $false }
}
$personal = Join-Path $Repo 'personal'
if (Test-Path $personal) {
  Get-ChildItem -LiteralPath $personal -Directory | ForEach-Object {
    $skillDirs += [pscustomobject]@{ Dir = $_.FullName; Name = $_.Name; Skip = [bool]$NoPersonal }
  }
}
foreach ($s in $skillDirs) { Add-Files $s.Dir "skills/$($s.Name)" $s.Skip }
Get-ChildItem -LiteralPath (Join-Path $Repo 'agents') -Filter '*.md' -File | ForEach-Object {
  [void]$Sources.Add([pscustomobject]@{ Src = $_.FullName; Rel = "agents/$($_.Name)"; Skip = $false })
}
Get-ChildItem -LiteralPath (Join-Path $Repo 'hooks') -File | Where-Object { $_.Extension -in '.sh', '.js' } | ForEach-Object {
  [void]$Sources.Add([pscustomobject]@{ Src = $_.FullName; Rel = "hooks/$($_.Name)"; Skip = $false })
}

$Seen = @{}
try {
  foreach ($s in $skillDirs) { if (-not $s.Skip) { Unlink-SkillDir $s.Name } }
  foreach ($f in $Sources) {
    $Seen[$f.Rel] = $true
    if (-not $f.Skip) { Install-File $f.Src $f.Rel }   # skipped (-NoPersonal) files keep their old record
  }
  # recorded files that no longer exist in the repo
  foreach ($rel in @($Old.Keys | Sort-Object)) {
    if ($Seen.ContainsKey($rel)) { continue }
    $dst = Join-Path $ClaudeHome (ToWin $rel)
    if (-not (Test-Path -LiteralPath $dst -PathType Leaf)) { $New.Remove($rel); continue }
    if ((Get-Sha $dst) -eq $Old[$rel]) {
      Backup-File $dst $rel
      Say "remove   $dst (no longer in the repo)"
      if (-not $DryRun) { Remove-Item -LiteralPath $dst -Force; Remove-EmptyParents $dst }
      $New.Remove($rel); $n.removed++
    } else {
      Write-Host "WARN     $dst is no longer in the repo but was edited by you - KEPT"
      [void]$KeptList.Add($dst); $n.kept++
    }
  }
} finally {
  if (-not $DryRun) { Write-Manifest }
}

if (-not $NoClaudeMd) {
  Say "merge    atelier block -> $ClaudeHome\CLAUDE.md (your other content is kept; a .atelier-bak copy is made)"
  if (-not $DryRun) { node (Join-Path $Repo 'hooks\wire.js') claude-md (Join-Path $ClaudeHome 'CLAUDE.md') (Join-Path $Repo 'global\CLAUDE.md'); if ($LASTEXITCODE) { throw 'node merge failed' } }
  $AgentsMd = Join-Path (Split-Path -Parent $ClaudeHome) 'AGENTS.md'
  Say "merge    atelier block -> $AgentsMd (your other content is kept; a .atelier-bak copy is made)"
  if (-not $DryRun) { node (Join-Path $Repo 'hooks\wire.js') agents-md $AgentsMd (Join-Path $Repo 'global\CLAUDE.md'); if ($LASTEXITCODE) { throw 'node merge failed' } }
}
if ($WireHooks) {
  Say "wire     hooks -> $ClaudeHome\settings.json"
  if (-not $DryRun) { node (Join-Path $Repo 'hooks\wire.js') settings (Join-Path $ClaudeHome 'settings.json'); if ($LASTEXITCODE) { throw 'node wire failed' } }
}

Write-Host "atelier: $($New.Count) file(s) tracked - $($n.new) new, $($n.update) updated, $($n.same) unchanged, $($n.adopt) adopted, $($n.force) forced, $($n.kept) kept (edited by you), $($n.removed) removed."
if ($n.adopt -gt 0) { Write-Host "atelier: note - $($n.adopt) pre-existing file(s) had no manifest entry and were adopted (backed up, then replaced)." }
if ($KeptList.Count -gt 0) { Write-Host "atelier: WARN - $($KeptList.Count) edited file(s) kept; see the .atelier-new files next to them, or re-run with -Force."; $KeptList | ForEach-Object { Write-Host "           $_" } }
if (-not $DryRun -and (Test-Path $Backup)) { Write-Host "atelier: backups in $Backup" }
if (-not $WireHooks) { Write-Host "atelier: hooks are copied but not active - re-run with -WireHooks (see hooks\README.md)." }
Write-Host "atelier: restart Claude Code to pick up new agents and hooks."
Write-Host "atelier $Version"
