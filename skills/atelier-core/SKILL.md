---
name: atelier-core
description: "Atelier operating rules: LOGIC vs REQUEST, GREEN/YELLOW/RED risk tiers (RED = stop, ask one question), authority levels, minimal context routing, doc/code drift, and which subagent does which job. Use when starting or onboarding a repo, deciding how to delegate, the AI invents function names or docs drift from code (docs lệch code), or unsure which atelier skill applies. Not for BA (ba-flow-logic), UI design (ui-design-logic), running-app defects (ui-ux-triage) or security (security-logic)."
---

# Atelier Core

The user is the master: they set direction and approve anything irreversible. The main session
is the foreman: it classifies, routes, delegates and reports. Subagents are the apprentices:
each gets a self-contained brief and runs at the cheapest model and effort that can do the job well.

This skill is a slimmed version of ai-simple's `ai-simple-product-dev`. The English sections are
atelier's own. The Vietnamese sections are upstream text kept as written. Principle files live
in `methodology/` (index: [methodology/README.md](methodology/README.md)).

## 1. Every request: four quick gates

1. **LOGIC vs REQUEST** ([05](methodology/05-logic-vs-request.md)). A question gets an answer, not an edit.
   A pasted error with no "fix" is a question.
2. **Route minimal context** ([03](methodology/03-context-routing.md)). Trivial, one file, known path:
   skip routing. Multi-domain or new session: spawn `router` (haiku, low) and read only what it lists.
3. **Risk tier** ([06](methodology/06-pre-flight-checklist.md)). Score by how hard it is to undo:
   - **GREEN**: undo with git (code, UI, docs, tests, new files, read-only). Do it. Don't ask.
   - **YELLOW**: undo needs a prepared step (new table, nullable column, flag, config). Do the safe
     version with its rollback and list it under `## Assumptions` at the end. Don't ask first.
   - **RED**: no way back, or it breaks production (DROP, lossy ALTER, loosened access rules,
     mutating prod data, touching running cron or edge functions, breaking a shared schema).
     Stop. Ask exactly **one** combined question with a recommended option. Keep doing the
     non-RED parts of the task while you wait.
4. **Authority** (below). Reversible is not the same as authorized.

## 2. Delegation matrix

| Job | Agent | Model | Effort |
|---|---|---|---|
| Route context, score tier | `router` | haiku | low |
| Find files, read-only lookup | `explorer` | haiku | low |
| Small, clear or mechanical edit | `builder` | sonnet | low |
| Typical feature or bug fix from a work order | `builder` | sonnet | medium |
| Multi-module or tricky build | `builder` | sonnet | high |
| Quick review (one lens) | `reviewer` | sonnet | medium |
| Thorough review, security, RED-adjacent diff | `reviewer` (override) | opus | high |
| Design-spec, architecture, ADR, hard debugging, course correction | `architect` | opus | high |
| Questions about Claude Code itself | `claude-code-guide` | default | default |

Rules for briefs: the apprentice starts cold. Give it the goal, the exact paths, the constraints,
the risk tier, and what to return. A written `work-order` is the preferred brief for anything
beyond a one-shot change. Independent jobs run in parallel. Don't spawn more than the job needs.

## Weak run and escalation

A run is judged weak by checks anyone can verify, never by the user's taste. The foreman (or a
separate reviewer) judges, not the user.

A run is **WEAK** only if at least one of these holds:

1. A command, test or build fails (non-zero exit), or tests fail after the agent said done.
2. "Done" is claimed with no proof: the check command from the work order was not run, or its output is missing.
3. An acceptance check (a "Done when" line) from the work order fails.
4. Scope drift: the diff touches files outside the work order's list, or misses required ones.
5. Invented facts: a function, file or path the agent names does not exist (verify with a search).
6. Thrashing: the same error after 2 attempts.
7. A separate reviewer agent (never the one that did the work) reports a blocking finding.

