---
name: elicit
description: "Pressure-test a recent output (spec, plan, work order, design-spec, ADR, draft) by offering a short menu of critique methods, running the chosen ones, and applying only changes the user accepts. Use when the user asks for deeper critique, says pre-mortem / red team / phản biện / soi kỹ lại / what could go wrong, or names a method (first principles, inversion, 5 whys); other skills may call it at a pause."
---

# Elicit

The target is the most recent output in the conversation, unless the user or a calling skill
points at something else. Work in the conversation's language.

Delegation: run it inline in the main session, because it needs the user's choices. For a
heavy method on a big artifact (pre-mortem of an architecture, red team of a security
design), spawn `architect` (opus, high) with the artifact path and the method text, then
bring the result back to the menu.

## 1. Offer a menu

Look at the target and pick the 2–4 method groups that fit it: risk before a launch, technical
for code, framing when the problem statement is shaky, collaboration when stakeholders
disagree, creative when the content is flat. Then hand-pick **five** methods from
[references/methods.md](references/methods.md) that attack it from different angles. Present:

1–5. the five methods by name, each with a one-line reason it fits.
- **Reshuffle**: five different methods, none of them already offered.
- **List all**: show the whole catalogue as a compact table.
- **Proceed**: done. Hand back the current version.

The user can pick several. Any other reply counts as direction: apply it and show the menu again.

## 2. Run a method

- Use the method's description as its intent and its output shape as a loose guide. Scale the
  depth to the target: a paragraph gets a light pass, an architecture decision gets the full treatment.
- Each method works on the latest improved version, so the improvements compound.
- Show what the method revealed and the specific changes it proposes. Then ask: **Apply**,
  **Reject**, or other direction.
- **Never change the work unless the user accepts the proposal.** If they reject it, drop it entirely.
- When a method calls for personas (panel, debate, round table), invent named viewpoints that
  suit the content. No role-play menus.

## 3. Hand back

On **Proceed**, return the improved version as the replacement for the target. Confirm
anything that was shown but never accepted. If a calling skill invoked this one, say so
explicitly so the caller can resume where it paused. Record accepted changes to specs or
plans in `decision-log`.

Inspired by BMAD-METHOD's advanced elicitation; rewritten for atelier.
