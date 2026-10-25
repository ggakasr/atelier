# atelier

A lean, personal Claude Code setup for one developer.

In a workshop the master sets the direction and the apprentices do the work, each one matched
to a job that fits their skill. Atelier applies the same idea to Claude Code:

- **You are the master.** You decide what to build and approve anything irreversible.
- **The main session is the foreman.** It classifies requests, routes context, writes briefs,
  triages results and reports back.
- **Subagents are the apprentices.** Each gets a self-contained brief and runs at the
  cheapest model and effort that can do the job well.

Atelier merges two upstream projects. From **ai-simple** it takes risk tiers, minimal context
routing, the ba-spec acceptance criteria used as the behaviour oracle, doc/code drift
awareness, the BA → design → build → triage pipeline and the cross-cutting security review.
From **BMAD-METHOD** it takes ideas only: review lenses, a per-task decision log, build
routes, the spec as a handoff contract, course correction and elicitation. Everything is
plain Markdown plus two small installers. There is no Node CLI and no CI.

## Workflow

```
                         you (master): intent, approvals
                                   │
                                   ▼
  ┌──────────────── main session (foreman) · skill: atelier-core ────────────────┐
  │ LOGIC or REQUEST? → router (haiku) lists context → risk tier GREEN/YELLOW/RED │
  └───────────────────────────────────────────────────────────────────────────────┘
          │ vague need                │ needs UI                   │ clear change
          ▼                           ▼                            │
   ba-flow-logic ──ba-spec──►  ui-design-logic ──design-spec──┐    │
   (AC = behaviour oracle)     (architect, opus)              │    │
                                                              ▼    ▼
                                    work-order  (kernel + route + review depth)
                                       │ oneshot (≤~100 lines) │ full (written work order)
                                       ▼                       ▼
                                    builder (sonnet) ── code + tests + docs
                                       │
                                       ▼
                     review-lenses: none | quick | thorough (reviewer, sonnet/opus)
                                       │ triage: patch → builder · plan flaw → amend
                                       │         intent gap → ask you · defer → list
                                       ▼
                                     done ──► app misbehaves later? ui-ux-triage
                                                (reads both oracles, only RED reaches you)

  Cross-cutting:  security-logic (any stage) · decision-log (append-only, every
                  non-trivial task) · course-correct (plan broke) · elicit (pressure-test)
  Reverse handoffs: triage, design or security find the spec wrong → back to ba-flow-logic
```

**Risk tiers** (from ai-simple principle 06):

- **GREEN.** Git can undo it. Proceed without asking.
- **YELLOW.** Undo needs a prepared step, such as a down migration or a flag. Do the safe
  version and list it under `## Assumptions`.
- **RED.** Irreversible, or it breaks production. Stop and ask exactly **one** combined
  question with a recommended option. Keep doing the non-RED parts of the task meanwhile.

**Authority is a separate axis.** Something can be easy to undo and still need your explicit
OK: installs, external messages, publish/deploy, push, or reading production data.

## Skills

| Skill | Origin | Who runs it (model, effort) |
|---|---|---|
| `atelier-core` | ai-simple `ai-simple-product-dev`, slimmed, plus new English sections | Main session (inline) |
| `ba-flow-logic` | ai-simple upstream + your local trigger/handoff wording | Main session leads; `architect` (opus, high) for flow optimization; `explorer` (haiku, low) for lookup |
| `ui-design-logic` | ai-simple upstream + your local trigger wording | `architect` (opus, high) for the spec; `builder` (sonnet, low–medium) builds; `reviewer` (sonnet, medium) for screenshot QA |
| `ui-ux-triage` | ai-simple upstream + your local description | Main session as Lead; Fixer `builder` (sonnet, medium); Advisor `architect` (opus, high) |
| `security-logic` | ai-simple upstream | `reviewer`: opus/high on auth, payment, crypto or migrations; sonnet/medium otherwise |
| `work-order` | new, inspired by BMAD-METHOD | Main session writes it (`architect` for complex work); `builder` executes |
| `review-lenses` | new, inspired by BMAD-METHOD | One `reviewer` per lens: sonnet/medium for quick, opus/high for thorough |
| `decision-log` | new, inspired by BMAD-METHOD | Whoever does the work (no subagent) |
| `course-correct` | new, inspired by BMAD-METHOD | `architect` (opus, high); main session asks you |
| `elicit` | new, inspired by BMAD-METHOD | Main session inline; `architect` (opus, high) for heavy methods |
| `mkn-xu-ly-task` (in `personal/`) | your own project skill, unchanged | As written in the skill |

Each SKILL.md states its delegation in its body. Atelier deliberately does **not** set `model:`
in skill frontmatter. That field switches the model of the main session while the skill is
active, but atelier's model choice belongs to the subagent that runs the work.

Naming: the four ai-simple skills keep their upstream names, so installing atelier replaces
your older local copies in place (after a backup) instead of creating duplicates. New skills
use short, plain kebab-case names that say what the skill does.

## Agents

All five live in `agents/` and use the standard Claude Code subagent frontmatter: `name`,
`description`, `tools`, `model` and `effort`.

