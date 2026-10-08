# Triage (main session)

Start only after every lens has reported. Throw away any severity a reviewer assigned.

## 1. Verify, then give one verdict per finding

Go to the cited location and read far enough (callers, upstream guards) to answer one
question: **does the bad outcome actually happen?** A true fact about nearby code does not
settle it.

| Verdict | Meaning |
|---|---|
| `high` | Real and intolerable for users or developers |
| `medium` | Real and tolerable |
| `low` | Real but cosmetic or negligible |
| `false` | You checked, and it does not happen. Write what disproves it. |
| `unsure` | The code cannot settle it. Write what would. |

Developer-only harm (diverging sources of truth, eroded invariants) needs a named place where
it will cause trouble. Otherwise it is `false` or `unsure`. When the harm is real but its size
is unclear, pick the higher grade. Loud failure on an input you have not shown can occur is
correct behaviour, not a defect. Verification-gap findings arrive with their evidence, so
trust what they filed and only verify their `other` items.

Rejections: drop `false` items. Drop `low` items when everyday use is unlikely to hit them
**and** the fix adds complexity. Drop anything whose fix is just to edit the work order.

## 2. Group by shared root cause

Group findings only when the same defect produced them. Sharing a location or a fix is not
enough. A group takes the highest verdict among its members.

## 3. Route each group to exactly one category

| Route | Test | Action |
|---|---|---|
| **intent gap** | Caused by this change; can't be fixed from the work order because the frozen intent is incomplete | Revert, ask the user, re-plan. Behavioural gaps go back to `ba-flow-logic`. |
| **plan flaw** | Caused by this change; the work order should have prevented it. When torn between this and patch, prefer this | Note what to KEEP, revert, amend the non-frozen sections, log it in `decision-log`, rebuild |
| **patch** | Caused by this change; the smallest fix is trivial, adds no public surface, and guards no undemonstrated state | Send back to the same builder: file, what's wrong, what the smallest fix must do. Re-run verification after |
| **defer** | Pre-existing; or all `unsure` but would be medium/high if true; or the fix edits agent-context files (CLAUDE.md, rules) | Append to `docs/work-orders/deferred.md`: source, one-line summary, evidence or what would settle it |

Run them in cascade order. Any intent gap or plan flaw triggers a loopback, and patch and
defer items wait for the rebuilt code. Cap: 3 loopbacks, then ask the user.

## 4. Record

One row per finding (rejected ones included) in the work order's `## Review triage`:
`lens | location | verdict | route | evidence`.
