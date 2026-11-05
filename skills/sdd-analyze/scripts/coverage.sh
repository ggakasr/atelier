#!/usr/bin/env bash
# coverage.sh - mechanical requirement->task coverage gate for sdd-analyze.
# Usage: coverage.sh <spec.md> <tasks.md> [--plan plan.md] [--warn-only]
#        coverage.sh --self-test
# Defined id  = FR-n / SC-n at the start of a list item, heading or bold in spec.md.
# Cited id    = any FR-n / SC-n on a task line (^- [ ] T012 ...) in tasks.md.
# UNCOVERED = defined, never cited | UNKNOWN = cited, not defined | UNMAPPED = task with no id.
# Exit 1 if any of the three exist (unless --warn-only), else 0. --plan: ids defined only
# in plan.md are reported as a note (not an error); plan.md must exist.
set -u
LC_ALL=C; export LC_ALL

DEF_RE='^[[:space:]]*([-*+][[:space:]]+|[0-9]+[.)][[:space:]]+)?(#+[[:space:]]+)?(\*\*|__)?`?(FR|SC)-[0-9]+'
TASK_RE='^[[:space:]]*[-*][[:space:]]\[[ xX]\][[:space:]]+T[0-9]+'

# first id on each defining line only (a definition line defines one id)
spec_defs() {
  tr -d '\r' < "$1" | grep -E "$DEF_RE" | while IFS= read -r l; do
    printf '%s\n' "$l" | grep -oE '(FR|SC)-[0-9]+' | head -n1
  done | sort -u
}
task_lines() { tr -d '\r' < "$1" | grep -E "$TASK_RE"; }

run() {
  spec="$1"; tasks="$2"; plan="${3:-}"; warn="${4:-0}"
  [ -f "$spec" ] || { echo "coverage: spec not found: $spec" >&2; return 2; }
  [ -f "$tasks" ] || { echo "coverage: tasks not found: $tasks" >&2; return 2; }
  [ -z "$plan" ] || [ -f "$plan" ] || { echo "coverage: plan not found: $plan" >&2; return 2; }
  T=$(mktemp -d) || return 2
  spec_defs "$spec" > "$T/defs"
  task_lines "$tasks" > "$T/tl"
  grep -oE '(FR|SC)-[0-9]+' "$T/tl" | sort -u > "$T/cited"
  comm -23 "$T/defs" "$T/cited" > "$T/uncov"
  comm -13 "$T/defs" "$T/cited" > "$T/unk"
  grep -vE '(FR|SC)-[0-9]+' "$T/tl" | sed -E 's/^[^T]*(T[0-9]+).*/\1/' | sort -u > "$T/unm"
  if [ -n "$plan" ]; then
    spec_defs "$plan" > "$T/pdefs"; comm -13 "$T/defs" "$T/pdefs" > "$T/pnote"
  fi
  nd=$(wc -l < "$T/defs" | tr -d ' '); nu=$(wc -l < "$T/uncov" | tr -d ' ')
  nk=$(wc -l < "$T/unk" | tr -d ' '); nm=$(wc -l < "$T/unm" | tr -d ' ')
  nt=$(wc -l < "$T/tl" | tr -d ' ')
  if [ "$nd" -gt 0 ]; then pct=$(( (nd - nu) * 100 / nd )); else pct=0; fi

  echo "| Requirement | Has Task? | Task IDs |"
  echo "|---|---|---|"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    ids=$(grep -E "(^|[^A-Za-z0-9-])$id([^0-9]|$)" "$T/tl" | sed -E 's/^[^T]*(T[0-9]+).*/\1/' | sort -u | tr '\n' ' ' | sed 's/ $//')
    if [ -n "$ids" ]; then echo "| $id | yes | $ids |"; else echo "| $id | NO | - |"; fi
  done < "$T/defs"
  while IFS= read -r id; do [ -n "$id" ] && echo "| $id | UNKNOWN (not in spec) | - |"; done < "$T/unk"
  while IFS= read -r id; do [ -n "$id" ] && echo "UNMAPPED task: $id"; done < "$T/unm"
  if [ -n "$plan" ]; then
    while IFS= read -r id; do [ -n "$id" ] && echo "NOTE: $id defined in plan only, not in spec"; done < "$T/pnote"
  fi
  echo "coverage: ${pct}% (${nd} requirements, ${nt} tasks) UNCOVERED=${nu} UNKNOWN=${nk} UNMAPPED=${nm}"
  bad=$(( nu + nk + nm )); rm -rf "$T"
  if [ "$bad" -gt 0 ] && [ "$warn" != 1 ]; then return 1; fi
  return 0
}

