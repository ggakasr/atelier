#!/usr/bin/env bash
# atelier uninstaller (macOS / Linux / Git Bash on Windows). Reads ~/.claude/.atelier-manifest (written by install.sh or install.ps1).
# Removes only files whose current SHA-256 equals the recorded one; files you edited are kept and listed. Empty folders are removed,
# then the manifest and .atelier-version. Without a manifest it refuses (it never guesses what is atelier's).
# The atelier block in CLAUDE.md / AGENTS.md and the hook wiring in settings.json stay unless you pass --remove-block (block only).
# Everything removed is first copied to ~/.claude/atelier-backups/<timestamp>/.
#
# Usage: ./uninstall.sh [--dry-run] [--remove-block] [--claude-home DIR]
set -euo pipefail

DRY_RUN=0
REMOVE_BLOCK=0
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

usage() {
  sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
  echo "Options:"
  echo "  --dry-run          print what would happen; change nothing"
  echo "  --remove-block     also strip the atelier block from CLAUDE.md and AGENTS.md (backup first)"
  echo "  --claude-home DIR  target instead of \$CLAUDE_HOME or ~/.claude (AGENTS.md is DIR/../AGENTS.md)"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --remove-block) REMOVE_BLOCK=1 ;;
    --claude-home) shift; [ $# -gt 0 ] || { echo "--claude-home needs a value" >&2; exit 2; }; CLAUDE_HOME="$1" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

CLAUDE_HOME="${CLAUDE_HOME%/}"
case "$CLAUDE_HOME" in ""|"/") echo "Refusing CLAUDE_HOME='$CLAUDE_HOME'" >&2; exit 1 ;; esac
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CLAUDE_HOME/atelier-backups/$STAMP"
MANIFEST="$CLAUDE_HOME/.atelier-manifest"
BEGIN_MARK='<!-- atelier:begin'
END_MARK='<!-- atelier:end -->'

say() { if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] $*"; else echo "$*"; fi; }
run() { if [ "$DRY_RUN" -eq 0 ]; then "$@"; fi; }
sha() { { sha256sum < "$1" 2>/dev/null || shasum -a 256 < "$1"; } | cut -c1-64; }

if [ ! -f "$MANIFEST" ]; then
  echo "atelier uninstall: no manifest at $MANIFEST - refusing to guess which files are atelier's." >&2
  echo "Nothing was changed. (Installs made before the manifest existed cannot be removed automatically; run install.sh once, then uninstall.sh.)" >&2
  exit 1
fi

TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT
GONE="$TMPD/gone"; : > "$GONE"
# manifest lines "<sha256>  <relative path>"; entries that could escape claude-home are dropped
tr -d '\r' < "$MANIFEST" | awk 'length($0)>66 && substr($0,65,2)=="  " && substr($0,1,64) ~ /^[0-9a-fA-F]+$/ {
  p=substr($0,67); if (p ~ /^\// || p ~ /:/ || p ~ /\\/ || p ~ /(^|\/)\.\.(\/|$)/) next; print tolower(substr($0,1,64)) "  " p }' > "$TMPD/m"

echo "atelier: uninstalling from $CLAUDE_HOME (manifest: $(head -n1 "$MANIFEST" | tr -d '\r'))"
[ "$DRY_RUN" -eq 1 ] && echo "atelier: DRY RUN - nothing will be written"

n_removed=0; n_kept=0; n_missing=0; KEPT_LIST=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  rel="${line:66}"; h="${line:0:64}"; dst="$CLAUDE_HOME/$rel"
  if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
    n_missing=$((n_missing+1))
  elif [ -f "$dst" ] && [ "$(sha "$dst")" = "$h" ]; then
    say "backup   $dst -> $BACKUP/$rel"
    run mkdir -p "$(dirname "$BACKUP/$rel")"
    run cp "$dst" "$BACKUP/$rel"
    say "remove   $dst"
    run rm -f -- "$dst"
    echo "$dst" >> "$GONE"
    n_removed=$((n_removed+1))
  else
    echo "KEPT     $dst (edited by you or not a plain file)"
    KEPT_LIST="$KEPT_LIST$dst"$'\n'
    n_kept=$((n_kept+1))
  fi
  # the <file>.atelier-new copy written by install is atelier's own, never yours
  if [ -f "$dst.atelier-new" ]; then
    say "remove   $dst.atelier-new"
    run rm -f -- "$dst.atelier-new"
    echo "$dst.atelier-new" >> "$GONE"
  fi
done < "$TMPD/m"

# folders left empty, deepest first (a folder counts as empty when only removed things are inside)
while IFS= read -r line; do
  [ -n "$line" ] || continue
  p="$(dirname "$CLAUDE_HOME/${line:66}")"
  while [ "$p" != "$CLAUDE_HOME" ] && [ "${p#"$CLAUDE_HOME"/}" != "$p" ]; do echo "$p"; p="$(dirname "$p")"; done
done < "$TMPD/m" | sort -u | awk '{print length($0) " " $0}' | sort -rn | cut -d' ' -f2- > "$TMPD/dirs"
while IFS= read -r d; do
  [ -d "$d" ] || continue
  if [ -z "$(find "$d" -mindepth 1 | grep -vxFf "$GONE" | head -n1)" ]; then
    say "rmdir    $d"
    echo "$d" >> "$GONE"
    run rmdir "$d"
  fi
done < "$TMPD/dirs"

say "remove   $MANIFEST and $CLAUDE_HOME/.atelier-version"
run rm -f -- "$MANIFEST" "$CLAUDE_HOME/.atelier-version"

# $1 = file; strips from the first begin marker through the first end marker after it
strip_block() {
  local f="$1"
  if [ ! -f "$f" ]; then echo "block    $f not found - nothing to strip"; return 0; fi
  if ! awk -v B="$BEGIN_MARK" -v E="$END_MARK" 'index($0,B)&&!b{b=NR} index($0,E)&&b&&!e{e=NR} END{exit !(b&&e)}' "$f"; then
    echo "block    no atelier block in $f"; return 0
  fi
  say "backup   $f -> $f.atelier-bak-<timestamp>"
  say "block    strip atelier block from $f"
  if [ "$DRY_RUN" -eq 0 ]; then
    cp "$f" "$f.atelier-bak-$(date +%s)"
    awk -v B="$BEGIN_MARK" -v E="$END_MARK" 's==0 && index($0,B) {s=1} s!=1 {print} s==1 && index($0,E) {s=2}' "$f" > "$TMPD/stripped"
    cat "$TMPD/stripped" > "$f"
  fi
}
AGENTS_MD="$(dirname "$CLAUDE_HOME")/AGENTS.md"
if [ "$REMOVE_BLOCK" -eq 1 ]; then
  strip_block "$CLAUDE_HOME/CLAUDE.md"
  strip_block "$AGENTS_MD"
else
  echo "atelier: left in place - the atelier block in $CLAUDE_HOME/CLAUDE.md and $AGENTS_MD,"
  echo "         and the hook entries in $CLAUDE_HOME/settings.json (they point at ~/.claude/hooks/*, now gone)."
  echo "         Strip the block with: ./uninstall.sh --remove-block   (only the text between the atelier:begin/end markers)."
  echo "         Remove the hooks by hand: delete the skill-router.js, skill-gap.sh, foreman-nudge.sh, git-guard.sh and giveup-guard.sh entries under \"hooks\" in settings.json."
fi

echo "atelier: $n_removed file(s) removed, $n_kept kept (edited by you), $n_missing already gone."
if [ "$n_kept" -gt 0 ]; then echo "atelier: kept files:"; printf '%s' "$KEPT_LIST" | sed 's/^/           /'; fi
if [ "$DRY_RUN" -eq 0 ] && [ -d "$BACKUP" ]; then echo "atelier: backups in $BACKUP"; fi
echo "atelier: uninstalled."
