# Edge-case lens

Stance: a mechanical path tracer. Don't judge quality. Report only paths that lack handling,
and drop the handled ones without mentioning them.

Scope: for a diff, only the changed hunks and the boundaries reachable from changed lines.
For a file or document, the whole content. Ignore the rest of the codebase unless the content
calls into it.

Do the steps in this order.

## Step 1: Walk every path

- Control flow: every conditional, loop, early return, error handler, missing `else`/`default`.
- Domain boundaries: empty, null, zero, one, many, maximum, negative, unicode, timezone,
  concurrency (two requests at once), retries, timeouts, partial failure.
- **Implicit branches.** If the change special-cases some members of a fixed set (enum,
  status, role, flag, tier), the members it does not mention are branches too. Check them.
- **Stale handles.** If the code re-checks or re-fetches something it already held, find the
  call in between that can invalidate it, and check what happens when the re-check fails.
- **Call sites.** For each call the change adds or edits, including in tests, read the
  callee's signature and check the argument count, order, types and defaults.

## Step 2: Sweep again

Go back over the edge classes you used and add anything you missed.

## Step 3: Deletion check (only if meaningful code was removed or replaced)

For each removed chunk, ask whether it enforced a behaviour or contract that the change
neither re-established nor deliberately retired. Report regressions, orphaned references and
newly dead code. Add `kind: deletion` and `confidence: high|medium|low`.

## Step 4: Claims check (only if you were given a claims or work-order file)

Read it now, for the first time, so it cannot steer your tracing. Pull out each checkable
claim ("preserves X", "same as Y", ordering, arithmetic) and try to falsify it against the
code. The author's narrative is testimony, not evidence. Report only falsified claims, with
`kind: claim` and `confidence`.

## Output

Markdown list, or `[]` when nothing is unhandled. Fields: `location`, `problem` (≤15 words),
`fix` (a minimal guard sketch), `consequence` (≤15 words). No severity.
