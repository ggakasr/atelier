# Changelog

Format follows Keep a Changelog. Versions follow the `VERSION` file.

## [Unreleased]

### Added
- `ui-design-logic` reference 09 (modern web platform): Baseline fallback policy, legacy-to-modern table,
  shadcn-wins conflict rule, anti-patterns; pointer in SKILL.md and skill-router keywords. Ideas inspired by
  GoogleChrome/modern-web-guidance (CC-BY 4.0 guides, Apache-2.0 code); wording is original.
  Optional live lookup via `skills/ui-design-logic/modern-web.sh` (search / retrieve / advisory scan, `--strict`
  opt-in gate): wraps `npx modern-web-guidance@1.0.0` with telemetry forced off, untrusted-output fence,
  no install/update/set-*, skip-with-exit-0 without node>=22. Offline `--self-test` wired into CI.
- `ui-design-logic` reference 10 (AUDIT-EXISTING lane): report-only audit of an existing frontend for legacy
  patterns (grep-style checklist against 09, optional `modern-web.sh scan`, findings by impact with file:line,
  effort, risk, 3 ordered recommendations, no edits until the user picks). skill-router now routes phrases like
  "cải thiện frontend", "frontend cũ", "làm CSS hiện đại hơn", "review my project and improve the frontend" to
  `ui-design-logic` (with and without diacritics), with anti-hijack self-tests for diff/PR/backend/crash.
- `reframe` skill: replace easy/hard labels with a smallest experiment, list at least 3 approaches
  (one flipping a constraint), give up only with the blocker report format. Never overrides safety refusals.
- `hooks/giveup-guard.sh` (Stop hook): blocks once on an evidence-free feasibility give-up, fail-open,
  skips safety refusals; wired by `wire.js` (`--wire-hooks`); `scripts/selftest-giveup-guard.sh`, run in CI. Min reply length is 30 (override `ATELIER_GIVEUP_MIN`): the work order's "<200" conflicted with its own
  41-char acceptance example. Wide EN+VN safety markers win over give-up phrases.
- Global rule "Proactive thinking (no premature give-up)", `reframe` routing row and skill-router keywords.

## [0.1.0] - baseline

### Added
- Initial lean personal Claude Code workshop: global instructions, agents, project template.
- Core workflow skills: atelier-core, ba-flow-logic, ui-design-logic, ui-ux-triage, security-logic,
  work-order, review-lenses, course-correct, decision-log, elicit.
- Skills adapted from mattpocock/skills (MIT): diagnosing-bugs, tdd, pr, handoff.
- 11 `sdd-*` skills ported from github/spec-kit (MIT): constitution, specify, clarify, plan, tasks,
  checklist, analyze, implement, assess, bug, converge. Spec-kit ideas also adopted into core skills
  (question budget, FR/SC ids, requirements-quality lens, convergence, URL policy).
- system-audit skill: evidence-based whole-system audit and QA.
- Hooks: skill-router (prompt routing, ported to node), skill-gap (SessionStart),
  foreman-nudge (PostToolUse), git-guard (PreToolUse), each with a `--self-test` where present.
- Installer (`install.ps1`, `install.sh`) with a merge-only `wire.js` that updates just the marked
  block in an existing CLAUDE.md and keeps `~/AGENTS.md` in sync.
- Global rules: foreman rule, skill upkeep (capture, mis-route, gap), bounded "Reuse before building",
  code discipline, weak-run definition and escalation ladder with required Done-when checks.
- Haiku tier for exact-spec mechanical edits; builder may run on haiku.
- Mis-route handling and Vietnamese routing test cases for the skill router.

### Changed
- skill-router rewritten from shell to node (about 10x faster per prompt).
- Main session must load a skill itself before delegating to a subagent.
- Escalation ladder docs explain the fable ban.

## How to release
1. Bump `VERSION`, move the Unreleased entries under a new `## [X.Y.Z] - date` heading.
2. Commit, then tag `vX.Y.Z` and push the tag.
