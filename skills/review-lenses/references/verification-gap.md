# Verification-gap lens

One question: **if the behaviour this change is meant to produce broke where it is actually
used, would any test fail?** Don't hunt for correctness bugs. If you notice one while tracing,
report it with `gap: other`.

## Gap shapes

- **regression**: the changed behaviour breaks at a consumer and no test covering that use fails.
- **missing-adoption**: a sibling site should now use the new rule or helper but handles the
  case its own way, and no test notices. This qualifies only with a clear signal that the new
  behaviour replaces the old one (intent, naming, a replaced sibling, deleted duplicate logic)
  **and** a shared observable contract. Without both, it is a refactor suggestion, not a finding.
- **broken-verification**: a test appears to cover the behaviour, but it is skipped, flaky,
  outside the normal test run, or too weak to see the regression.

## Evidence rules

- Read a test before you claim what it covers.
- Before you claim no test exists, search the whole repo by the symbol and by its imports.
- Say what you actually checked ("none of the 4 tests I read cover this").
- Drop any finding you cannot ground.

## Steps

1. **Screen.** Is the change behavioural? Formatting, comments, pure renames and type-only
   changes are not behavioural, so return `[]` and say "non-behavioural". Exception: a
   test-only change that removes or weakens verification still counts.
2. **Name the changed behaviour(s):** output, side effect, branch, error, schema or event
   shape, default, validation or authorization rule. Dependency, build and config changes count too.
3. **Trace to consumers:** callers, routes, commands, schema or event readers. Usually 1–3
   hops. Stop when a test at that boundary would fail, when the consumer cannot observe the
   change, or when the next hop is guesswork.
4. **Demonstrate.** For each consumer, name the smallest realistic regression (invert the
   branch, drop the default, omit the field). Then read its test. Would an assertion fail?
   These don't count as verification: success-only or no-throw checks, snapshot-only tests,
   mock-call-only tests, tests that mock away the integration, and stale fixtures.
5. **Re-check** each finding against the tests and searches it relies on before you report it.

For LLM-backed behaviour, stop at the inference boundary. Deterministic prompt building and
response parsing can still be verified.

## Output

Markdown list, or `[]`. If the list is empty, write exactly: `No verification gaps found.`
Fields: `location`, `problem`, `fix` (the missing assertion, in the repo's own test style),
`consequence`, `gap` (regression | missing-adoption | broken-verification | other),
`consumer` (named, with file:line), `evidence` (what you read or searched).
