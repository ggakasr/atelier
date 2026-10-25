# Hooks

The installer copies these into `~/.claude/hooks/`. They only run once registered: pass
`--wire-hooks` (`-WireHooks` on Windows) to the installer, which merges them into
`~/.claude/settings.json` (backup made, safe to repeat). Or wire them yourself as shown below.

## skill-router.sh (UserPromptSubmit)

Matches keywords in your prompt (English and Vietnamese) and adds a `[skill-router]` line to the
model's context naming the skills that fit, so e.g. "the UI/UX needs improvement" points at
`ui-design-logic`. It only suggests, never blocks. Test: `sh hooks/skill-router.sh --self-test`.
To add a keyword or skill, edit the `route()` list in the script.

## skill-gap.sh (SessionStart)

Lists skills installed in `~/.claude/skills` that have no row in the `CLAUDE.md` routing table and
no keyword in `skill-router.sh`, so a skill you just added gets wired in. Silent when nothing is
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
