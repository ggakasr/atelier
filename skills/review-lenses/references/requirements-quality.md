# Requirements-quality lens

Stance: "unit tests for requirements". You test the **quality of the spec** (ba-spec, work
order, design-spec), not the code. The question is never "does the code do X" but "is X
written well enough to be built and tested at all".

Inputs: a spec or work-order path. Read the repo's `CLAUDE.md` only for house terms. Do not
read the code unless a requirement points at it.

## Dimensions

1. **Completeness**: is every needed requirement present (states, errors, empty, permission, handoff)?
2. **Clarity**: can two readers misread it? Vague words ("fast", "valid", "as expected").
3. **Consistency**: do requirements agree with each other, with Non-goals and with Constraints?
4. **Measurability**: does each requirement or success criterion have a checkable threshold?
5. **Coverage**: does every FR map to an AC/SC, every AC to a flow or capability, and every task to an id?

## Item rules

- Each item is a question about the **text of the spec**. It must **not** start with
  Verify / Test / Check that code does...
- Each item carries a tag: `[Gap]` `[Ambiguity]` `[Conflict]` `[Assumption]` (add `[Measurability]`
  or `[Coverage]` when none fits) and a ref to the spec id, such as `[FR-003]`, `[SC-001]`, `[AC-2]`.
- Report only items that fail. An empty result is valid ("No requirement-quality gaps found.").

Bad vs good:

- Bad: "Verify the export button downloads a CSV." (tests code, not spec)
- Good: "Is the export format and the row limit stated for large result sets? [Gap] [FR-004]"
- Bad: "Check that the page loads fast." (not about the spec)
- Good: "Is 'fast' in SC-002 quantified with a threshold and a load condition? [Ambiguity] [SC-002]"
- Good: "Do FR-005 (owner approves) and R1 (only admin approves) name the same role? [Conflict] [FR-005]"

## Rules for the lens

- Never edit the spec. Describe; the foreman routes (a real spec flaw routes to intent gap → `ba-flow-logic`).
- Ticking is not yours to do for others: only a reviewer or the user may tick a checklist item.
  A builder must **never self-tick** items on its own spec or work order.

Output: Markdown list or `[]`. Fields: `location`, `problem` (the item as a question plus its tag),
`fix`, `consequence`, `ref` (the FR/SC/AC/C id).
