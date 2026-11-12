# Work order: reframe skill + give-up guard hook + CLAUDE.md rule

status: ready | route: full | review: quick | risk: GREEN (new files + small edits to docs/wiring in this repo; nothing installed to ~/.claude)

## Intent (frozen)
User: "tôi muốn Claude có tư duy chủ động, không gán nhãn dễ/khó rồi từ chối; ghi thành luật; làm đầy đủ (rule + skill + hook)".
Interpretation: stop FEASIBILITY give-ups ("không làm được / cannot / too complex / out of scope") that lack evidence. Safety refusals must never be touched.

## Why
Claude labels work easy/hard early and then only confirms the label. Need (a) a short standing rule, (b) a procedure skill, (c) a Stop hook that forces ONE retry when a final answer gives up without evidence.

## Capabilities
- C-1 `skills/reframe/SKILL.md` (+ optional `references/blocker-report.md`). Procedure: ban easy/hard labels -> ask "what must be true / smallest experiment" and run it; before settling list >=3 different approaches incl. one that flips a constraint (partial delivery, other tool, redefine done, drop an assumption); blocked -> 3x "why" then split; give up ONLY via the blocker format: tried A,B,C (with evidence) -> blocked where -> what unlocks it -> what the user must decide. Classify blocker: real (safety/permission/physics) vs false (missing info/untried). Skill explicitly does NOT override safety refusals. Must pass `scripts/lint-skills.sh` (read it for the frontmatter/description rules; description starts with what it does + "Use when ..." + "Not for ...", EN + VN trigger words ok).
  Independent test: lint passes; skill reads standalone.
- C-2 `hooks/giveup-guard.sh` Stop hook. Behavior: read hook JSON from stdin. If `stop_hook_active` is true -> exit 0 (retry once only). Get last assistant text (use field `last_assistant_message` if present, else parse the last assistant entry of `transcript_path`; follow how existing hooks in `hooks/` parse JSON and what runtime they assume - bash + node is fine, no new dependencies). Tiering: HIGH-confidence give-up phrases (EN: "cannot be done", "not possible", "impossible", "out of scope", "too complex", "beyond what I can", "I'm unable to"; VN: "không thể làm", "không làm được", "bất khả thi", "quá phức tạp", "ngoài phạm vi", "không khả thi"). Block only if a HIGH phrase matches AND the text has NO evidence marker (code fence, a "tried"/"đã thử" list, error quote, file:line, "blocker"/"chặn ở") AND NO safety marker (EN: "policy", "unsafe", "harmful", "not allowed", "security risk", "permission"; VN: "an toàn", "không được phép", "chính sách", "quyền"). Skip very short replies (<200 chars). On block print `{"decision":"block","reason":"..."}` where reason (Vietnamese, short) says: list 2-3 other approaches, run the smallest experiment, then report with the blocker format from the reframe skill; reporting a real blocker WITH evidence is a valid exit. Never exit non-zero on parse errors: fail open (exit 0).
  Independent test: `scripts/selftest-giveup-guard.sh`.
- C-3 `scripts/selftest-giveup-guard.sh`: >=8 cases piping JSON into the hook (EN give-up w/o evidence -> block; VN give-up -> block; give-up WITH tried-list -> pass; safety refusal -> pass; stop_hook_active true -> pass; short reply -> pass; no phrase -> pass; garbage input -> pass). Add it to `.github/workflows/ci.yml` next to the other self-tests (match their style, both ubuntu and windows jobs).
- C-4 Wiring: add the hook to whatever `hooks/wire.js` / installers (`install.sh`, `install.ps1`, `uninstall.*`) do for existing hooks, including the sha256 manifest convention if one exists. Do NOT run the installer; do NOT touch ~/.claude.
- C-5 Docs: `global/CLAUDE.md` add a short section "Proactive thinking (no premature give-up)" (<=12 lines: the 5 rules, safety carve-out, pointer to skill `reframe`) and a routing-table row for `reframe` (request sounds like: "Claude says can't / too hard / từ chối / không làm được / bí đường / reframe / thử hướng khác"). Mirror the row in `hooks/skill-router.js` keywords. `hooks/README.md` document the new hook and its one-retry + fail-open design. `CHANGELOG.md` add an Unreleased entry. Do not bump VERSION.

## Acceptance
- Given a final reply "Việc này không làm được vì quá phức tạp." (no evidence) When Stop hook runs Then output has decision=block; same input with stop_hook_active=true -> no output, exit 0.
- Given a reply with a "Đã thử: A, B, C ... chặn ở ..." list Then pass.
- Given a refusal citing safety/policy Then pass.
- `bash scripts/lint-skills.sh` and every existing self-test still pass, plus the new one.

## Constraints
- No new dependencies. Hook must work in Git Bash on Windows and on ubuntu. Fail open.
- Match existing style of sibling hooks/scripts. Surgical edits to existing files.

## Non-goals
- No Haiku/LLM-judge layer, no subagent layer. No plugin packaging. No install to the user's machine. No commit. Do not copy code from other repos (stop-phrase-guard is Apache-2.0 prior art for the *idea* only; anti-laziness-guard has no license).

## Context (read first)
hooks/README.md, hooks/foreman-nudge.sh, hooks/git-guard.sh, hooks/wire.js, hooks/skill-router.js, scripts/lint-skills.sh, .github/workflows/ci.yml, install.sh, install.ps1, global/CLAUDE.md, CHANGELOG.md, one existing skills/*/SKILL.md for format.

## Tasks (in order)
1. C-1 skill. 2. C-2 hook. 3. C-3 selftest + CI line. 4. C-4 wiring. 5. C-5 docs/router/changelog. 6. Run lint + all self-tests.

## Done when
- `bash scripts/lint-skills.sh` exits 0 (paste output tail).
- `bash scripts/selftest-giveup-guard.sh` exits 0 with all cases listed PASS (paste output).
- Every other existing self-test in ci.yml still passes (paste a one-line result each).
- `git status` shows only intended files; nothing outside the repo touched (paste it).
Verification commands: those above.

## Open questions / Assumptions
- Assumed bash+node available as in existing hooks; builder confirms from sibling hooks and reports if wrong.