self_test() {
  S="$0"; case "$S" in /*|[A-Za-z]:*) ;; *) S="$(pwd)/$S";; esac
  D=$(mktemp -d) || exit 1; RC=0
  SPEC='# Spec\n## Requirements\n- **FR-001**: a\n- **FR-002**: b\n## Success\n- **SC-001**: c\n'
  printf "$SPEC" > "$D/spec.md"
  chk() { # name expected_rc must_grep tasks_file [spec]
    out=$(bash "$S" "${5:-$D/spec.md}" "$4" 2>&1); rc=$?
    if [ "$rc" -eq "$2" ] && echo "$out" | grep -q -- "$3"; then echo "PASS: $1"
    else echo "FAIL: $1 (rc=$rc)"; echo "$out"; RC=1; fi
  }
  printf -- '- [ ] T001 a FR-001\n- [x] T002 b FR-002 SC-001\n' > "$D/good.md"
  chk "good case 100%" 0 "100% (3 requirements, 2 tasks) UNCOVERED=0 UNKNOWN=0 UNMAPPED=0" "$D/good.md"
  printf -- '- [ ] T001 a FR-001\n- [ ] T002 b SC-001\n' > "$D/unc.md"
  chk "uncovered FR-002" 1 "| FR-002 | NO" "$D/unc.md"
  printf -- '- [ ] T001 a FR-001 FR-002 SC-001 FR-009\n' > "$D/unk.md"
  chk "unknown FR-009" 1 "| FR-009 | UNKNOWN" "$D/unk.md"
  printf -- '- [ ] T001 a FR-001 FR-002 SC-001\n- [ ] T002 nothing\n' > "$D/unm.md"
  chk "unmapped T002" 1 "UNMAPPED task: T002" "$D/unm.md"
  printf -- '- [ ] T001 a FR-001\r\n- [x] T002 b FR-002 SC-001\r\n' > "$D/crlf-t.md"
  printf "$SPEC" | sed 's/$/\r/' > "$D/crlf-s.md"
  chk "CRLF input" 0 "100%" "$D/crlf-t.md" "$D/crlf-s.md"
  printf '# Spec\n- **FR-001**: a, see also FR-002 in prose\n' > "$D/prose.md"
  printf -- '- [ ] T001 a FR-001\n- [ ] T002 b FR-002\n' > "$D/prose-t.md"
  chk "prose-only mention is not a definition" 1 "| FR-002 | UNKNOWN" "$D/prose-t.md" "$D/prose.md"
  out=$(bash "$S" "$D/spec.md" "$D/unc.md" --warn-only 2>&1); rc=$?
  [ "$rc" -eq 0 ] && echo "PASS: --warn-only exits 0" || { echo "FAIL: --warn-only rc=$rc"; RC=1; }
  rm -rf "$D"
  [ "$RC" -eq 0 ] && echo "coverage self-test: ALL PASS" || echo "coverage self-test: CO FAIL"
  exit $RC
}

[ "${1:-}" = "--self-test" ] && self_test
spec=""; tasks=""; plan=""; warn=0
while [ $# -gt 0 ]; do
  case "$1" in
    --warn-only) warn=1 ;;
    --plan) shift; plan="${1:-}" ;;
    *) if [ -z "$spec" ]; then spec="$1"; elif [ -z "$tasks" ]; then tasks="$1"; fi ;;
  esac
  shift
done
[ -n "$spec" ] && [ -n "$tasks" ] || { echo "usage: coverage.sh <spec.md> <tasks.md> [--plan plan.md] [--warn-only] | --self-test" >&2; exit 2; }
run "$spec" "$tasks" "$plan" "$warn"
