#!/usr/bin/env node
// atelier: OPT-IN UserPromptSubmit hook. Reads the user's prompt, matches keywords (English and
// Vietnamese, with and without diacritics) and prints a one-line hint naming the skills that fit.
// Claude Code adds hook stdout to the model's context. Hints only: never blocks, always exit 0,
// fail-open on input it cannot parse. See hooks/README.md.
//
// Wiring: node hooks/wire.js settings <settings.json>  (the installer does this with --wire-hooks)
// Test:   node hooks/skill-router.js --self-test
'use strict';

// Most specific rules first: the hint is capped at 3 skills, so order is priority.
// One rule per line, written ['skill-name', /regex/i], (skill-gap.sh greps for the quoted name).
const RULES = [
  ['mkn-xu-ly-task', /\bmkn\b|l[aà]m theo quy tr[iì]nh/i],
  ['week-usage', /usage tu[aầ]n|week.?usage|token.*tu[aầ]n/i],
  // whole-system audit+QA: only specific phrases, never bare 'audit' / 'security audit' / 'đánh giá' (those stay with security-logic, review-lenses)
  ['system-audit', /\b(system|full|comprehensive) (audit|qa)\b|audit h[eệ] th[oố]ng|audit to[aà]n di[eệ]n|[dđ][aá]nh gi[aá] to[aà]n di[eệ]n|ki[eể]m th[uử] to[aà]n b[oộ]|h[eệ] th[oố]ng [dđ][aã] t[oố]t ch[uư]a|[dđ][uủ] [dđ][eể] d[uù]ng th[uự]c t[eế]|qa to[aà]n di[eệ]n/i],
  // spec-first lane (sdd-*): only specific phrases, never bare 'spec' / 'yêu cầu' / 'plan' / 'task' (those stay with ba-flow-logic, work-order)
  ['sdd-implement', /\bimplement\b.{0,30}\btasks?(\.md)?\b|tasks\.md.{0,30}\bimplement|implement theo tasks|th[uự]c thi tasks?/i],
  ['sdd-clarify', /\bclarify\b.{0,20}\b(spec|requirements?)\b|l[aà]m r[oõ] (spec|[dđ][aặ]c t[aả]|y[eê]u c[aầ]u)|h[oỏ]i l[aạ]i y[eê]u c[aầ]u|\bspec\b.{0,20}\bambigu/i],
  ['sdd-checklist', /\b(requirements?|spec) checklist\b|checklist (y[eê]u c[aầ]u|spec|[dđ][aặ]c t[aả]|ch[aấ]t l[uư][oợ]ng y[eê]u c[aầ]u)|so[aá]t ch[aấ]t l[uư][oợ]ng y[eê]u c[aầ]u/i],
  ['sdd-tasks', /\btasks\.md\b|\buser stor(y|ies)\b|chia task|task breakdown|break (it |this )?(down )?into tasks/i],
  ['sdd-analyze', /\b(analy[sz]e|consisten\w*)\b.{0,30}\b(spec|plan|tasks)\b.{0,30}\b(spec|plan|tasks|consisten\w*)\b|nh[aấ]t qu[aá]n.{0,30}\b(spec|plan|tasks)\b|\b(spec|plan|tasks)\b.{0,30}nh[aấ]t qu[aá]n|cross.artifact/i],
  ['sdd-converge', /\b(spec drift|converge)\b|\bcode\b.{0,30}\b(match|matches)\b.{0,15}\bspec\b|code.{0,20}kh[oớ]p.{0,10}spec|kh[oớ]p spec|[dđ][oó]ng kho[aả]ng tr[oố]ng/i],
  ['sdd-constitution', /\bconstitution\b|hi[eế]n ph[aá]p|nguy[eê]n t[aắ]c d[uự] [aá]n|project principles/i],
  ['sdd-assess', /\bgo\/kill\b|go.no.go|[dđ][aá]nh gi[aá] [yý] t[uư][oở]ng|\b(should we build|is it worth building|idea assessment)\b|c[oó] n[eê]n (l[aà]m|build|x[aâ]y)\b/i],
  ['sdd-bug', /\bverdict\b|\b(assess|triage)\b.{0,20}\bbug\b|\bbug\b.{0,30}\b(evidence|verdict)\b|b[aằ]ng ch[uứ]ng.{0,20}\bbug\b|\bbug\b.{0,20}b[aằ]ng ch[uứ]ng/i],
  ['sdd-plan', /\b(technical|tech|implementation) plan\b|l[aậ]p plan|plan k[yỹ] thu[aậ]t|k[eế] ho[aạ]ch k[yỹ] thu[aậ]t|\bplan\.md\b/i],
  ['sdd-specify', /\bspecify\b|\b(write|draft|create)\b.{0,15}\bspec\b|\bfeature spec\b|\bspec\.md\b|[dđ][aặ]c t[aả]|(vi[eế]t|so[aạ]n|t[aạ]o) spec/i],
  ['docx', /\b(docx|word doc\w*)\b/i],
  ['pdf', /\bpdf\b/i],
  ['xlsx', /\b(xlsx|excel|spreadsheet)\b/i],
  ['pptx', /\b(pptx|powerpoint|slides?|deck)\b/i],
  ['ban-tin-tuan', /b[aả]n tin/i],
  ['quet-zalo-ban-tin', /\bzalo\b/i],
  ['dataviz', /\b(chart|graph|plot)\b|bi[eể]u [dđ][oồ]/i],
  ['deep-research', /nghi[eê]n c[uứ]u|\b(deep research|research report)\b/i],
  ['security-logic', /b[aả]o m[aậ]t|l[oỗ] h[oổ]ng|\b(security|secrets?|cve|owasp|injection)\b/i],
  ['ui-ux-triage', /b[aấ]m kh[oô]ng [dđ][uư][oơợ]c|kh[oô]ng b[aấ]m [dđ][uư][oơợ]c|n[uú]t .*(l[oỗ]i|kh[oô]ng)|kh[oô]ng [aă]n|sai s[oố]|l[eệ]ch|\bnot working\b|doesn.t work|kh[oô]ng ho[aạ]t [dđ][oộ]ng|sai d[uữ] li[eệ]u|screenshot/i],
  ['ui-design-logic', /\b(ui|ux|redesign|dashboard|landing|layout|make it pretty)\b|giao di[eệ]n|m[aà]n h[iì]nh|m[aà]n n[aà]y (x[aấ]u|r[oố]i)|th[eê]m m[aà]n|[dđ][eẹ]p h[oơ]n|nh[iì]n nh[uư] ai|\b(modern css|baseline|container quer(y|ies)|view transitions?|popover|dialog element)\b|web hi[eệ]n [dđ][aạ]i|:has\(|\b(improve|moderni[sz]e|upgrade|audit|refresh|revamp|review|clean up).{0,40}\b(front.?end|css|html|web ?app)\b|(c[aả]i thi[eệ]n|n[aâ]ng c[aấ]p|hi[eệ]n [dđ][aạ]i h[oó]a|l[aà]m m[oớ]i|so[aá]t|ki[eể]m tra|[dđ][aá]nh gi[aá]).{0,40}\b(front.?end|css|html)\b|(front.?end|css|html).{0,30}(c[uũ] qu[aá]|c[uũ]\b|l[oỗ]i th[oờ]i|hi[eệ]n [dđ][aạ]i)|hi[eệ]n [dđ][aạ]i.{0,30}(front.?end|css|html)/i],
  ['diagnosing-bugs', /\b(bug|broken|crash(es|ed)?|exception|stack ?trace|regression|root cause|memory leak|race condition|flaky|slow)\b|nguy[eê]n nh[aâ]n|ch[aậ]m|treo/i],
  ['tdd', /\b(tdd|test.first|red.green|failing test)\b|vi[eế]t test tr[uư][oớ]c/i],
  ['pr', /\bpr\b.*\b(body|description|title|write|draft)\b|\b(write|draft|vi[eế]t|so[aạ]n)\b.*\b(pr|pull request)\b|m[oô] t[aả] pr/i],
  ['handoff', /\bhandoff\b|b[aà]n giao|new session|session m[oớ]i|continue in a new/i],
  ['course-correct', /[dđ][oổ]i h[uư][oớ]ng|k[eé]o kh[oô]ng [oổ]n|\b(pivot|course.correct)\b|plan (kh[oô]ng|no longer)/i],
  ['reframe', /t[uừ] ch[oố]i|kh[oô]ng l[aà]m [dđ][uư][oợ]c|b[ií] [dđ][uư][oờ]ng|th[uử] h[uư][oớ]ng kh[aá]c|\breframe\b|\b(can.?t do|cannot do|too hard|too complex|gave up|giving up|you refused|refuses?)\b/i],
  ['elicit', /ph[aả]n bi[eệ]n|soi k[yỹ]|\b(pre-mortem|red team|what could go wrong)\b/i],
  ['decision-log', /ti[eế]p t[uụ]c task|v[iì] sao quy[eế]t [dđ][iị]nh|why did we decide/i],
  ['atelier-core', /docs? l[eệ]ch|\b(hallucinat\w*|onboard\w*)\b|b[iị]a t[eê]n|context (qu[aá] )?d[aà]i/i],
  ['review-lenses', /\b(review|code review)\b|so[aá]t/i],
  ['ba-flow-logic', /nghi[eệ]p v[uụ]|y[eê]u c[aầ]u|\b(requirements?|user flow)\b|t[ií]nh n[aă]ng m[oớ]i|th[eê]m t[ií]nh n[aă]ng|\bnew feature\b/i],
  ['work-order', /l[aà]m [dđ]i|\b(go ahead|build it)\b|tri[eể]n khai/i],
];

function route(prompt) { // returns matching skill names in priority order, deduped
  return [...new Set(RULES.filter(([, re]) => re.test(prompt)).map(([name]) => name))];
}

function hint(prompt) { // returns the hint line, or '' when nothing matches
  const r = route(prompt).slice(0, 3).join(', ');
  return r ? `[skill-router] Request may match installed skills: ${r}. Pick the best fit and invoke it with the Skill tool before acting (say which in one line). Skip only if the request is trivial.` : '';
}

function handle(input) { // raw stdin text -> output line ('' = print nothing); never throws
  try {
    const p = JSON.parse(input).prompt;
    return typeof p === 'string' && p ? hint(p) : '';
  } catch (e) {
    return '';
  }
}

function selfTest() {
  let rc = 0;
  const t = (prompt, want) => { // want = skill, or '' for no hint
    const out = handle(JSON.stringify({ hook_event_name: 'UserPromptSubmit', prompt }));
    if (!want) {
      if (!out) console.log(`PASS: none  - ${prompt}`);
      else { console.log(`FAIL: '${prompt}' should give no hint, got: ${out}`); rc = 1; }
    } else if (out.includes(want)) console.log(`PASS: ${want} - ${prompt}`);
    else { console.log(`FAIL: '${prompt}' should hint ${want}, got: ${out}`); rc = 1; }
  };
  t('the UI/UX needs some improvement', 'ui-design-logic');
  t('màn này xấu quá', 'ui-design-logic');
  t('nút lưu không ăn', 'ui-ux-triage');
  t('phân tích nghiệp vụ cho tính năng mới', 'ba-flow-logic');
  t('làm đi', 'work-order');
  t('review the diff', 'review-lenses');
  t('check security of the login', 'security-logic');
  t('soi kỹ lại plan này', 'elicit');
  t('export to an excel file', 'xlsx');
  t('task mkn trạng thái sai', 'mkn-xu-ly-task');
  t('this function crashes, find the root cause', 'diagnosing-bugs');
  t('use tdd for the parser', 'tdd');
  t('write the PR description', 'pr');
  t('make a handoff for the next session', 'handoff');
  t('what time is it', '');
  t('rename variable foo to bar', '');
  t('giao diện app này cần cải thiện, nhớ cả mobile', 'ui-design-logic');
  t('man nay xau qua, sua lai di', 'ui-design-logic');
  t('màn hình đăng nhập nhìn như AI làm', 'ui-design-logic');
  t('thêm màn hình thống kê', 'ui-design-logic');
  t('use container queries instead of media queries', 'ui-design-logic');
  t('replace the custom popover with modern css', 'ui-design-logic');
  t('viết web hiện đại, đừng dùng code cũ', 'ui-design-logic');
  t('nút lưu bấm không được', 'ui-ux-triage');
  t('số liệu hiển thị sai so với dữ liệu', 'ui-ux-triage');
  t('bảng bị lệch trên điện thoại', 'ui-ux-triage');
  t('hàm này bị lỗi, tìm nguyên nhân giúp tôi', 'diagnosing-bugs');
  t('app chạy chậm quá', 'diagnosing-bugs');
  t('server bị crash lúc nửa đêm', 'diagnosing-bugs');
  t('viết mô tả PR cho thay đổi này', 'pr');
  t('soạn PR description giúp tôi', 'pr');
  t('kiểm tra bảo mật phần đăng nhập', 'security-logic');
  t('có lỗ hổng nào không', 'security-logic');
  t('soát lại đoạn code vừa sửa', 'review-lenses');
  t('review giúp tôi cái diff này', 'review-lenses');
  t('tôi muốn thêm tính năng báo cáo tuần', 'ba-flow-logic');
  t('phân tích nghiệp vụ quản lý kho', 'ba-flow-logic');
  t('yêu cầu của khách chưa rõ lắm', 'ba-flow-logic');
  t('triển khai luôn nhé', 'work-order');
  t('bàn giao sang session mới', 'handoff');
  t('viết test trước rồi mới code', 'tdd');
  t('tóm tắt usage tuần này', 'week-usage');
  t('phản biện kế hoạch này giúp tôi', 'elicit');
  t('soi kỹ lại thiết kế này', 'elicit');
  t('đổi hướng, cách này không ổn', 'course-correct');
  t('tiếp tục task hôm qua', 'decision-log');
  t('xuất ra file excel', 'xlsx');
  t('làm bản tin tuần này', 'ban-tin-tuan');
  t('quét zalo tuần này', 'quet-zalo-ban-tin');
  t('làm theo quy trình mkn', 'mkn-xu-ly-task');
  t('Claude says it cannot do this, too hard', 'reframe');
  t('Claude từ chối, bảo không làm được', 'reframe');
  t('bí đường rồi, thử hướng khác đi', 'reframe');
  t('reframe this problem', 'reframe');
  t('hôm nay trời đẹp không', '');
  t('đổi tên biến a thành b', '');

  // spec-first lane (sdd-*): positives
  t('write a feature spec for the export button', 'sdd-specify');
  t('viết đặc tả tính năng đăng nhập', 'sdd-specify');
  t('clarify the spec before we plan', 'sdd-clarify');
  t('làm rõ spec này giúp tôi', 'sdd-clarify');
  t('create a technical plan from the spec', 'sdd-plan');
  t('lập plan kỹ thuật cho tính năng này', 'sdd-plan');
  t('requirements checklist for this spec', 'sdd-checklist');
  t('checklist yêu cầu cho spec này', 'sdd-checklist');
  t('generate tasks.md grouped by user story', 'sdd-tasks');
  t('chia task theo user story', 'sdd-tasks');
  t('analyze spec, plan and tasks for consistency', 'sdd-analyze');
  t('spec plan tasks có nhất quán không', 'sdd-analyze');
  t('implement the tasks in tasks.md', 'sdd-implement');
  t('implement theo tasks.md', 'sdd-implement');
  t('does the code match the spec, close the gaps', 'sdd-converge');
  t('code đã khớp spec chưa', 'sdd-converge');
  t('write the project constitution', 'sdd-constitution');
  t('đặt nguyên tắc dự án', 'sdd-constitution');
  t('go/kill this new idea', 'sdd-assess');
  t('đánh giá ý tưởng này có nên làm không', 'sdd-assess');
  t('assess this bug with evidence and give a verdict', 'sdd-bug');
  t('bug này có bằng chứng, cho verdict', 'sdd-bug');
  // ui-design-logic audit-existing lane: positives + anti-hijack
  t('xem qua dự án của tôi xem có thể cải thiện frontend không', 'ui-design-logic');
  t('làm CSS hiện đại hơn cho dự án này', 'ui-design-logic');
  t('dự án này frontend cũ quá, nâng cấp giúp', 'ui-design-logic');
  t('review my project and improve the frontend', 'ui-design-logic');
  t('xem qua du an cua toi, co the cai thien frontend khong', 'ui-design-logic');
  t('lam css hien dai hon cho du an nay', 'ui-design-logic');
  t('audit the html and css of this web app', 'ui-design-logic');
  {
    const first = (p) => (/skills: ([^,.]*)/.exec(handle(JSON.stringify({ prompt: p }))) || [])[1];
    const f = first('review my project and improve the frontend');
    if (f === 'ui-design-logic') console.log('PASS: ui-design-logic is first for review+improve frontend');
    else { console.log(`FAIL: first hit was ${f}`); rc = 1; }
  }
  t('review this PR', 'review-lenses');
  t('soát diff này', 'review-lenses');
  t('fix the crash in the API', 'diagnosing-bugs');
  t('review backend code', 'review-lenses');
  // anti-hijack: generic words keep their old owners and never pull in sdd-*
  const tn = (prompt, bad) => {
    const out = handle(JSON.stringify({ prompt }));
    if (!out.includes(bad)) console.log(`PASS: no ${bad} - ${prompt}`);
    else { console.log(`FAIL: '${prompt}' must not hint ${bad}, got: ${out}`); rc = 1; }
  };
  tn('yêu cầu của khách chưa rõ lắm', 'sdd-');
  tn('phân tích nghiệp vụ và yêu cầu quản lý kho', 'sdd-');
  tn('the spec is outdated, please update the plan', 'sdd-');
  tn('làm đi', 'sdd-');
  tn('this function crashes, find the root cause', 'sdd-');
  tn('review the diff', 'sdd-');
  for (const p of ['review this PR', 'soát diff này', 'fix the crash in the API', 'review backend code', 'review the spec']) {
    const out = handle(JSON.stringify({ prompt: p }));
    if (!out.includes('ui-design-logic')) console.log(`PASS: no ui-design-logic - ${p}`);
    else { console.log(`FAIL: '${p}' must not hint ui-design-logic, got: ${out}`); rc = 1; }
  }

  // system-audit: positives
  t('run a full audit of the whole system', 'system-audit');
  t('do a comprehensive QA before launch', 'system-audit');
  t('audit hệ thống này giúp tôi', 'system-audit');
  t('hệ thống đã tốt chưa, đủ để dùng thực tế chưa', 'system-audit');
  t('kiểm thử toàn bộ rồi đánh giá toàn diện', 'system-audit');
  // system-audit: anti-hijack
  t('do a security audit of the login', 'security-logic');
  tn('do a security audit of the login', 'system-audit');
  tn('audit an toàn phần đăng nhập, review bảo mật', 'system-audit');
  t('review bảo mật module thanh toán', 'security-logic');
  tn('review this diff', 'system-audit');
  tn('màn này sai số liệu, bị lệch', 'system-audit');
  tn('spec plan tasks có nhất quán không', 'system-audit');
  tn('code đã khớp spec chưa', 'system-audit');

  const long ='spec flow review security crash chart pdf slow implement ui layout';
  const out = handle(JSON.stringify({ prompt: long }));
  const m = /skills: ([^.]*)/.exec(out);
  const n = m ? m[1].split(',').length : 0;
  if (n >= 1 && n <= 3) console.log(`PASS: hint capped at 3 (${n})`);
  else { console.log(`FAIL: hint not capped (${n})`); rc = 1; }

  if (handle('not json') === '' && handle('') === '' && handle('{"prompt":""}') === '' && handle('{"prompt":5}') === '') console.log('PASS: garbage input gives no hint');
  else { console.log('FAIL: garbage input'); rc = 1; }

  // one real end-to-end run: spawn this script with JSON on stdin, expect the hint line and exit 0
  const r = require('child_process').spawnSync(process.execPath, [__filename], { input: '{"prompt":"nút lưu bấm không được"}', encoding: 'utf8' });
  if (r.status === 0 && r.stdout.startsWith('[skill-router] Request may match installed skills: ui-ux-triage')) console.log('PASS: end-to-end stdin -> hint, exit 0');
  else { console.log(`FAIL: end-to-end (status ${r.status}): ${r.stdout}${r.stderr}`); rc = 1; }

  console.log(rc === 0 ? 'skill-router self-test: ALL PASS' : 'skill-router self-test: FAIL');
  process.exit(rc);
}

if (process.argv[2] === '--self-test') selfTest();
else {
  let input = '';
  try { input = require('fs').readFileSync(0, 'utf8'); } catch (e) { /* fail-open */ }
  const line = handle(input);
  if (line) process.stdout.write(line + '\n');
  process.exit(0);
}
