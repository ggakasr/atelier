# Hooks

The installer copies these into `~/.claude/hooks/`. They only run once registered: pass
`--wire-hooks` (`-WireHooks` on Windows) to the installer, which merges them into
`~/.claude/settings.json` (backup made, safe to repeat). Or wire them yourself as shown below.

## skill-router.js (UserPromptSubmit)

Matches keywords in your prompt (English and Vietnamese) and adds a `[skill-router]` line to the
model's context naming the skills that fit, so e.g. "the UI/UX needs improvement" points at
`ui-design-logic`. It only suggests, never blocks. It is a node script (needs only node, starts in a fraction of a second). Test:
`node hooks/skill-router.js --self-test`. To add a keyword or skill, edit the `RULES` list in the
script (one `['skill', /regex/i],` per line, most specific first; the hint is capped at 3 skills).
Re-running the installer with `--wire-hooks` swaps an older `skill-router.sh` registration for this one.

## foreman-nudge.sh (PostToolUse)

Counts the main session's own tool calls (subagent calls, recognised by `agent_id`, are ignored).
After 8 in a row with no subagent call it adds a `[foreman]` reminder: delegate the next chunk.
A subagent call resets the count. Change the threshold with `ATELIER_FOREMAN_N`. It runs after
every tool call, so it adds a small delay per call. Test: `sh hooks/foreman-nudge.sh --self-test`.

## giveup-guard.sh (Stop)

Catches a final answer that gives up on a feasibility problem ("cannot be done", "too complex",
"không làm được", "quá phức tạp" ...) with no evidence, and blocks it once so the model tries other
approaches (skill `reframe`) before saying no. It blocks only when all three hold: a high-confidence
give-up phrase matches, the text has no evidence (code fence, "tried"/"đã thử" list, error quote,
`file:line`, "blocker"/"chặn ở"), and no safety marker (policy, unsafe, harmful, not allowed,
permission, malware, illegal, dangerous, "unable to help/assist", an toàn, bất hợp pháp, không thể giúp, chính sách, quyền and more; safety markers always win). Safety refusals are never touched.
Design: one retry only (`stop_hook_active` true or "true" => allow), replies under 30 characters are skipped
(change with `ATELIER_GIVEUP_MIN`; the work order's "<200" conflicted with its own 41-char acceptance example, so 30 is used), and it fails open: bad input, a missing node or a transcript it
cannot read all mean exit 0 with no output. It reads `last_assistant_message`, else the text of the LAST assistant entry in `transcript_path` (no text there => allow). Needs sh and node. Wired as a `Stop` hook by `--wire-hooks`.
Test: `bash scripts/selftest-giveup-guard.sh`.

## skill-gap.sh (SessionStart)

Lists skills installed in `~/.claude/skills` that have no row in the `CLAUDE.md` routing table and
no keyword in `skill-router.js`, so a skill you just added gets wired in. Silent when nothing is
missing. The model offers once to add the row and keywords in the repo, then you reinstall.

## git-guard.sh (PreToolUse, Bash)

This hook blocks the commands that destroy uncommitted user work: `git reset`, `git stash`,
`git restore`, and `git checkout -- <path>`. It still allows `git checkout -b`,
`git log --grep reset`, and similar commands. The source is ai-simple
(`templates/pretooluse-git-guard.sh`). The hook matches command strings, so it stops
accidents. It will not stop a deliberate workaround such as an alias or a wrapper script.

Requirements: a POSIX `sh`. On Windows, Claude Code runs hook commands through Git Bash, which
provides it.

1. Copy the file to `~/.claude/hooks/git-guard.sh` (all projects) or to
   `<repo>/.claude/git-guard.sh` (one project).
2. Add this to `~/.claude/settings.json` or `<repo>/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command", "command": "sh ~/.claude/hooks/git-guard.sh" } ] }
    ]
  }
}
```

3. Optional self-test: `sh ~/.claude/hooks/git-guard.sh --self-test`.

Exit code 2 denies the call and shows the reason to the agent. Input it cannot parse is allowed
through (fail-open).

## Skill linters (pre-commit, per project)

`ba-verify.sh`, `design-verify.sh`, `security-verify.sh` and `triage-verify.sh` ship inside
their skills. They are read-only POSIX linters for the spec docs in `docs/app-map/`. To enforce
them in a project, call them from that project's `.git/hooks/pre-commit` (or `.githooks/`):

```sh
#!/bin/sh
S="$HOME/.claude/skills"
sh "$S/ba-flow-logic/ba-verify.sh" --staged || exit 1
sh "$S/ui-design-logic/design-verify.sh" --staged || exit 1
sh "$S/security-logic/security-verify.sh" --staged || exit 1
```
