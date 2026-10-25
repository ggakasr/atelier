#!/bin/sh
# atelier: OPT-IN SessionStart hook. Lists skills installed in ~/.claude/skills that have no row in the
# routing table (CLAUDE.md) and no keyword in skill-router.js, so a new skill can be wired in right away.
# Claude Code adds hook stdout to the model's context. Silent when nothing is missing; always exit 0.
set -u
H="${CLAUDE_HOME:-$HOME/.claude}"
[ -d "$H/skills" ] || exit 0

missing=""
for d in "$H"/skills/*/; do
  [ -f "${d}SKILL.md" ] || continue
  n=$(basename "$d")
  grep -qF "\`$n\`" "$H/CLAUDE.md" 2>/dev/null && continue
  grep -qF "'$n'" "$H/hooks/skill-router.js" 2>/dev/null && continue
  missing="$missing $n"
done

missing=$(echo $missing | sed 's/ /, /g')
[ -n "$missing" ] && echo "[skill-gap] Installed skills with no routing row or keyword: $missing. Offer once, in one line, to add them to the atelier repo (global/CLAUDE.md table + hooks/skill-router.js keywords) and reinstall. Wait for my yes."
exit 0
