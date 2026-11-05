# [CHECKLIST TYPE] Checklist: [FEATURE NAME]

**Purpose**: [What requirements-quality area this covers]
**Created**: [DATE]
**Feature**: [Link to specs/NNN-slug/spec.md]

**Review ownership**: reviewer-owned requirements-quality artifact. Mark an item `[x]` only when the reviewer judges the criterion satisfied.
**Marker semantics**: `[x]` means the requirement text was reviewed and is good enough. It does NOT mean implementation is done. The agent never ticks items.

<!-- Replace the sample items below with real ones derived from the spec. Delete these samples. -->

## [Category 1, e.g. Requirement Completeness]

- [ ] CHK001 Are [requirement type] defined for [scenario]? [Gap]
- [ ] CHK002 Is [vague term] quantified with specific criteria? [Clarity, FR-###]
- [ ] CHK003 Are requirements consistent between [section A] and [section B]? [Consistency, Spec §x]

## [Category 2, e.g. Scenario Coverage]

- [ ] CHK004 Are recovery/rollback requirements defined for [failure]? [Coverage, Gap]
- [ ] CHK005 Can [requirement] be objectively measured? [Measurability, SC-###]

## Notes

- Leave items unchecked while they still need clarification, correction or reviewer evaluation
- Items are numbered sequentially (CHK001...) and never renumbered; later runs append
- Tags: [Gap] [Ambiguity] [Conflict] [Assumption]; refs: FR-###, SC-###, Spec §x
- Add findings inline under the item
