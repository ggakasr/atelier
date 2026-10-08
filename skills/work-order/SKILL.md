---
name: work-order
description: "Turn an agreed intent (a request, a ba-spec, a design-spec, a bug diagnosis) into a self-contained work order that a cold builder subagent can execute, then pick the build route (oneshot or full) and the review depth (none, quick or thorough). Use when the user says build it / implement / go ahead / làm đi after the WHAT is clear, when handing work to a subagent, or when a change is bigger than a one-file edit. Not for vague needs (ba-flow-logic first), UI design decisions (ui-design-logic first), or questions."
---

# Work Order

A work order is the handoff between the foreman (main session) and an apprentice (subagent).
It is the **only** thing the builder reads about the intent, so it must stand alone.

Delegation: the main session writes it (for complex or RED-adjacent work, ask `architect`
(opus, high) to draft it). `builder` (sonnet, medium; high for multi-module work) executes it.
Review runs at the depth chosen below.

## 1. Check scope first

- **One goal per work order.** Split only when the request holds two or more deliverables that
  could each ship, be reviewed and be reverted alone. "Add validation and show the errors" is
  one goal. "Dark mode, plus a JWT migration, plus an admin page" is three.
- When you detect several goals, list them, recommend which to do first, and ask once:
  **split** (do the first, park the rest in `docs/work-orders/deferred.md`) or **keep all**.
- Check git state: dirty tree or an obviously wrong branch → ask before going on
  (atelier-core hard safety rules).

## 2. Write the kernel

Use [templates/work-order.md](templates/work-order.md). Fields:

| Field | Rule |
|---|---|
| **Intent** (frozen) | The user's words plus one-line interpretation. Once the user approves, nothing changes it except the user. |
| **Why** | The problem in one or two sentences. |
| **Capabilities** | `C-1`, `C-2`, ... Each has an *intent* (what, not how) and a *success* check. Never renumber. |
| **Acceptance** | Given/When/Then. If a ba-spec exists, cite its AC IDs instead of rewriting them. |
| **Constraints** | Only constraints that rule something out. A constraint that rules nothing out is decoration, so cut it. |
| **Non-goals** | At least one. An empty list invites the builder to fill the gap. |
| **Context** | The exact files the builder must read first (specs, module CLAUDE.md, the code to touch). |
| **Tasks** | Ordered by dependency. Each has a file path and a concrete action. |
| **Verification** | The commands that prove it works (tests, lint, type-check, a manual step). |
| **Risk tier** | GREEN / YELLOW / RED, with the reason. RED parts list the one question that was asked and its answer. |
| **Open questions / Assumptions** | Anything investigation could not settle. Never invent an answer. |

Ready means actionable, ordered, testable, complete (no TBD) and coherent. Size: usually one
to two pages. Shorter invites guessing. Much longer rots in the builder's context, so move
bulky detail into an addendum (see `decision-log`) and link it.

## 3. Pick the route

| Route | When | How |
|---|---|---|
| **oneshot** | About 100 changed lines or fewer, at most ~5 files, simple or mechanical, GREEN/YELLOW | Main session or `builder` implements straight from a short inline brief. No work-order file needed. |
| **full** | Anything bigger, multi-module, or any RED part | Save the work order to `docs/work-orders/<YYYY-MM-DD>-<slug>.md`. Launch `builder` cold with: "Read <path> fully and implement it; it is the sole source of truth. Load every file under Context first. Report what changed, how you verified it, and what is left or risky." |

Estimate from what you already know. Don't do extra reading just to choose a route.

## 4. Pick the review depth

| Depth | When | What runs (`review-lenses`) |
|---|---|---|
| **none** | Doc-only, config-only, trivial GREEN oneshot | Nothing. Record `review: none`. |
| **quick** (default) | Normal GREEN/YELLOW work | One `reviewer` (sonnet, medium): checks the diff against the acceptance criteria and the repo's CLAUDE.md rules, and looks for bugs. |
| **thorough** | Any RED part; auth, payment, data or permissions; more than ~300 changed lines; or the user asks | In parallel: adversarial, edge-case, verification-gap and spec-alignment lenses (`reviewer` with model opus, effort high). Add `security-logic` when security paths are touched. |

## 5. After review: route each verified finding

Triage happens in the main session (see `review-lenses/references/triage.md`):

- **intent gap** (the frozen intent is incomplete) → revert, ask the user, re-plan.
- **plan flaw** (the work order should have prevented it) → write down what to keep, revert,
  amend the non-frozen sections, log the change in `decision-log`, rebuild.
- **patch** (small fix, no new public surface) → send it back to the same builder.
- **defer** (pre-existing, or unverified but plausibly serious) → append to
  `docs/work-orders/deferred.md`.

Cap the loop at **3** plan amendments. After that, stop and ask the user.

## 6. Close

Set the work order status to `done`, append an `event` line to the decision log, and report:
outcome, files changed, verification run, assumptions (YELLOW), deferred items, and anything
that needs the user's decision. Don't commit unless the user asked.

Inspired by BMAD-METHOD's build routing, review depth and spec-kernel handoff; rewritten for atelier.
