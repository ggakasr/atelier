#!/usr/bin/env bash
# atelier installer (macOS / Linux / Git Bash on Windows).
# Copies skills/, personal/, agents/ and hooks/ into ~/.claude and merges the atelier block into CLAUDE.md and AGENTS.md
# (the parent folder of --claude-home). Hooks are only wired into settings.json with --wire-hooks.
# Every copied file is recorded with its SHA-256 in ~/.claude/.atelier-manifest (sha256sum format; install.ps1 reads it too).
# Per file: missing -> installed; identical -> left alone; unchanged since last install -> backed up, replaced;
#   edited by you -> KEPT, new version written as <file>.atelier-new plus a WARN (--force backs up and overwrites);
#   present but not in a manifest -> adopted (backed up, replaced). Files removed from the repo are deleted if you never edited them.
# Anything replaced or deleted is first copied to ~/.claude/atelier-backups/<timestamp>/.
# To change a skill, edit the repo copy, not the installed one. Undo everything with uninstall.sh.
#
# Usage: ./install.sh [--dry-run] [--no-personal] [--no-claude-md] [--wire-hooks] [--force] [--claude-home DIR]
set -euo pipefail

DRY_RUN=0
WITH_PERSONAL=1
WITH_CLAUDE_MD=1
WIRE_HOOKS=0
FORCE=0
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  echo "Options:"
  echo "  --dry-run          print what would happen; change nothing"
  echo "  --no-personal      skip personal/ skills"
  echo "  --no-claude-md     do not merge the atelier block into CLAUDE.md / AGENTS.md"
  echo "  --wire-hooks       also register the hooks in settings.json (needs node)"
  echo "  --force            overwrite files you edited (after a backup) instead of writing <file>.atelier-new"
  echo "  --claude-home DIR  target instead of \$CLAUDE_HOME or ~/.claude (AGENTS.md goes to DIR/../AGENTS.md)"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --no-personal) WITH_PERSONAL=0 ;;
    --no-claude-md) WITH_CLAUDE_MD=0 ;;
    --wire-hooks) WIRE_HOOKS=1 ;;
    --force) FORCE=1 ;;
    --claude-home) shift; [ $# -gt 0 ] || { echo "--claude-home needs a value" >&2; exit 2; }; CLAUDE_HOME="$1" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

REPO="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
CLAUDE_HOME="${CLAUDE_HOME%/}"
BACKUP="$CLAUDE_HOME/atelier-backups/$STAMP"
MANIFEST="$CLAUDE_HOME/.atelier-manifest"

[ -d "$REPO/skills" ] && [ -d "$REPO/agents" ] || { echo "Run from the atelier repo (skills/ and agents/ not found next to $0)" >&2; exit 1; }
case "$CLAUDE_HOME" in ""|"/") echo "Refusing CLAUDE_HOME='$CLAUDE_HOME'" >&2; exit 1 ;; esac

say() { if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] $*"; else echo "$*"; fi; }
run() { if [ "$DRY_RUN" -eq 0 ]; then "$@"; fi; }
sha() { { sha256sum < "$1" 2>/dev/null || shasum -a 256 < "$1"; } | cut -c1-64; }

# version: VERSION file, else short git hash, else 'dev'
VERSION_STR=""
if [ -f "$REPO/VERSION" ]; then VERSION_STR="$(head -n1 "$REPO/VERSION" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"; fi
[ -n "$VERSION_STR" ] || VERSION_STR="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || true)"
[ -n "$VERSION_STR" ] || VERSION_STR="dev"

