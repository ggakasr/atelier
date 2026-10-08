# App-map

Canonical docs that describe what the app does and how it should look. Each one carries
coupling frontmatter so drift between doc and code is visible:

```yaml
---
covers: [src/orders/, src/api/orders.ts]   # code this doc describes
last_verified: 2026-01-01                  # bump after checking claims against code
ttl_days: 90
---
```

Typical files (created by the atelier skills, numbered by domain as the repo grows):

- `ba-spec-<area>.md` — business flows + acceptance criteria (skill `ba-flow-logic`)
- `design-spec.md` — user ladder, screen map, state matrix (skill `ui-design-logic`)
- `security-review-<area>.md` — declared-coverage security review (skill `security-logic`)

See the `atelier-core` skill, methodology 02 and 12, for the full pattern.
