#!/bin/sh
# atelier: OPT-IN Stop hook. When the final answer gives up on a FEASIBILITY problem ("cannot be done",
# "không làm được", "too complex" ...) with no evidence (no code fence, tried-list, error quote, file:line,
# blocker) and no safety/policy marker, it blocks ONCE and asks the model to try other approaches and report
# with the blocker format from the `reframe` skill. Safety refusals are never touched.
# Retry once only (stop_hook_active => allow). Fail-open: any parse problem or error => exit 0, no output.
# Needs sh + node (same as the other atelier hooks). Replies shorter than ATELIER_GIVEUP_MIN chars (default 30) are skipped.
# Test: bash scripts/selftest-giveup-guard.sh        See hooks/README.md.
set -u
command -v node >/dev/null 2>&1 || exit 0

JS=$(cat <<'JSEOF'
'use strict';
const fs = require('fs');
const MIN = parseInt(process.env.ATELIER_GIVEUP_MIN || '30', 10) || 30;

// HIGH-confidence give-up phrases (matched on lowercased text)
const GIVEUP = [
  'cannot be done', 'not possible', 'impossible', 'out of scope', 'too complex', 'beyond what i can', "i'm unable to", 'i’m unable to',
  'không thể làm', 'không làm được', 'bất khả thi', 'quá phức tạp', 'ngoài phạm vi', 'không khả thi',
];
// evidence markers: code fence, tried-list, error quote, file:line, blocker
const EVIDENCE = [
  /```/, /\btried\b/i, /đã thử/i, /\b(error|exception|traceback)\b\s*[:(]/i, /\blỗi\s*:/i,
  /[\w.\\/-]+\.[a-z]{1,5}:\d+/i, /\bblockers?\b/i, /chặn ở/i,
];
// safety markers: a real safety/policy/permission refusal is never blocked
const SAFETY = [
  'policy', 'unsafe', 'harmful', 'not allowed', 'security risk', 'permission',
  'an toàn', 'không được phép', 'chính sách', 'quyền',
  'malware', 'illegal', 'unlawful', 'dangerous', 'weapon', 'exploit victims',
  "can't help with", 'cannot help with', "can’t help with", 'unable to help', 'unable to assist', "won't help", "won’t help",
  'bất hợp pháp', 'nguy hiểm', 'vi phạm', 'đạo đức', 'không thể giúp', 'không thể hỗ trợ',
]; // when in doubt do NOT block (fail open): safety markers win over give-up phrases

function lastText(input) {
  if (typeof input.last_assistant_message === 'string' && input.last_assistant_message) return input.last_assistant_message;
  if (typeof input.transcript_path !== 'string' || !input.transcript_path) return '';
  const lines = fs.readFileSync(input.transcript_path, 'utf8').split('\n');
  for (let i = lines.length - 1; i >= 0; i--) {
    if (!lines[i].trim()) continue;
    let e; try { e = JSON.parse(lines[i]); } catch (x) { continue; }
    if (!e || (e.type !== 'assistant' && !(e.message && e.message.role === 'assistant'))) continue;
    const c = e.message && e.message.content;
    const t = typeof c === 'string' ? c : Array.isArray(c) ? c.filter(b => b && b.type === 'text' && typeof b.text === 'string').map(b => b.text).join('\n') : '';
    return t.trim() ? t : ''; // only the LAST assistant entry; no text => pass (never walk back to an older turn)
  }
  return '';
}

function decide(raw) { // raw stdin text -> reason string to block, or '' to allow; never throws
  try {
    const input = JSON.parse(raw);
    if (!input || (input.stop_hook_active === true || input.stop_hook_active === 'true')) return '';
    const text = lastText(input).normalize('NFC');
    if (text.length < MIN) return '';
    const low = text.toLowerCase();
    if (!GIVEUP.some(p => low.includes(p))) return '';
    if (EVIDENCE.some(re => re.test(text))) return '';
    if (SAFETY.some(p => low.includes(p))) return '';
    return 'Câu trả lời vừa rồi bỏ cuộc về tính khả thi mà chưa có bằng chứng. Đừng gán nhãn khó/dễ rồi dừng. Hãy: (1) liệt kê 2-3 hướng khác (có một hướng đổi ràng buộc: giao một phần, dùng công cụ khác, định nghĩa lại "xong", bỏ một giả định); (2) chạy thí nghiệm nhỏ nhất để kiểm chứng; (3) rồi báo lại theo định dạng blocker của skill reframe: đã thử A, B, C (kèm bằng chứng) -> chặn ở đâu -> cần gì để mở khóa -> người dùng cần quyết định gì. Báo một blocker thật kèm bằng chứng là kết thúc hợp lệ. (Nếu đây là từ chối vì an toàn/chính sách thì không áp dụng, giữ nguyên từ chối.)';
  } catch (e) {
    return '';
  }
}

let raw = '';
try { raw = fs.readFileSync(0, 'utf8'); } catch (e) { /* fail-open */ }
const reason = decide(raw);
if (reason) process.stdout.write(JSON.stringify({ decision: 'block', reason }) + '\n');
process.exit(0);
JSEOF
)

node -e "$JS" 2>/dev/null
exit 0
