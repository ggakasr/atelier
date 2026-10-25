#!/bin/sh
# atelier: OPT-IN UserPromptSubmit hook. Reads the user's prompt, matches keywords (English and
# Vietnamese, with and without diacritics) and prints a one-line hint naming the skills that fit.
# Claude Code adds hook stdout to the model's context. Hints only: never blocks, always exit 0,
# fail-open on input it cannot parse. See hooks/README.md.
#
# Wiring: node hooks/wire.js settings <settings.json>  (the installer does this with --wire-hooks)
set -u
# Vietnamese classes need a UTF-8 locale
case "$(uname)" in Darwin) LC_ALL=en_US.UTF-8 ;; *) LC_ALL=C.UTF-8 ;; esac; export LC_ALL

route() { # $1 = prompt; prints skill names, one per line
  F=$(mktemp); printf '%s' "$1" > "$F"
  m() { grep -qiE "$1" "$F"; }
  # Most specific rules first: the hint is capped at 3 skills, so order is priority.
  m '\bmkn\b|l[aà]m theo quy tr[iì]nh' && echo mkn-xu-ly-task
  m 'usage tu[aầ]n|week.?usage|token.*tu[aầ]n' && echo week-usage
  m '\b(docx|word doc\w*)\b' && echo docx
  m '\bpdf\b' && echo pdf
  m '\b(xlsx|excel|spreadsheet)\b' && echo xlsx
  m '\b(pptx|powerpoint|slides?|deck)\b' && echo pptx
  m 'b[aả]n tin' && echo ban-tin-tuan
  m '\bzalo\b' && echo quet-zalo-ban-tin
  m '\b(chart|graph|plot)\b|bi[eể]u [dđ][oồ]' && echo dataviz
  m 'nghi[eê]n c[uứ]u|\b(deep research|research report)\b' && echo deep-research
  m 'b[aả]o m[aậ]t|l[oỗ] h[oổ]ng|\b(security|secrets?|cve|owasp|injection)\b' && echo security-logic
  m 'b[aấ]m kh[oô]ng [dđ][uư][oơợ]c|kh[oô]ng b[aấ]m [dđ][uư][oơợ]c|n[uú]t .*(l[oỗ]i|kh[oô]ng)|kh[oô]ng [aă]n|sai s[oố]|l[eệ]ch|\bnot working\b|doesn.t work|kh[oô]ng ho[aạ]t [dđ][oộ]ng|sai d[uữ] li[eệ]u|screenshot' && echo ui-ux-triage
  m '\b(ui|ux|redesign|dashboard|landing|layout|make it pretty)\b|giao di[eệ]n|m[aà]n h[iì]nh|m[aà]n n[aà]y (x[aấ]u|r[oố]i)|th[eê]m m[aà]n|[dđ][eẹ]p h[oơ]n|nh[iì]n nh[uư] ai' && echo ui-design-logic
  m '\b(bug|broken|crash(es|ed)?|exception|stack ?trace|regression|root cause|memory leak|race condition|flaky|slow)\b|nguy[eê]n nh[aâ]n|ch[aậ]m|treo' && echo diagnosing-bugs
  m '\b(tdd|test.first|red.green|failing test)\b|vi[eế]t test tr[uư][oớ]c' && echo tdd
  m '\bpr\b.*\b(body|description|title|write|draft)\b|\b(write|draft|vi[eế]t|so[aạ]n)\b.*\b(pr|pull request)\b|m[oô] t[aả] pr' && echo pr
  m '\bhandoff\b|b[aà]n giao|new session|session m[oớ]i|continue in a new' && echo handoff
  m '[dđ][oổ]i h[uư][oớ]ng|k[eé]o kh[oô]ng [oổ]n|\b(pivot|course.correct)\b|plan (kh[oô]ng|no longer)' && echo course-correct
  m 'ph[aả]n bi[eệ]n|soi k[yỹ]|\b(pre-mortem|red team|what could go wrong)\b' && echo elicit
  m 'ti[eế]p t[uụ]c task|v[iì] sao quy[eế]t [dđ][iị]nh|why did we decide' && echo decision-log
  m 'docs? l[eệ]ch|\b(hallucinat\w*|onboard\w*)\b|b[iị]a t[eê]n|context (qu[aá] )?d[aà]i' && echo atelier-core
  m '\b(review|code review)\b|so[aá]t' && echo review-lenses
  m 'nghi[eệ]p v[uụ]|y[eê]u c[aầ]u|\b(requirements?|user flow)\b|t[ií]nh n[aă]ng m[oớ]i|th[eê]m t[ií]nh n[aă]ng|\bnew feature\b' && echo ba-flow-logic
  m 'l[aà]m [dđ]i|\b(go ahead|build it)\b|tri[eể]n khai' && echo work-order
  rm -f "$F"
}

