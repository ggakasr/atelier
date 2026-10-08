# Methodology index (atelier subset)

These principle files come from ai-simple and are kept in their original language (mostly Vietnamese,
with English headings). They are reference material that skills load on demand. They are not rules
the agent has to load every session.

| # | File | Status in atelier |
|---|---|---|
| 01 | [Hierarchical context](01-hierarchical-context.md) | Active |
| 02 | [App-map pattern](02-app-map-pattern.md) | Active (scale it down for small repos) |
| 03 | [Context routing](03-context-routing.md) | Active, through the `router` agent |
| 04 | [Doc + test sync](04-doc-test-sync.md) | Active |
| 05 | [LOGIC vs REQUEST](05-logic-vs-request.md) | Active |
| 06 | [Pre-flight checklist / risk tiers](06-pre-flight-checklist.md) | Active |
| 07 | [Memory as feedback](07-memory-as-feedback.md) | Active (Claude Code memory) |
| 08 | [Automated enforcement](08-automated-enforcement.md) | Reference only. Atelier ships only the opt-in hooks in `hooks/` and the per-skill `*-verify.sh` linters |
| 11 | [Ops layer](11-ops-layer.md) | Active when a project has background processes |
| 12 | [Self-optimization](12-self-optimization.md) | Partly active: the coupling map and verify-on-use read gate. Loops B and C assume upstream tooling |
| 14 | [Security gate](14-security-gate.md) | Active, through `security-logic` |
| 15 | [Build discipline](15-build-discipline.md) | Active |

Not shipped: 09 (generated vs authored docs), 10 (cross-repo contracts) and 13 (git-native parallel
sessions). They depend on the ai-simple Node CLI. For those, see upstream ai-simple.

Mentions of `npx ai-simple ...`, `doctor`, `doc-health-report`, `/audit` or hook items such as `1d`/`1e`/`1f`
in these files refer to upstream tooling that atelier does not install.
