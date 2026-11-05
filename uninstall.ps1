<#
.SYNOPSIS
  atelier uninstaller for Windows PowerShell 5.1+ / PowerShell 7.
.DESCRIPTION
  Reads ~\.claude\.atelier-manifest (written by install.ps1 or install.sh). Removes only files whose
  current SHA-256 equals the recorded one; files you edited are kept and listed. Folders left empty are
  removed, then the manifest and .atelier-version. Without a manifest it refuses (it never guesses).
  The atelier block in CLAUDE.md / AGENTS.md and the hook wiring in settings.json stay unless you pass
  -RemoveBlock (which strips only the block). Everything removed is first copied to
  ~\.claude\atelier-backups\<timestamp>\.
.EXAMPLE
  .\uninstall.ps1 -DryRun
  .\uninstall.ps1 -RemoveBlock
  .\uninstall.ps1 -ClaudeHome D:\tmp\home\.claude   # AGENTS.md is D:\tmp\home\AGENTS.md
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$RemoveBlock,
  [string]$ClaudeHome = $(if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' })
)
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ClaudeHome)) { throw "ClaudeHome is empty." }
$ClaudeHome = [System.IO.Path]::GetFullPath($ClaudeHome).TrimEnd('\')
if ($ClaudeHome -eq [System.IO.Path]::GetPathRoot($ClaudeHome).TrimEnd('\')) { throw "Refusing a drive root: $ClaudeHome" }

$Stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $ClaudeHome (Join-Path 'atelier-backups' $Stamp)
$ManifestPath = Join-Path $ClaudeHome '.atelier-manifest'
$BeginMark = '<!-- atelier:begin'
$EndMark   = '<!-- atelier:end -->'

function Say([string]$Msg) {
  if ($DryRun) { Write-Host "[dry-run] $Msg" } else { Write-Host $Msg }
}
function Get-Sha([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function ToWin([string]$Rel) { $Rel.Replace('/', '\') }

if (-not (Test-Path -LiteralPath $ManifestPath)) {
  Write-Host "atelier uninstall: no manifest at $ManifestPath - refusing to guess which files are atelier's."
  Write-Host "Nothing was changed. (Installs made before the manifest existed cannot be removed automatically; run install.ps1 once, then uninstall.ps1.)"
  exit 1
}

$lines = [IO.File]::ReadAllLines($ManifestPath)
$entries = New-Object System.Collections.ArrayList
foreach ($l in $lines) {
  if ($l -match '^([0-9a-fA-F]{64})  (.+)$') {
    $p = $Matches[2]
    if ($p -match '^/|:|\\|(^|/)\.\.(/|$)') { Write-Host "WARN     ignoring unsafe manifest entry: $p"; continue }
    [void]$entries.Add([pscustomobject]@{ Rel = $p; Hash = $Matches[1].ToLowerInvariant() })
  }
}

Write-Host "atelier: uninstalling from $ClaudeHome (manifest: $($lines[0]))"
if ($DryRun) { Write-Host "atelier: DRY RUN - nothing will be written" }

$Gone = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$nRemoved = 0; $nKept = 0; $nMissing = 0
$KeptList = New-Object System.Collections.ArrayList
foreach ($e in $entries) {
  $dst = Join-Path $ClaudeHome (ToWin $e.Rel)
  if (-not (Test-Path -LiteralPath $dst)) {
    $nMissing++
  } elseif ((Test-Path -LiteralPath $dst -PathType Leaf) -and (Get-Sha $dst) -eq $e.Hash) {
    $bk = Join-Path $Backup (ToWin $e.Rel)
    Say "backup   $dst -> $bk"
    Say "remove   $dst"
    if (-not $DryRun) {
      New-Item -ItemType Directory -Force -Path (Split-Path $bk -Parent) | Out-Null
      Copy-Item -LiteralPath $dst -Destination $bk -Force
      Remove-Item -LiteralPath $dst -Force
    }
    [void]$Gone.Add($dst)
    $nRemoved++
  } else {
    Write-Host "KEPT     $dst (edited by you or not a plain file)"
    [void]$KeptList.Add($dst)
    $nKept++
  }
  # the <file>.atelier-new copy written by install is atelier's own, never yours
  $alt = "$dst.atelier-new"
  if (Test-Path -LiteralPath $alt -PathType Leaf) {
    Say "remove   $alt"
    if (-not $DryRun) { Remove-Item -LiteralPath $alt -Force }
    [void]$Gone.Add($alt)
  }
}

# folders left empty, deepest first (a folder counts as empty when only removed things are inside)
$dirs = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($e in $entries) {
  $p = Split-Path (Join-Path $ClaudeHome (ToWin $e.Rel)) -Parent
  while ($p.Length -gt $ClaudeHome.Length -and $p.StartsWith($ClaudeHome + '\', [StringComparison]::OrdinalIgnoreCase)) { [void]$dirs.Add($p); $p = Split-Path $p -Parent }
}
foreach ($d in ($dirs | Sort-Object { $_.Length } -Descending)) {
  if (-not (Test-Path -LiteralPath $d -PathType Container)) { continue }
  $left = @(Get-ChildItem -LiteralPath $d -Force -Recurse | Where-Object { -not $Gone.Contains($_.FullName) })
  if ($left.Count -eq 0) {
    Say "rmdir    $d"
    [void]$Gone.Add($d)
    if (-not $DryRun) { Remove-Item -LiteralPath $d -Force }
  }
}

Say "remove   $ManifestPath and $ClaudeHome\.atelier-version"
if (-not $DryRun) {
  Remove-Item -LiteralPath $ManifestPath -Force
  $vf = Join-Path $ClaudeHome '.atelier-version'
  if (Test-Path -LiteralPath $vf) { Remove-Item -LiteralPath $vf -Force }
}

# strips from the first begin marker through the first end marker after it
function Strip-Block([string]$File) {
  if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { Write-Host "block    $File not found - nothing to strip"; return }
  $enc = New-Object System.Text.UTF8Encoding($false)
  $text = [IO.File]::ReadAllText($File)
  $b = $text.IndexOf($BeginMark, [StringComparison]::Ordinal)
  $e = if ($b -ge 0) { $text.IndexOf($EndMark, $b, [StringComparison]::Ordinal) } else { -1 }
  if ($b -lt 0 -or $e -lt 0) { Write-Host "block    no atelier block in $File"; return }
  Say "backup   $File -> $File.atelier-bak-<timestamp>"
  Say "block    strip atelier block from $File"
  if (-not $DryRun) {
    $ms = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    [IO.File]::WriteAllText("$File.atelier-bak-$ms", $text, $enc)
    [IO.File]::WriteAllText($File, $text.Substring(0, $b) + $text.Substring($e + $EndMark.Length), $enc)
  }
}
$AgentsMd = Join-Path (Split-Path -Parent $ClaudeHome) 'AGENTS.md'
if ($RemoveBlock) {
  Strip-Block (Join-Path $ClaudeHome 'CLAUDE.md')
  Strip-Block $AgentsMd
} else {
  Write-Host "atelier: left in place - the atelier block in $ClaudeHome\CLAUDE.md and $AgentsMd,"
  Write-Host "         and the hook entries in $ClaudeHome\settings.json (they point at ~/.claude/hooks/*, now gone)."
  Write-Host "         Strip the block with: .\uninstall.ps1 -RemoveBlock   (only the text between the atelier:begin/end markers)."
  Write-Host "         Remove the hooks by hand: delete the skill-router.js, skill-gap.sh, foreman-nudge.sh and git-guard.sh entries under `"hooks`" in settings.json."
}

Write-Host "atelier: $nRemoved file(s) removed, $nKept kept (edited by you), $nMissing already gone."
if ($nKept -gt 0) { Write-Host "atelier: kept files:"; $KeptList | ForEach-Object { Write-Host "           $_" } }
if (-not $DryRun -and (Test-Path $Backup)) { Write-Host "atelier: backups in $Backup" }
Write-Host "atelier: uninstalled."
