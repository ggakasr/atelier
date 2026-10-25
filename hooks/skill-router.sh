#!/bin/sh
# atelier: OPT-IN UserPromptSubmit hook. Reads the user's prompt, matches keywords (English and
# Vietnamese, with and without diacritics) and prints a one-line hint naming the skills that fit.
# Claude Code adds hook stdout to the model's context. Hints only: never blocks, always exit 0,
# fail-open on input it cannot parse. See hooks/README.md.
#
# Wiring: node hooks/wire.js settings <settings.json>  (the installer does this with --wire-hooks)
set -u
# Vietnamese classes need a UTF-8 locale
for L in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8; do locale -a 2>/dev/null | grep -qix "$L" && LC_ALL=$L && break; done
export LC_ALL

route() { # $1 = prompt; prints skill names, one per line
  p="$1"
  m() { printf '%s' "$p" | grep -qiE "$1"; }
  m '\b(ui|ux|redesign|dashboard|landing|layout|make it pretty)\b|giao di[eệ]n|m[aà]n h[iì]nh|m[aà]n n[aà]y (x[aấ]u|r[oố]i)|th[eê]m m[aà]n|[dđ][eẹ]p h[oơ]n|nh[iì]n nh[uư] ai' && echo ui-design-logic
  m 'kh[oô]ng [aă]n|sai s[oố]|l[eệ]ch|\b(bug|broken|not working|doesn.t work)\b|kh[oô]ng ho[aạ]t [dđ][oộ]ng|sai d[uữ] li[eệ]u|screenshot' && echo ui-ux-triage
  m 'nghi[eệ]p v[uụ]|y[eê]u c[aầ]u|\b(requirements?|spec|user flow|flow)\b|t[ií]nh n[aă]ng m[oớ]i|ph[aâ]n t[ií]ch' && echo ba-flow-logic
  m 'l[aà]m [dđ]i|\b(go ahead|build it|implement)\b|tri[eể]n khai' && echo work-order
  m '\b(review|pull request)\b|so[aá]t' && echo review-lenses
  m 'b[aả]o m[aậ]t|l[oỗ] h[oổ]ng|\b(security|secrets?|cve|owasp|injection|auth)\b' && echo security-logic
  m '[dđ][oổ]i h[uư][oớ]ng|k[eé]o kh[oô]ng [oổ]n|\b(pivot|course.correct)\b|plan (kh[oô]ng|no longer)' && echo course-correct
  m 'ph[aả]n bi[eệ]n|soi k[yỹ]|\b(pre-mortem|red team|what could go wrong)\b' && echo elicit
  m 'ti[eế]p t[uụ]c task|v[iì] sao quy[eế]t [dđ][iị]nh|why did we decide' && echo decision-log
  m 'docs? l[eệ]ch|\b(hallucinat\w*|onboard\w*)\b|b[iị]a t[eê]n|context (qu[aá] )?d[aà]i' && echo atelier-core
  m '\b(docx|word doc\w*)\b' && echo docx
  m '\bpdf\b' && echo pdf
  m '\b(xlsx|excel|spreadsheet)\b' && echo xlsx
  m '\b(pptx|powerpoint|slides?|deck)\b' && echo pptx
  m 'nghi[eê]n c[uứ]u|\b(deep research|research report)\b' && echo deep-research
  m '\b(chart|graph|plot|bi[eể]u [dđ][oồ])\b' && echo dataviz
  m 'b[aả]n tin' && echo ban-tin-tuan
  m '\bzalo\b' && echo quet-zalo-ban-tin
  m '\bmkn\b|l[aà]m theo quy tr[iì]nh' && echo mkn-xu-ly-task
  m 'usage tu[aầ]n|week.?usage|token.*tu[aầ]n' && echo week-usage
}

emit() { # $1 = prompt
  r=$(route "$1" | awk '!s[$0]++' | paste -sd, - | sed 's/,/, /g')
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
t 'what time is it' ""
t 'rename variable foo to bar' ""
printf 'not json' | sh "$SELF" >/dev/null; [ $? -eq 0 ] && echo "PASS: garbage stdin allowed" || { echo "FAIL: garbage stdin"; RC=1; }
[ "$RC" -eq 0 ] && echo "skill-router self-test: ALL PASS" || echo "skill-router self-test: FAIL"
exit $RC
