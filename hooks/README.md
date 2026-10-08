# Opt-in hooks

Atelier installs **no** hooks. Everything here is opt-in, and you wire it up yourself.

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