| Agent | Model | Effort | Tools | Job |
|---|---|---|---|---|
| `router` | haiku | low | Read, Glob, Grep | Lists the context `.md` files to read and scores the risk tier (ai-simple `context-router`) |
| `explorer` | haiku | low | Read, Glob, Grep | Read-only lookup with `path:line` evidence |
| `builder` | sonnet | medium | Read, Edit, Write, Glob, Grep, Bash | Implements a work order. Stops at RED; no commits unless the brief grants them |
| `reviewer` | sonnet | medium | Read, Glob, Grep, Bash (read-only) | Runs exactly one lens and returns findings only |
| `architect` | opus | high | Read, Glob, Grep, Write, Edit, Bash (read-only) | Work orders, design-specs, ADRs, course corrections. Writes no production code |

The foreman may override the model or effort for a single call. Typical overrides:
`builder` at low for mechanical edits or high for multi-module work, and `reviewer` at
opus/high for thorough or security reviews.

## Layout

```
atelier/
├── README.md · NOTICE.md · LICENSE · .gitignore · .gitattributes
├── install.ps1 · install.sh        install into ~/.claude with timestamped backups
├── global/CLAUDE.md                atelier block (workflow + skill-routing table), merged into CLAUDE.md
├── skills/<name>/SKILL.md          14 skills (+ references/, templates/, opt-in *-verify.sh)
├── personal/mkn-xu-ly-task/        project-specific skill, installed unless --no-personal
├── agents/*.md                     router, explorer, builder, reviewer, architect
├── hooks/                          skill-router (UserPromptSubmit) + git-guard (PreToolUse) + wire.js
└── project-template/               drop into a new repo: CLAUDE.md (tiny) + docs/
    └── docs/ app-map/ · work-orders/ · decision-log/ · decisions/
```

Why this layout differs a little from the original plan:

- `personal/` keeps project-specific skills apart from the reusable ones. The installer still
  installs them, and you can skip them with `--no-personal` / `-NoPersonal`.
- `hooks/` is a separate folder, so nothing in it can be mistaken for something the installer
  wires up.
- `project-template/docs/app-map/` exists because the ai-simple skills and their linters look
  for `ba-spec`, `design-spec` and `security-review` files there.

## Install

```powershell
# Windows PowerShell
.\install.ps1 -DryRun          # preview
.\install.ps1                  # install
.\install.ps1 -NoPersonal -NoClaudeMd
```

```bash
# macOS / Linux / Git Bash
./install.sh --dry-run
./install.sh
./install.sh --no-personal --no-claude-md --claude-home /path/to/.claude
```

The installer copies `skills/*` and `personal/*` to `~/.claude/skills/<name>/`, `agents/*.md`
to `~/.claude/agents/` and `hooks/*` to `~/.claude/hooks/`. `global/CLAUDE.md` is merged, not
copied: only the block between the `atelier:begin/end` markers is replaced, the rest of your
`CLAUDE.md` stays. Before it replaces anything, it copies the old version to
`~/.claude/atelier-backups/<yyyyMMdd-HHmmss>/`. It removes nothing else. It edits
`settings.json` only with `--wire-hooks` / `-WireHooks`, which registers skill-router and
git-guard (needs node). Restart Claude Code
afterwards so it picks up the new agents.

To start a project, copy `project-template/` into the repo root, fill the `{{...}}` blanks in
`CLAUDE.md`, and delete the doc folders you don't need.

## Hooks and extras

- `hooks/skill-router.js`: a UserPromptSubmit hook that spots what a request is about and tells the
  model which skill to invoke (e.g. "UI/UX needs improvement" -> `ui-design-logic`). The routing
  table in `global/CLAUDE.md` does the same from the model's side.
- `hooks/git-guard.sh`: a PreToolUse hook that blocks `git reset`, `git stash`, `git restore`
  and `git checkout -- <path>`, so your uncommitted work is safe. See `hooks/README.md`.
- `*-verify.sh` inside four of the skills: read-only POSIX linters for spec docs, which you
  can wire into a project's pre-commit hook. On Windows they run under Git Bash.

## Not included (and why)

- **ai-simple's Node CLI, CI workflows, the 1000-line pre-commit hook, `/fl` `/audit` `/learn`
  commands, evals, and principles 09, 10 and 13.** They are heavy, need the CLI, or target
  teams. Claude Code's skills and worktrees cover the solo case.
- **BMAD's runtime, Python scripts, ticket tree, persona menus, party mode, toolsmith and
  i18n.** Atelier keeps only the ideas listed above, rewritten.
- **ai-simple's `ui-design-logic/research/` calibration notes and Codex agent files.**
  Nothing in the skills references them.

## Credits

- **ai-simple** © 2026 Long (Long-Forfun), MIT. Most of the Vietnamese skill text and the
  methodology come from it, along with the ideas it credits to Ponytail, Hallmark and Impeccable.
- **BMAD-METHOD** © 2025 BMad Code, LLC, MIT. The five new skills are inspired by it. BMad™
  and BMAD-METHOD™ are trademarks of BMad Code, LLC, and atelier is not affiliated with it.

Full notices are in [NOTICE.md](NOTICE.md). Atelier itself is © 2026 ggakasr, MIT, see [LICENSE](LICENSE).
