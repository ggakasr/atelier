#!/usr/bin/env bash
# Lint skills/*/SKILL.md and personal/*/SKILL.md.
# Usage: bash scripts/lint-skills.sh [--self-test]
# Run from anywhere; operates on the repo root (parent of scripts/) unless LINT_ROOT is set.
set -u
ROOT="${LINT_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ "${1:-}" = "--self-test" ]; then
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  mkdir -p "$T/skills/bad-one" "$T/skills/sdd-x"
  printf -- '---\nname: wrong-name\ndescription: ""\n---\nSee `references/missing.md`.\n' > "$T/skills/bad-one/SKILL.md"
  printf -- '---\nname: sdd-x\ndescription: ok\n---\n' > "$T/skills/sdd-x/SKILL.md"
  OUT="$(LINT_ROOT="$T" bash "$0" 2>&1)"; RC=$?
  echo "$OUT"
  need=0
  for p in "name 'wrong-name'" "empty description" "references/missing.md" "LICENSE-spec-kit.md"; do
    echo "$OUT" | grep -q "${p#* }\|$p" || { echo "self-test: expected problem not reported: $p"; need=1; }
  done
  if [ "$RC" -ne 1 ] || [ "$need" -ne 0 ]; then echo "lint-skills self-test: FAIL"; exit 1; fi
  echo "lint-skills self-test: PASS (broken fixture rejected)"; exit 0
fi

BAD=0; N=0
problem() { echo "$1: $2"; BAD=1; }

for f in "$ROOT"/skills/*/SKILL.md "$ROOT"/personal/*/SKILL.md; do
  [ -f "$f" ] || continue
  N=$((N+1))
  dir="$(dirname "$f")"; folder="$(basename "$dir")"
  rel="${f#"$ROOT"/}"
  content="$(tr -d '\r' < "$f")"
  [ "$(printf '%s\n' "$content" | head -1)" = "---" ] || { problem "$rel" "frontmatter must start with ---"; continue; }
  fm="$(printf '%s\n' "$content" | awk 'NR==1{next} /^---[ \t]*$/{exit} {print}')"
  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[ \t]*//p' | head -1 | sed 's/^["'\'']//; s/["'\''][ \t]*$//')"
  desc="$(printf '%s\n' "$fm" | sed -n 's/^description:[ \t]*//p' | head -1 | sed 's/^["'\'']//; s/["'\''][ \t]*$//')"
  [ -n "$name" ] || problem "$rel" "missing name:"
  [ -z "$name" ] || [ "$name" = "$folder" ] || problem "$rel" "name '$name' != folder '$folder'"
  [ -n "$desc" ] || problem "$rel" "empty description"
  [ "${#desc}" -le 1024 ] || problem "$rel" "description too long (${#desc} > 1024)"
  # Referenced files: backticked references|templates|scripts/<file.ext>, outside code fences,
  # skipping lines marked 'not shipped' / 'optional upstream'. Dirs, globs and ranges are ignored.
  printf '%s\n' "$content" | awk '/^```/{c=!c; next} !c && !/not shipped|optional upstream/' \
    | grep -oE '`(references|templates|scripts)/[^` ]+`' | tr -d '`' | sort -u \
    | while read -r p; do
        case "$p" in *..*|*\**|*/) continue;; esac
        case "$p" in *.*) ;; *) continue;; esac
        [ -e "$dir/$p" ] || echo "$rel: referenced file missing: $p"
      done > "${TMPDIR:-/tmp}/lint-skills.$$"
  if [ -s "${TMPDIR:-/tmp}/lint-skills.$$" ]; then cat "${TMPDIR:-/tmp}/lint-skills.$$"; BAD=1; fi
  rm -f "${TMPDIR:-/tmp}/lint-skills.$$"
  case "$folder" in sdd-*) [ -f "$dir/LICENSE-spec-kit.md" ] || problem "$rel" "missing LICENSE-spec-kit.md";; esac
done

if [ "$BAD" -ne 0 ]; then exit 1; fi
echo "lint-skills: OK ($N skills)"
