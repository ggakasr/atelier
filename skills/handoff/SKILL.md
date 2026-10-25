---
name: handoff
description: "Compact the current conversation into a handoff document so a fresh agent can continue the work. Use when the user asks for a handoff, to hand over, summarise for the next session, or is about to end or reset a long session."
argument-hint: "What will the next session be used for?"
---

> **Atelier notes** (English, added by atelier)
> - **Source.** Adapted from mattpocock/skills (MIT); see `LICENSE-mattpocock.md`. The body below is upstream, unchanged.
> - **Who runs it.** The main session is the foreman: heavy steps (reading the repo and git state) go to `builder` (sonnet, medium), or `explorer` (haiku, low) for read-only digging; the main session relays short reports.
> - **Related atelier skills.** `decision-log` for the append-only record of decisions the handoff should point to.

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) - not the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
