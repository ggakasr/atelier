#!/usr/bin/env bash
# Self-test for hooks/giveup-guard.sh: pipes Stop-hook JSON into it and checks block / pass.
# Usage: bash scripts/selftest-giveup-guard.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/hooks/giveup-guard.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
RC=0

mk() { printf '{"hook_event_name":"Stop","stop_hook_active":%s,"last_assistant_message":"%s"}' "$1" "$2"; } # active, text

check() { # $1 = description  $2 = json  $3 = expect (block|pass)
  out="$(printf '%s' "$2" | sh "$HOOK" 2>/dev/null)"; code=$?
  case "$out" in *'"decision":"block"'*) got=block ;; *) got=pass ;; esac
  if [ "$code" -ne 0 ]; then echo "FAIL: $1 (exit $code, must always be 0)"; RC=1
  elif [ "$got" = "$3" ]; then echo "PASS: $3 - $1"
  else echo "FAIL: $1 (expected $3, got $got)"; RC=1; fi
}

EN_GIVEUP="I looked at the request and this cannot be done in the current codebase because the design is too complex to change safely, so I will stop here."
FENCE='```'
check "EN give-up without evidence" "$(mk false "$EN_GIVEUP")" block
check "VN give-up without evidence" "$(mk false 'Việc này không làm được vì quá phức tạp.')" block
check "give-up WITH tried-list" "$(mk false 'Đã thử: A (lỗi import), B (thiếu file cấu hình), C (đổi thư viện). Không làm được ở bước export, chặn ở export.js:42.')" pass
check "EN give-up with code fence evidence" "$(mk false "This is not possible as written. I ran it:\\n${FENCE}\\nTypeError: x is undefined\\n${FENCE}\\nSo I stopped.")" pass
check "VN safety refusal" "$(mk false 'Tôi không thể làm việc này vì chính sách an toàn: yêu cầu này không được phép và không khả thi theo quy định.')" pass
check "EN safety refusal" "$(mk false 'This is impossible for me to do: it would be harmful and against policy, so I will not help with it.')" pass
check "stop_hook_active true (retry once only)" "$(mk true 'Việc này không làm được vì quá phức tạp.')" pass
check "stop_hook_active string \"true\"" "$(mk '"true"' 'Việc này không làm được vì quá phức tạp.')" pass
check "EN refusal: unable to help" "$(mk false "I'm unable to help with that request.")" pass
check "EN refusal: unable to assist malware" "$(mk false "I'm unable to assist with writing malware for you.")" pass
check "VN refusal: bất hợp pháp" "$(mk false 'Tôi không thể làm điều này, nó bất hợp pháp.')" pass
check "short reply" "$(mk false 'Không thể làm.')" pass
check "no give-up phrase" "$(mk false 'Đã sửa xong lỗi đăng nhập, chạy test và tất cả đều xanh, bạn có thể merge.')" pass
check "garbage input" "not json at all {{{" pass
check "empty input" "" pass
check "wrong field types" '{"stop_hook_active":"x","last_assistant_message":5}' pass

# transcript fallback: last assistant entry of a jsonl file, no last_assistant_message field
printf '%s\n' \
  '{"type":"user","message":{"role":"user","content":"hãy làm việc này"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Việc này bất khả thi vì quá phức tạp, tôi dừng ở đây."}]}}' > "$T/t.jsonl"
TW="$T"; command -v cygpath >/dev/null 2>&1 && TW="$(cygpath -m "$T")" # node needs a native path on Windows
check "transcript fallback gives up" "{\"stop_hook_active\":false,\"transcript_path\":\"$TW/t.jsonl\"}" block
printf '%s
'   '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Việc này bất khả thi vì quá phức tạp, tôi dừng ở đây."}]}}'   '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"x","name":"Bash","input":{}}]}}' > "$T/stale.jsonl"
check "stale transcript (last entry tool_use only)" "{\"stop_hook_active\":false,\"transcript_path\":\"$TW/stale.jsonl\"}" pass
check "transcript path missing (fail-open)" "{\"stop_hook_active\":false,\"transcript_path\":\"$TW/nope.jsonl\"}" pass

# block output must be valid JSON with decision + non-empty reason
out="$(printf '%s' "$(mk false "$EN_GIVEUP")" | sh "$HOOK")"
if printf '%s' "$out" | node -e 'const o=JSON.parse(require("fs").readFileSync(0,"utf8")); process.exit(o.decision==="block"&&o.reason&&o.reason.length>20?0:1)'; then
  echo "PASS: block output is valid JSON with a reason"
else echo "FAIL: block output is not valid JSON with decision+reason: $out"; RC=1; fi

[ "$RC" -eq 0 ] && echo "giveup-guard self-test: ALL PASS" || echo "giveup-guard self-test: FAIL"
exit $RC
