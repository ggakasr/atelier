---
name: review-lenses
description: "Review a diff, branch, uncommitted changes, spec or document through independent lenses (adversarial, edge-case, verification-gap, spec-alignment, requirements-quality) run as parallel reviewer subagents, then triage every finding. Use when the user says review / soát / check this diff / review PR, or a work order sets review depth quick or thorough. Not for applying feedback from an earlier review (that is a change); never run uninvited on your own edits outside a work order."
---

# Review Lenses

Each lens is a different method and stance. Reviewers report what is real and never pad a
review to look thorough. **Zero findings is a valid result** for the edge-case,
verification-gap and spec-alignment lenses. Only the adversarial lens treats an empty list as a
reason to look again.

Delegation: every lens runs as a `reviewer` subagent with no prior context. Quick depth uses
sonnet, medium. Thorough depth, security-sensitive diffs or RED-adjacent work use opus, high
(override the model and effort on the Agent call). The main session triages, so it stays as
the foreman's judgement.

## 1. Stage the content once

- Diff, branch or uncommitted work: write a unified diff to a temp file, including untracked
  files (`git diff <base>...HEAD`, or `git diff HEAD` plus `git ls-files --others --exclude-standard`).
  A branch means its diff against the merge base.
- Pass **paths** to reviewers, never pasted content. Pass the work order or ba-spec path only
  to the lenses that need it (spec-alignment, and edge-case for its late claims check).
- Classify the content as code or docs. A spec or plan is docs, but a behavioural lens can still apply to it.

## 2. Choose lenses

| Lens | File | Applies to | Stance on zero findings |
|---|---|---|---|
| **spec-alignment** | [references/spec-alignment.md](references/spec-alignment.md) | code + a work order or ba-spec | valid |
| **adversarial** | [references/adversarial.md](references/adversarial.md) | anything | re-check before returning empty |
| **edge-case** | [references/edge-case.md](references/edge-case.md) | code, behavioural specs | valid |
| **verification-gap** | [references/verification-gap.md](references/verification-gap.md) | code with behaviour change | valid ("No verification gaps found.") |
| **requirements-quality** | [references/requirements-quality.md](references/requirements-quality.md) | a ba-spec, work order or design-spec (tests the spec, not the code) | valid |

- **quick** = spec-alignment only (or adversarial when there is no spec).
- **thorough** = all four code lenses in parallel, plus requirements-quality when a spec or work order is in scope.
- When the user names lenses, run exactly those.
- Security paths touched → also run `security-logic` (its own skill, not a lens file here).

Announce the plan in one line (content class, lenses), then launch every lens before reading
any result.

## 3. Reviewer brief (per lens)

```
You are a reviewer. Read <skill-dir>/references/<lens>.md completely and follow it.
Content under review: <absolute path to staged diff or document>.
<only for spec-alignment / edge-case:> Spec or claims file: <path> (edge-case: leave unread until its claims step).
Return ONLY your findings as text. Do not edit files, invoke skills or spawn subagents.
```

## 4. Finding shape (all lenses)

- `location`: file:line range, or section for documents
- `problem`: one line
- `fix`: the concrete guard, check or change
- `consequence`: what goes wrong if it ships as-is
- plus any lens-specific fields

Reviewers never assign severity. They lack the context to grade.

## 5. Triage

Follow [references/triage.md](references/triage.md): verify each finding at its location,
give one verdict (`high`, `medium`, `low`, `false`, `unsure`), group by shared root cause,
and route to **intent gap / plan flaw / patch / defer**. Record one row per finding in the
work order's `## Review triage` (or in the chat report when there is no work order). Overlap
between lenses counts as signal, so keep both findings and note the overlap.

Inspired by BMAD-METHOD's review lenses; rewritten for atelier.