**Gray zone:** if no signal holds, the run is NOT weak, even if the result feels mediocre. Do not
escalate (this prevents cost creep). Taste questions (does it look right) are not model problems:
show a before/after or a screenshot and ask the user one closed question.

**Escalation ladder:** model sonnet → opus; effort low → medium → high → xhigh. Haiku jobs
(`router`, `explorer`) go to sonnet first. The ladder stops at opus; do not use fable (the costliest tier) unless the user names it. Start every job at the cheapest row of
the table above that fits. On a weak signal, move up exactly one step and re-run with the same
brief plus the failure evidence. At most 2 steps up per task. After that, stop and tell the user in
one line what was tried and what still fails.

**No objective test (design, writing):** before work, write 3-5 plain-language "Done when" checks
(example: "the table does not scroll sideways at 375px") into the work order and get the user's
one-time approval. Those checks are the yardstick.

## 3. Pipeline and skills

```
need is vague ──► ba-flow-logic ──► ba-spec (AC = behaviour oracle)
needs UI ───────► ui-design-logic ─► design-spec (visual oracle)
ready to build ─► work-order (kernel + route + review depth) ─► builder
after build ────► review-lenses (none | quick | thorough) ─► triage findings
running app wrong ► ui-ux-triage (reads both oracles; RED-only escalation)
any stage ──────► security-logic (cross-cutting) · decision-log (append-only)
plan broke ─────► course-correct        artifact feels thin ─► elicit
```

Reverse handoffs are normal: triage finds the spec is wrong → `ba-flow-logic`; design finds a
missing behaviour → `ba-flow-logic`; security finds an unsafe AC → `ba-flow-logic`.

## Bước 0 — chọn profile (upstream, rút gọn cho atelier)

| Profile | Khi nào | Nguyên tắc |
|---|---|---|
| tiny | Project < 10 file / thử nghiệm vứt đi | 01 + 06 (CLAUDE.md mỏng + risk tier) |
| core | Mọi project nghiêm túc | 01–07 |
| ops | Có process chạy nền (cron/agent/pipeline) | + 11 |
| optimization | Hệ chạy > 3 tháng / muốn học từ revisions | + 12 |
| security | Code chạm auth/payment/crypto/migration / có dependency ngoài / docs từ nhiều nguồn | + 14 (skill `security-logic`) |

**Đường tắt: Core profile + task GREEN = bước 1→2→4→5→8→9→13** (Nhận yêu cầu → Phân loại LOGIC/REQUEST → Route minimal context → GREEN/YELLOW/RED → Implement đúng scope → Validate code/test/doc → Commit/tích hợp theo quyền được cấp).

## Nguyên tắc (bản atelier giữ lại)

1. **Hierarchical Context** — root CLAUDE.md < 6K token, link xuống module → [01](methodology/01-hierarchical-context.md)
2. **App-map** — doc canonical đánh số theo domain → [02](methodology/02-app-map-pattern.md)
3. **Context Routing** — deterministic trước, LLM fallback → [03](methodology/03-context-routing.md)
4. **Doc + Test Sync** — behavior change ↔ test; documented change ↔ doc; cùng commit → [04](methodology/04-doc-test-sync.md)
5. **LOGIC vs REQUEST** — hỏi ≠ yêu cầu; hybrid tách đôi → [05](methodology/05-logic-vs-request.md)
6. **Risk Tiers** — GREEN/YELLOW tự làm với default an toàn; RED mới confirm (đúng 1 câu gộp) → [06](methodology/06-pre-flight-checklist.md)
7. **Memory** — preference explicit của user = fast-path vòng B → [07](methodology/07-memory-as-feedback.md)
8. **Automated Enforcement** — chỉ tham khảo; atelier không ship hook lớn → [08](methodology/08-automated-enforcement.md)
11. **Ops Layer** — sự cố → runbook trước code → [11](methodology/11-ops-layer.md)
12. **Evidence-Driven Self-Evolution** — coupling map doc↔code + cổng đọc verify-on-use → [12](methodology/12-self-optimization.md)
14. **Security as a Declared Gate** — khai báo phủ sóng, KHÔNG "đã bảo mật ✓" → [14](methodology/14-security-gate.md)
15. **Build Discipline** — thang 7 bậc dừng-ở-bậc-đủ; guardrail không được cắt; thiếu-spec → handoff ngược → [15](methodology/15-build-discipline.md)