emit() { # $1 = prompt
  r=$(route "$1" | awk '!s[$0]++' | head -3 | paste -sd, - | sed 's/,/, /g')
  [ -n "$r" ] && echo "[skill-router] Request may match installed skills: $r. Pick the best fit and invoke it with the Skill tool before acting (say which in one line). Skip only if the request is trivial."
  return 0
}

if [ "${1:-}" != "--self-test" ]; then
  IN=$(cat 2>/dev/null || true)
  P=$(printf '%s' "$IN" | tr '\n' ' ' | sed -nE 's/.*"prompt"[[:space:]]*:[[:space:]]*"((\\.|[^"\\])*)".*/\1/p' | sed 's/\\"/"/g')
  [ -z "$P" ] && exit 0
  emit "$P"
  exit 0
fi

SELF="$0"; case "$SELF" in /*|[A-Za-z]:*) ;; *) SELF="$(pwd)/$SELF";; esac
RC=0
t() { # $1 = prompt  $2 = expected skill ("" = expect no hint)
  out=$(printf '{"hook_event_name":"UserPromptSubmit","prompt":"%s"}' "$1" | sh "$SELF")
  if [ -z "$2" ]; then
    [ -z "$out" ] && echo "PASS: none  - $1" || { echo "FAIL: '$1' should give no hint, got: $out"; RC=1; }
  else
    case "$out" in *"$2"*) echo "PASS: $2 - $1" ;; *) echo "FAIL: '$1' should hint $2, got: $out"; RC=1 ;; esac
  fi
}
t 'the UI/UX needs some improvement' ui-design-logic
t 'màn này xấu quá' ui-design-logic
t 'nút lưu không ăn' ui-ux-triage
t 'phân tích nghiệp vụ cho tính năng mới' ba-flow-logic
t 'làm đi' work-order
t 'review the diff' review-lenses
t 'check security of the login' security-logic
t 'soi kỹ lại plan này' elicit
t 'export to an excel file' xlsx
t 'task mkn trạng thái sai' mkn-xu-ly-task
t 'this function crashes, find the root cause' diagnosing-bugs
t 'use tdd for the parser' tdd
t 'write the PR description' pr
t 'make a handoff for the next session' handoff
t 'what time is it' ""
t 'rename variable foo to bar' ""
t 'giao diện app này cần cải thiện, nhớ cả mobile' ui-design-logic
t 'man nay xau qua, sua lai di' ui-design-logic
t 'màn hình đăng nhập nhìn như AI làm' ui-design-logic
t 'thêm màn hình thống kê' ui-design-logic
t 'nút lưu bấm không được' ui-ux-triage
t 'số liệu hiển thị sai so với dữ liệu' ui-ux-triage
t 'bảng bị lệch trên điện thoại' ui-ux-triage
t 'hàm này bị lỗi, tìm nguyên nhân giúp tôi' diagnosing-bugs
t 'app chạy chậm quá' diagnosing-bugs
t 'server bị crash lúc nửa đêm' diagnosing-bugs
t 'viết mô tả PR cho thay đổi này' pr
t 'soạn PR description giúp tôi' pr
t 'kiểm tra bảo mật phần đăng nhập' security-logic
t 'có lỗ hổng nào không' security-logic
t 'soát lại đoạn code vừa sửa' review-lenses
t 'review giúp tôi cái diff này' review-lenses
t 'tôi muốn thêm tính năng báo cáo tuần' ba-flow-logic
t 'phân tích nghiệp vụ quản lý kho' ba-flow-logic
t 'yêu cầu của khách chưa rõ lắm' ba-flow-logic
t 'triển khai luôn nhé' work-order
t 'bàn giao sang session mới' handoff
t 'viết test trước rồi mới code' tdd
t 'tóm tắt usage tuần này' week-usage
t 'phản biện kế hoạch này giúp tôi' elicit
t 'soi kỹ lại thiết kế này' elicit
t 'đổi hướng, cách này không ổn' course-correct
t 'tiếp tục task hôm qua' decision-log
t 'xuất ra file excel' xlsx
t 'làm bản tin tuần này' ban-tin-tuan
t 'quét zalo tuần này' quet-zalo-ban-tin
t 'làm theo quy trình mkn' mkn-xu-ly-task
t 'hôm nay trời đẹp không' ""
t 'đổi tên biến a thành b' ""
long='spec flow review security crash chart pdf slow implement ui layout'
out=$(printf '{"prompt":"%s"}' "$long" | sh "$SELF")
n=$(printf '%s' "$out" | grep -oE 'skills: [^.]*' | tr ',' '
' | grep -c .)
[ "$n" -ge 1 ] && [ "$n" -le 3 ] && echo "PASS: hint capped at 3 ($n)" || { echo "FAIL: hint not capped ($n)"; RC=1; }
printf 'not json' | sh "$SELF" >/dev/null; [ $? -eq 0 ] && echo "PASS: garbage stdin allowed" || { echo "FAIL: garbage stdin"; RC=1; }
[ "$RC" -eq 0 ] && echo "skill-router self-test: ALL PASS" || echo "skill-router self-test: FAIL"
exit $RC
