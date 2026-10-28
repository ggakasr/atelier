#!/usr/bin/env node
// atelier: merge helpers used by the installers (needs only node). Idempotent; always backs up first.
//   node wire.js claude-md <target CLAUDE.md> <block file>   replace/insert the atelier block
//   node wire.js agents-md <target AGENTS.md> <block file>   same, for the Codex-style ~/AGENTS.md
//   node wire.js settings <settings.json>                   register the atelier hooks
const fs = require('fs');
const [, , cmd, target, blockFile] = process.argv;
const BEGIN = '<!-- atelier:begin', END = '<!-- atelier:end -->';

function backup(file) {
  if (fs.existsSync(file)) fs.copyFileSync(file, `${file}.atelier-bak-${Date.now()}`);
}

function mergeClaudeMd() {
  const src = fs.readFileSync(blockFile, 'utf8').trim();
  // fresh install gets the whole file; otherwise only the marked block is merged, so your own sections stay yours
  const sb = src.indexOf(BEGIN), se = src.indexOf(END);
  const exists = fs.existsSync(target) && fs.readFileSync(target, 'utf8').trim();
  const block = exists && sb !== -1 && se > sb ? src.slice(sb, se + END.length) : src;
  let cur = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : '';
  const b = cur.indexOf(BEGIN), e = cur.indexOf(END);
  if (b !== -1 && e > b) {
    cur = cur.slice(0, b) + block + cur.slice(e + END.length);
  } else {
    // first merge: drop the old unmarked "## Atelier workflow" section, keep everything else
    cur = cur.replace(/^## Atelier workflow[^\n]*\n[\s\S]*?(?=^## |(?![\s\S]))/m, '');
    cur = cur.replace(/\s+$/, '') + (cur.trim() ? '\n\n' : '') + block;
  }
  backup(target);
  fs.writeFileSync(target, cur.replace(/\s+$/, '') + '\n');
  console.log(`merged atelier block into ${target}`);
}

function mergeAgentsMd() {
  // same marked block as CLAUDE.md, merged into a Codex-style AGENTS.md; text outside the markers is never touched
  const src = fs.readFileSync(blockFile, 'utf8');
  const sb = src.indexOf(BEGIN), se = src.indexOf(END);
  if (sb === -1 || se < sb) { console.error(`no atelier block markers in ${blockFile}`); process.exit(1); }
  const block = src.slice(sb, se + END.length);
  let cur = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : '';
  const b = cur.indexOf(BEGIN), e = cur.indexOf(END);
  if (b !== -1 && e > b) {
    cur = cur.slice(0, b) + block + cur.slice(e + END.length);
  } else if (/^## Atelier workflow/m.test(cur)) {
    // one-time migration of an unmarked file: the old section runs up to "## Code discipline" (or the end)
    cur = cur.replace(/^## Atelier workflow[^\n]*\n[\s\S]*?(?=^## Code discipline|(?![\s\S]))/m, () => block + '\n\n');
  } else {
    cur = cur.replace(/\s+$/, '') + (cur.trim() ? '\n\n' : '') + block;
  }
  backup(target);
  fs.writeFileSync(target, cur.replace(/\s+$/, '') + '\n');
  console.log(`merged atelier block into ${target}`);
}

function wireSettings() {
  const s = fs.existsSync(target) ? JSON.parse(fs.readFileSync(target, 'utf8')) : {};
  s.hooks = s.hooks || {};
  const add = (event, matcher, command) => {
    const list = (s.hooks[event] = s.hooks[event] || []);
    const key = command.split('/').pop();
    if (list.some(g => (g.hooks || []).some(h => (h.command || '').includes(key)))) return;
    const group = { hooks: [{ type: 'command', command }] };
    if (matcher) group.matcher = matcher;
    list.push(group);
  };
  // older installs registered the sh version of skill-router: swap that command for the node one in place
  const migrate = (event, oldKey, command) => {
    for (const g of s.hooks[event] || []) for (const h of g.hooks || []) if ((h.command || '').includes(oldKey)) h.command = command;
  };
  migrate('UserPromptSubmit', 'skill-router.sh', 'node ~/.claude/hooks/skill-router.js');
  add('UserPromptSubmit', null, 'node ~/.claude/hooks/skill-router.js');
  add('SessionStart', null, 'sh ~/.claude/hooks/skill-gap.sh');
  add('PostToolUse', null, 'sh ~/.claude/hooks/foreman-nudge.sh');
  add('PreToolUse', 'Bash', 'sh ~/.claude/hooks/git-guard.sh');
  backup(target);
  fs.writeFileSync(target, JSON.stringify(s, null, 2) + '\n');
  console.log(`atelier hooks registered in ${target}`);
}

if (cmd === 'claude-md' && target && blockFile) mergeClaudeMd();
else if (cmd === 'agents-md' && target && blockFile) mergeAgentsMd();
else if (cmd === 'settings' && target) wireSettings();
else { console.error('usage: wire.js claude-md <target> <block> | agents-md <target> <block> | settings <settings.json>'); process.exit(2); }