## Hard safety rules (mọi profile, mọi lúc)

- ĐỌC đủ Git state (branch/HEAD/status/dirty/untracked/worktrees) trước khi sửa code hay tạo worktree.
- CẤM: tự stash thay đổi của user; reset/checkout đè; di chuyển dirty changes; xóa branch/worktree không rõ owner. **Dirty work của user là bất khả xâm phạm.**
- RED (không quay đầu: DROP, mutate prod, RLS nới) = dừng, đúng 1 câu confirm kèm phương án khuyến nghị. Confirm là ngoại lệ đắt giá, không phải nghi thức.

## AUTHORITY CONTRACT (trục ĐỘC LẬP với risk tier — áp cho MỌI skill)

**Reversible ≠ authorized.** Risk tier trả lời *"sai thì undo mất bao lâu"*; authority trả lời *"user đã cho phép chưa"*. Một việc dễ undo (bật cờ gửi tin, cài thêm tool) vẫn cần quyền. Bốn mức, chấm độc lập với GREEN/YELLOW/RED:

| Mức | Phạm vi | Quy tắc |
|---|---|---|
| **L0 — local workspace write** | Sửa file trong repo đang làm, tạo branch/worktree, chạy test cục bộ | Được phép theo scope task. Vẫn cấm đụng dirty của user (mục trên). |
| **L1 — external communication / install / publish / deploy** | Gửi tin (telegram/email/SMS), cài công cụ hoặc dependency ngoài, publish package, deploy | **Cần user cho phép TƯỜNG MINH cho chính việc đó.** "Có sẵn script/tool" hay "user từng đồng ý lần trước" KHÔNG phải quyền. Kênh consent phải nằm NGOÀI thứ agent ghi được (config tầng user / câu trả lời trực tiếp của user). |
| **L2 — production data** | Đọc/ghi dữ liệu thật đang phục vụ người dùng | **Mặc định CẤM.** Chỉ khi user nêu đúng target + cấp quyền cho lần đó. Mặc định làm trên staging/tenant cô lập/synthetic identity. Đọc-only vẫn phải hỏi nếu là dữ liệu cá nhân. |
| **L3 — destructive filesystem / history** | `rm -rf`, `Remove-Item -Recurse -Force`, rewrite git history, xoá branch/worktree | Bắt buộc theo thứ tự: **resolve target thật (đường dẫn tuyệt đối, phân biệt junction/symlink vs thư mục thật) → kiểm owner → backup → confirm** nếu không chắc phục hồi được. Không có bước nào được bỏ vì "chắc là đúng thư mục". |

Agent bị CẤM tự nâng quyền cho chính mình: không tự set env consent, không tự ghi file consent tầng user, không tự thêm token phê duyệt.

## 4. Doc/code drift (atelier summary of 04 + 12)

- A doc that describes code carries `covers:` and `last_verified:` in its frontmatter (see
  [02](methodology/02-app-map-pattern.md) and [12](methodology/12-self-optimization.md)).
- Before you trust a doc whose covered code changed after `last_verified`, check only the
  claims you are about to use against the code. If they match, bump `last_verified`. If they
  don't, fix the doc first, then code.
- Code change that alters behaviour ships with its test and its doc update in the same commit.
  The only exemptions: pure UI tweak, config-only, doc-only.

## 5. Not shipped from ai-simple

The Node CLI (`init`, `doctor`, `parallel`), the 1000-line pre-commit hook template, CI
workflows, `/audit` and `/learn` commands, evals, and principles 09 (generated docs),
10 (cross-repo contracts) and 13 (parallel sessions). Claude Code's own worktree isolation
covers most solo parallel work. Read upstream ai-simple if a project outgrows this.