TMPD="$(mktemp -d)"
OLDF="$TMPD/old"; NEWF="$TMPD/new"; SEENF="$TMPD/seen"
: > "$OLDF"; : > "$NEWF"; : > "$SEENF"
# old manifest: "<sha256>  <relative path>" lines; entries that could escape claude-home are dropped
if [ -f "$MANIFEST" ]; then
  tr -d '\r' < "$MANIFEST" | awk 'length($0)>66 && substr($0,65,2)=="  " && substr($0,1,64) ~ /^[0-9a-fA-F]+$/ {
    p=substr($0,67); if (p ~ /^\// || p ~ /:/ || p ~ /\\/ || p ~ /(^|\/)\.\.(\/|$)/) next; print tolower(substr($0,1,64)) "  " p }' > "$OLDF"
fi

n_new=0; n_same=0; n_update=0; n_adopt=0; n_force=0; n_kept=0; n_removed=0
KEPT_LIST=""
STARTED=0; FINISHED=0

record() { printf '%s  %s\n' "$2" "$1" >> "$NEWF"; }
old_hash() { awk -v r="$1" 'substr($0,67)==r {print substr($0,1,64); exit}' "$OLDF"; }

write_manifest() { # $1 = "union": also keep old records not present in the new list (used if the run aborts)
  mkdir -p "$CLAUDE_HOME"
  { echo "# atelier $VERSION_STR"
    { cat "$NEWF"
      if [ "${1:-}" = "union" ]; then awk 'FILENAME==ARGV[1]{seen[substr($0,67)]=1; next} !(substr($0,67) in seen)' "$NEWF" "$OLDF"; fi
    } | LC_ALL=C sort -k2
  } > "$MANIFEST.tmp"
  mv -f "$MANIFEST.tmp" "$MANIFEST"
  printf '%s\n' "$VERSION_STR" > "$CLAUDE_HOME/.atelier-version"
}
on_exit() {
  if [ "$STARTED" -eq 1 ] && [ "$FINISHED" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then write_manifest union || true; fi
  rm -rf "$TMPD"
}
trap on_exit EXIT

backup_file() { # <dst> <rel>
  say "backup   $1 -> $BACKUP/$2"
  run mkdir -p "$(dirname "$BACKUP/$2")"
  run cp "$1" "$BACKUP/$2"
}
copy_file() { run mkdir -p "$(dirname "$2")"; run cp "$1" "$2"; } # <src> <dst>
remove_empty_parents() { # <path>: remove emptied folders below claude-home
  local p; p="$(dirname "$1")"
  while [ "$p" != "$CLAUDE_HOME" ] && [ "${p#"$CLAUDE_HOME"/}" != "$p" ] && [ -d "$p" ] && [ -z "$(ls -A "$p")" ]; do
    rmdir "$p"; p="$(dirname "$p")"
  done
}

# a skill folder that is itself a symlink: remove the link only (never its target), then install real files
unlink_skill_dir() { # <name>
  local d="$CLAUDE_HOME/skills/$1"
  if [ -L "$d" ]; then
    say "backup   $d (link) -> $BACKUP/skills/$1"
    say "unlink   $d"
    run mkdir -p "$BACKUP/skills"
    run cp -RP "$d" "$BACKUP/skills/$1"
    run rm -- "$d"
  fi
}

install_file() { # <src> <rel>
  local src="$1" rel="$2" dst="$CLAUDE_HOME/$2" sh_src sh_dst rec kind
  if [ -d "$dst" ] && [ ! -L "$dst" ]; then echo "WARN     $dst is a folder, expected a file; skipped"; return 0; fi
  sh_src="$(sha "$src")"
  if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
    say "install  $dst"
    copy_file "$src" "$dst"
    if [ "$DRY_RUN" -eq 1 ]; then record "$rel" "$sh_src"; else record "$rel" "$(sha "$dst")"; fi
    n_new=$((n_new+1)); return 0
  fi
  if [ ! -f "$dst" ]; then echo "WARN     $dst is not a regular file; skipped"; return 0; fi
  sh_dst="$(sha "$dst")"
  if [ "$sh_dst" = "$sh_src" ]; then record "$rel" "$sh_dst"; n_same=$((n_same+1)); return 0; fi
  rec="$(old_hash "$rel")"
  if [ -n "$rec" ] && [ "$sh_dst" != "$rec" ] && [ "$FORCE" -eq 0 ]; then
    echo "WARN     $dst was edited by you - KEPT. New version: $dst.atelier-new (merge it, or re-run with --force to overwrite)"
    copy_file "$src" "$dst.atelier-new"
    record "$rel" "$rec"
    KEPT_LIST="$KEPT_LIST$dst"$'\n'
    n_kept=$((n_kept+1)); return 0
  fi
  if [ -z "$rec" ]; then kind=adopt; elif [ "$sh_dst" != "$rec" ]; then kind=force; else kind=update; fi
  backup_file "$dst" "$rel"
  say "replace  $dst ($kind)"
  copy_file "$src" "$dst"
  if [ "$DRY_RUN" -eq 1 ]; then record "$rel" "$sh_src"; else record "$rel" "$(sha "$dst")"; fi
  eval "n_$kind=\$((n_$kind+1))"
}

# handle_tree <dir> <rel prefix> <skip 0|1>: every file below dir
handle_tree() {
  local dir="$1" prefix="$2" skip="$3" f rel h
  while IFS= read -r f; do
    rel="$prefix/${f#"$dir"/}"
    echo "$rel" >> "$SEENF"
    if [ "$skip" -eq 1 ]; then # skipped (--no-personal) files keep their old record
      h="$(old_hash "$rel")"; [ -z "$h" ] || record "$rel" "$h"
    else
      install_file "$f" "$rel"
    fi
  done < <(find "$dir" -type f | LC_ALL=C sort)
}

echo "atelier: installing from $REPO into $CLAUDE_HOME"
[ "$DRY_RUN" -eq 1 ] && echo "atelier: DRY RUN - nothing will be written"

STARTED=1
for d in "$REPO"/skills/*/; do
  name="$(basename "$d")"
  unlink_skill_dir "$name"
  handle_tree "${d%/}" "skills/$name" 0
done
if [ -d "$REPO/personal" ]; then
  pskip=$((1 - WITH_PERSONAL))
  for d in "$REPO"/personal/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ "$pskip" -eq 1 ] || unlink_skill_dir "$name"
    handle_tree "${d%/}" "skills/$name" "$pskip"
  done
fi
for f in "$REPO"/agents/*.md; do
  name="$(basename "$f")"
  echo "agents/$name" >> "$SEENF"
  install_file "$f" "agents/$name"
done
for f in "$REPO"/hooks/*.sh "$REPO"/hooks/*.js; do
  name="$(basename "$f")"
  echo "hooks/$name" >> "$SEENF"
  install_file "$f" "hooks/$name"
done

# recorded files that no longer exist in the repo
awk 'FILENAME==ARGV[1]{seen[$0]=1; next} !(substr($0,67) in seen)' "$SEENF" "$OLDF" > "$TMPD/stale"
while IFS= read -r line; do
  [ -n "$line" ] || continue
  rel="${line:66}"; h="${line:0:64}"; dst="$CLAUDE_HOME/$rel"
  [ -f "$dst" ] || continue
  if [ "$(sha "$dst")" = "$h" ]; then
    backup_file "$dst" "$rel"
    say "remove   $dst (no longer in the repo)"
    if [ "$DRY_RUN" -eq 0 ]; then rm -f -- "$dst"; remove_empty_parents "$dst"; fi
    n_removed=$((n_removed+1))
  else
    echo "WARN     $dst is no longer in the repo but was edited by you - KEPT"
    record "$rel" "$h"
    KEPT_LIST="$KEPT_LIST$dst"$'\n'
    n_kept=$((n_kept+1))
  fi
done < "$TMPD/stale"

[ "$DRY_RUN" -eq 1 ] || write_manifest
FINISHED=1
tracked="$(wc -l < "$NEWF" | tr -d ' ')"

if [ "$WITH_CLAUDE_MD" -eq 1 ]; then
  say "merge    atelier block -> $CLAUDE_HOME/CLAUDE.md (your other content is kept; a .atelier-bak copy is made)"
  run node "$REPO/hooks/wire.js" claude-md "$CLAUDE_HOME/CLAUDE.md" "$REPO/global/CLAUDE.md"
  AGENTS_MD="$(dirname "$CLAUDE_HOME")/AGENTS.md"
  say "merge    atelier block -> $AGENTS_MD (your other content is kept; a .atelier-bak copy is made)"
  run node "$REPO/hooks/wire.js" agents-md "$AGENTS_MD" "$REPO/global/CLAUDE.md"
fi
if [ "$WIRE_HOOKS" -eq 1 ]; then
  say "wire     hooks -> $CLAUDE_HOME/settings.json"
  run node "$REPO/hooks/wire.js" settings "$CLAUDE_HOME/settings.json"
fi

echo "atelier: $tracked file(s) tracked - $n_new new, $n_update updated, $n_same unchanged, $n_adopt adopted, $n_force forced, $n_kept kept (edited by you), $n_removed removed."
[ "$n_adopt" -eq 0 ] || echo "atelier: note - $n_adopt pre-existing file(s) had no manifest entry and were adopted (backed up, then replaced)."
if [ "$n_kept" -gt 0 ]; then
  echo "atelier: WARN - $n_kept edited file(s) kept; see the .atelier-new files next to them, or re-run with --force."
  printf '%s' "$KEPT_LIST" | sed 's/^/           /'
fi
if [ "$DRY_RUN" -eq 0 ] && [ -d "$BACKUP" ]; then echo "atelier: backups in $BACKUP"; fi
[ "$WIRE_HOOKS" -eq 1 ] || echo "atelier: hooks are copied but not active - re-run with --wire-hooks (see hooks/README.md)."
echo "atelier: restart Claude Code to pick up new agents and hooks."
echo "atelier $VERSION_STR"
