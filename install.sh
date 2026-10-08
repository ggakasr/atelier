#!/usr/bin/env bash
# atelier installer (macOS / Linux / Git Bash on Windows).
# Copies skills/, personal/, agents/ and global/CLAUDE.md into ~/.claude.
# Anything it would replace is first copied to ~/.claude/atelier-backups/<timestamp>/.
#
# Usage: ./install.sh [--dry-run] [--no-personal] [--no-claude-md] [--claude-home DIR]
set -euo pipefail

DRY_RUN=0
WITH_PERSONAL=1
WITH_CLAUDE_MD=1
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

usage() {
  sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
  echo "Options:"
  echo "  --dry-run          print what would happen; change nothing"
  echo "  --no-personal      skip personal/ skills"
  echo "  --no-claude-md     do not install global/CLAUDE.md"
  echo "  --claude-home DIR  target instead of \$CLAUDE_HOME or ~/.claude"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --no-personal) WITH_PERSONAL=0 ;;
    --no-claude-md) WITH_CLAUDE_MD=0 ;;
    --claude-home) shift; [ $# -gt 0 ] || { echo "--claude-home needs a value" >&2; exit 2; }; CLAUDE_HOME="$1" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

REPO="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CLAUDE_HOME/atelier-backups/$STAMP"

[ -d "$REPO/skills" ] && [ -d "$REPO/agents" ] || { echo "Run from the atelier repo (skills/ and agents/ not found next to $0)" >&2; exit 1; }
case "$CLAUDE_HOME" in ""|"/") echo "Refusing CLAUDE_HOME='$CLAUDE_HOME'" >&2; exit 1 ;; esac

say() { if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] $*"; else echo "$*"; fi; }
run() { if [ "$DRY_RUN" -eq 0 ]; then "$@"; fi; }

# install_item <source path> <target path> <backup-relative name>
install_item() {
  src="$1"; dst="$2"; rel="$3"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    say "backup   $dst -> $BACKUP/$rel"
    run mkdir -p "$(dirname "$BACKUP/$rel")"
    run cp -RP "$dst" "$BACKUP/$rel"
    say "replace  $dst"
    run rm -rf -- "$dst"
  else
    say "install  $dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run cp -R "$src" "$dst"
}

echo "atelier: installing from $REPO into $CLAUDE_HOME"
[ "$DRY_RUN" -eq 1 ] && echo "atelier: DRY RUN - nothing will be written"

count=0
for d in "$REPO"/skills/*/; do
  name="$(basename "$d")"
  install_item "${d%/}" "$CLAUDE_HOME/skills/$name" "skills/$name"; count=$((count+1))
done
if [ "$WITH_PERSONAL" -eq 1 ] && [ -d "$REPO/personal" ]; then
  for d in "$REPO"/personal/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    install_item "${d%/}" "$CLAUDE_HOME/skills/$name" "skills/$name"; count=$((count+1))
  done
fi
for f in "$REPO"/agents/*.md; do
  name="$(basename "$f")"
  install_item "$f" "$CLAUDE_HOME/agents/$name" "agents/$name"; count=$((count+1))
done
if [ "$WITH_CLAUDE_MD" -eq 1 ]; then
  install_item "$REPO/global/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" "CLAUDE.md"; count=$((count+1))
fi

echo "atelier: $count item(s) processed."
if [ "$DRY_RUN" -eq 0 ] && [ -d "$BACKUP" ]; then echo "atelier: backups in $BACKUP"; fi
echo "atelier: hooks are opt-in - see hooks/README.md. Restart Claude Code to pick up new agents."
