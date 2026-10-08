---
title: <short title>
slug: <kebab-case-slug>
status: draft            # draft | ready | in-progress | in-review | done | blocked | dropped
route: full              # oneshot | full
review: quick            # none | quick | thorough
risk_tier: GREEN         # GREEN | YELLOW | RED
baseline_revision: <git rev-parse HEAD at start>
decision_log: docs/decision-log/<YYYY-MM-DD>-<slug>.md
specs: []                # e.g. docs/app-map/ba-spec-orders.md, docs/app-map/design-spec.md
---

# <Title>

## Intent (frozen after approval)

> <the user's request, verbatim>

Interpretation: <one line>

## Why

<the problem in one or two sentences>

## Capabilities

- **C-1** intent: <what, not how> · success: <observable check>
- **C-2** intent: ... · success: ...

## Acceptance

- AC-1 (C-1): **Given** <state> **When** <action> **Then** <observable result>
- Or cite ba-spec IDs: `ba-spec-<x>.md#AC-3`

## Constraints

- <a constraint that rules something out>

## Non-goals

- <at least one thing this work will not do>

## Context (read first)

- `<path>` — <why>

## Tasks

1. `<path>` — <concrete action>
2. `<path>` — <concrete action>

## Verification

- `<command>` — <what it proves>

## Open questions / Assumptions

- <question or assumption, with the default taken if YELLOW>

## Change log

<!-- Append-only. One entry per amendment: trigger, what changed, what to keep. -->

## Review triage

<!-- One row per finding: lens | location | verdict | route | evidence -->
