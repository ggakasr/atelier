---
name: course-correct
description: "Handle a significant mid-work change (technical limit, new or misunderstood requirement, pivot, failed approach): assess impact on work orders, specs, ADRs and tests, weigh paths (adjust, roll back, cut scope), and produce a change proposal for approval. Use when the user says correct course / đổi hướng / plan này không ổn nữa, a builder or reviewer reports the plan cannot work, or the review loop hits its cap. Not for small patches (work-order) or brand-new features (ba-flow-logic)."
---

# Course Correct

Delegation: `architect` (opus, high) does the impact analysis and drafts the proposal. The
main session talks to the user. A change of direction is the master's call, so the proposal
ends in **one** approval question with a recommended path.

Work through the checklist with the user. Mode: **incremental** (agree each edit as you go,
the default) or **batch** (present the whole proposal at once). Ask which once.

## Checklist

### 1. Trigger and evidence
- [ ] What revealed the problem? (work order, task, review finding, user report)
- [ ] Type: technical limit · new requirement · misunderstood requirement · pivot · failed approach.
- [ ] Problem statement in two or three sentences.
- [ ] Concrete evidence: error output, failing test, user feedback, a measured constraint.
- **Stop** if the trigger is unclear or there is no evidence. Ask for it. Don't analyse a hunch.

### 2. Impact on current work
- [ ] Can the current work order still finish as written? If not, what has to change?
- [ ] Which other open or deferred work orders are affected? Do any become obsolete, and
      does the order need to change?

### 3. Artifact conflicts
- [ ] ba-spec: which AC, flows or invariants are now wrong or missing? → `ba-flow-logic`
- [ ] design-spec: screens, states or budgets affected? → `ui-design-logic`
- [ ] ADRs and architecture: which decisions are invalidated? → new ADR that supersedes
- [ ] Tests, docs, CLAUDE.md, ops runbooks, deployment: what has to follow?
- [ ] Security implications? → `security-logic`

### 4. Paths forward (score each for effort H/M/L and risk H/M/L)
- [ ] **Adjust**: change or add tasks inside the current plan.
- [ ] **Roll back**: revert recent work when that makes the fix simpler. Name exactly what
      gets reverted. Reverting committed history is L3 or RED, so it needs the user.
- [ ] **Cut scope**: is the original goal still reachable? What moves to later?
- [ ] Pick one (or a hybrid) and justify it: effort, risk, long-term maintainability, value to the user.

### 5. Change proposal
Write [references/change-proposal.md](references/change-proposal.md) to
`docs/work-orders/<YYYY-MM-DD>-change-<slug>.md`: summary, impact, recommended path and
rationale, specific edits (old → new) per artifact, who carries each edit, and how success is verified.

### 6. Approval and handoff
- [ ] Ask the user one question: approve, revise or reject, with your recommendation.
- [ ] Log it in `decision-log`: `change` lines for each accepted edit, `override` if an earlier
      user decision is reversed, and an `event` line for the approval.
- [ ] Hand off: spec edits → their skills; implementation → new or amended `work-order` → `builder`.

Inspired by BMAD-METHOD's correct-course checklist; rewritten for atelier.
