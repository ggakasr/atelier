# Spec-alignment lens

Stance: the acceptance criteria are the oracle (atelier inherits this from ai-simple's ba-spec).
Judge the change against the spec, not your own taste.

Inputs: the diff, plus a work order, ba-spec or design-spec path. Also read the repo's
`CLAUDE.md` (root, and the folders the diff touches). Those are the house rules.

1. List every acceptance criterion or capability (`AC-n`, `C-n`) in scope.
2. For each one: is it implemented, and is there a test that would fail if it broke?
   Report AC that are unmet, partly met or untested.
3. Report behaviour in the diff that **no** AC asks for (scope creep). Exception: states that
   build discipline requires anyway (loading, empty, error, permission), as long as they are
   recorded under Assumptions.
4. Report broken house rules (CLAUDE.md, the risk-tier rules, doc+test sync).
5. Classify each gap from steps 2-3 as `missing` (not built), `partial` (built in part),
   `contradicts` (built against the spec) or `unrequested` (built, but nothing asks for it).
   A done claim, a ticked box or a report saying "done" is not evidence: look at the code and the proof.
6. Describe; don't prescribe new work beyond the spec. If the spec itself looks wrong, say
   "possible spec gap" and leave it to triage (it routes to intent gap → ba-flow-logic).

Output: Markdown list or `[]`. Fields: `location`, `problem`, `fix`, `consequence`, `ac` (the
criterion ID, or `rule:<name>`, or `scope-creep`), plus `gap` (`missing | partial | contradicts | unrequested`) when it applies.
A result with no gaps is `[]` ("converged"). The foreman may turn gaps into appended tasks (see `work-order` "Convergence").
