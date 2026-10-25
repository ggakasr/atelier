#!/bin/sh
# atelier: OPT-IN PostToolUse hook. Counts the MAIN session's own tool calls; after N in a row with no
# subagent (Agent) call it adds a "[foreman]" reminder to the model's context, so the main session
# goes back to managing instead of doing the work. Calls made inside subagents carry an agent_id and are ignored.
# Hints only: never blocks, always exit 0, fail-open. N defaults to 8 (env ATELIER_FOREMAN_N).
set -u
N="${ATELIER_FOREMAN_N:-8}"
DIR="${TMPDIR:-/tmp}"

if [ "${1:-}" != "--self-test" ]; then
  IN=$(cat 2>/dev/null || true)
  [ -z "$IN" ] && exit 0
  J=$(printf '%s' "$IN" | tr '\n' ' ')
  printf '%s' "$J" | grep -q '"agent_id"[[:space:]]*:[[:space:]]*"[^"]' && exit 0
  SID=$(printf '%s' "$J" | sed -nE 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | tr -cd 'A-Za-z0-9_-')
  TOOL=$(printf '%s' "$J" | sed -nE 's/.*"tool_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p')
  [ -z "$SID" ] || [ -z "$TOOL" ] && exit 0
  F="$DIR/atelier-foreman-$SID"
  case "$TOOL" in
    Agent|Task) echo 0 > "$F"; exit 0 ;;
    TodoWrite|ToolSearch|Skill|ReadNotifications|SendMessage|mcp__ccd_turn__*|mcp__ccd_session__*) exit 0 ;;
  esac
  C=$(cat "$F" 2>/dev/null || echo 0)
  C=$((C + 1))
  echo "$C" > "$F"
  if [ $((C % N)) -eq 0 ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"[foreman] You have made %s tool calls in the main session without delegating. You are the manager: hand the next chunk (surveys, browser or screenshot work, edits, tests) to an apprentice subagent, relay only its short report, and say in one line that you are delegating."}}\n' "$C"
  fi
  exit 0
fi

SELF="$0"; case "$SELF" in /*|[A-Za-z]:*) ;; *) SELF="$(pwd)/$SELF";; esac
RC=0
TMPDIR=$(mktemp -d); export TMPDIR ATELIER_FOREMAN_N=3
call() { printf '{"session_id":"s1","tool_name":"%s"%s}' "$1" "${2:-}" | sh "$SELF"; }
check() { # $1 = description  $2 = output  $3 = expect (nudge|quiet)
  case "$2" in *'[foreman]'*) got=nudge ;; *) got=quiet ;; esac
  [ "$got" = "$3" ] && echo "PASS: $3 - $1" || { echo "FAIL: $1 (expected $3, got $got)"; RC=1; }
}
check "call 1" "$(call Bash)" quiet
check "call 2" "$(call Read)" quiet
check "call 3 reaches N" "$(call Bash)" nudge
check "subagent calls ignored" "$(call Bash ',"agent_id":"a1"'; call Bash ',"agent_id":"a1"'; call Bash ',"agent_id":"a1"')" quiet
check "Agent call resets" "$(call Agent)" quiet
check "after reset call 1" "$(call Bash)" quiet
check "TodoWrite not counted" "$(call TodoWrite; call TodoWrite; call TodoWrite)" quiet
printf 'not json' | sh "$SELF" >/dev/null; [ $? -eq 0 ] && echo "PASS: garbage stdin allowed" || { echo "FAIL: garbage stdin"; RC=1; }
rm -rf "$TMPDIR"
[ "$RC" -eq 0 ] && echo "foreman-nudge self-test: ALL PASS" || echo "foreman-nudge self-test: FAIL"
exit $RC
