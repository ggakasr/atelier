---
name: decision-log
description: "Keep a per-task, append-only decision log (decisions, constraints, assumptions, questions, answers, changes, overrides, events) plus an addendum for depth that does not belong in the main artifact; resume work from the log, and promote long-lived architectural decisions to an ADR. Use when starting non-trivial work (any full-route work order, BA run, design-spec, course correction), when the user makes or reverses a decision, when resuming a task from an earlier session (tiếp tục task hôm trước), or when asked why something was decided."
---

# Decision Log

The log is the task's working memory and audit trail. Specs, work orders and ADRs are
**distilled from it**. They aren't the record themselves. Because the log only grows, several
skills can feed the same task in any order without overwriting each other.

Delegation: no subagent. Whoever is doing the work appends lines: the main session, or a
builder or architect when its brief says so. It costs a few tokens per line.

## 1. Where

- `docs/decision-log/<YYYY-MM-DD>-<slug>.md`, one per task or work order. Start it from
  [templates/decision-log.md](templates/decision-log.md).
- Optional addendum: `docs/decision-log/<YYYY-MM-DD>-<slug>.addendum.md`
  ([templates/addendum.md](templates/addendum.md)).
- Link the log from the work order frontmatter (`decision_log:`).

## 2. Line format

```
- 2026-10-08T14:05 | decision | Use soft-delete for orders: refunds need history (user, ba-spec AC-4)
```

`<ISO time> | <type> | <one line: the gist and the reason>`

Types: `decision`, `constraint`, `assumption`, `question`, `answer`, `change`, `override`, `event`.

Rules:
- **Never edit, delete or reorder lines.** When something changes, append a new line. The
  later line wins on the same point, and the history stays visible.
- Write a line as it happens, not at the end. Whatever isn't logged is lost when the task resumes.
- A decision line says what it binds and what it prevents, when that isn't obvious.
- A reversal of something the user decided is an `override`, and it needs the user's words or
  explicit approval.
- Milestones (spec approved, build done, review verdict, task closed) are `event` lines.
  The log has no status field.
- Keep it lean: no prose, no transcripts, no secrets or personal data.

## 3. Addendum

The addendum holds depth the user volunteered that doesn't fit the main artifact but is worth
keeping: rejected alternatives and why, option matrices, sizing data, technical how-to,
detailed personas. Capture it **during** the conversation, when the user offers it. Audit and
override information never goes in the addendum. That belongs in the log.

## 4. Resume

When you pick a task back up, read the log first. It is the authority on what was decided, so
don't re-ask anything it settles. Then re-derive or update the artifacts. If a rendered artifact
disagrees with the log, the log wins: fix the artifact.

## 5. Promote

- Architectural, cross-cutting and long-lived decisions get an ADR in `docs/decisions/`
  (project-template `ADR-template.md`). Append `event | promoted to ADR-NNNN`.
- Durable **user preferences** ("always ...", "never ...") belong in Claude Code memory
  (atelier-core methodology 07), not in a task log.
- A decision that changes a ba-spec or design-spec gets handed off to that skill. The log
  records the handoff.

Inspired by BMAD-METHOD's per-run memory log and addendum; rewritten for atelier.
