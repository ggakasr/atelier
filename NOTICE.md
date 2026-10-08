# NOTICE

Atelier combines material and ideas from the projects below. This file keeps their
license notices and credits.

## 1. ai-simple (text copied and adapted)

- Source: ai-simple by Long (Long-Forfun), reference commit `eeb1b66` (2026-08-18).
- What atelier copies: the skills `ba-flow-logic`, `ui-design-logic`, `ui-ux-triage` and
  `security-logic` (SKILL.md, references, templates, `*-verify.sh`, `ui-lane.sh`,
  `finding-parser.awk`); the Vietnamese core text in `atelier-core` (taken from
  `ai-simple-product-dev`); `methodology/` 01-08, 11, 12, 14 and 15; the `router` agent body (from
  `context-router`); the project-template `CLAUDE.md` (from `CLAUDE.tiny.md.template`) and
  `ADR-template.md`; and `hooks/git-guard.sh` (from `pretooluse-git-guard.sh`).
- Atelier changes: merged skill descriptions (including trigger and handoff wording from the
  user's earlier local copies), English "Atelier notes" blocks, slimming, and removal of
  CLI-dependent parts. Removed: evals, Codex agent files, `research/`, the Node CLI, CI, and
  the large hook template.

```
MIT License

Copyright (c) 2026 Long (Long-Forfun)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Ideas that ai-simple credits (passed on here)

ai-simple's own NOTICE says that some of its rules are rewritten ideas, not copied text, from:

| Code | Project | License | What it inspired |
|---|---|---|---|
| `PT-*` | Ponytail, github.com/DietrichGebert/ponytail | MIT | The anti-over-engineering decision ladder, the do-not-cut guardrails, and debt markers with an upgrade condition (methodology 15) |
| `HM-*` | Hallmark, github.com/Nutlope/hallmark | MIT | Universal anti-AI-slop UI gates (ui-design-logic 06 §2 and 02/03/04) |
| `IMP-*` | Impeccable, github.com/pbakaus/impeccable | Apache-2.0 | Undeclared-token gate, semantic HTML, browser surfaces, audience-based screen type, transform/opacity-only motion (ui-design-logic 01 §7, 04) |

## 2. BMAD-METHOD (ideas only, no text copied)

- Source: BMAD-METHOD by BMad Code, LLC, reference commit `bda3c59` (2026-10-06).
- Atelier's `review-lenses`, `decision-log`, `work-order`, `course-correct` and `elicit` skills
  are **inspired by BMAD-METHOD**. They rewrite these ideas in atelier's own words: review
  lenses (adversarial, edge-case hunter, verification-gap, "zero findings is valid"), the
  append-only per-run memory log plus addendum, build route selection and review depth, the
  spec kernel as a handoff contract, the correct-course checklist, and the elicitation method
  menu. No BMAD scripts, runtime, templates or prose are included.
- **Trademark disclaimer:** BMad™, BMad Method™ and BMad Core™ (all casings and variations,
  including BMAD, bmad and BMAD-METHOD) are trademarks of BMad Code, LLC. Atelier is not
  affiliated with or endorsed by BMad Code, LLC. The name appears here only to attribute the
  source of ideas, and atelier uses none of these marks in any skill, agent, folder or title.

```
MIT License

Copyright (c) 2025 BMad Code, LLC

This project incorporates contributions from the open source community.
See [CONTRIBUTORS.md](CONTRIBUTORS.md) for contributor attribution.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

TRADEMARK NOTICE:
BMad™, BMad Method™, and BMad Core™ are trademarks of BMad Code, LLC, covering all
casings and variations (including BMAD, bmad, BMadMethod, BMAD-METHOD, etc.). The use of
these trademarks in this software does not grant any rights to use the trademarks
for any other purpose. See [TRADEMARK.md](TRADEMARK.md) for detailed guidelines.
```

## 3. Atelier

Atelier's own content (README, the new skills, agents, installers, templates) is © 2026
ggakasr under the MIT License in `LICENSE`.
