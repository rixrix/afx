# AFX Frontmatter Schema

> Add this section to your CLAUDE.md to document the frontmatter schema for AFX documents.

### AFX Frontmatter Schema

All AFX-managed files use YAML frontmatter to support external tooling and metadata queries. The `afx: true` marker identifies AFX-owned documents.

**Full Schema (SPEC, DESIGN, TASKS):**

```yaml
---
afx: true # AFX ownership marker (required)
type: SPEC # Document type (required)
status: Draft # Draft | Approved | Living
owner: "@handle" # GitHub handle
priority: High # High | Medium | Low (SPEC only)
version: 1.0 # Semantic versioning
created: YYYY-MM-DDTHH:MM:SSZ # ISO 8601 creation timestamp
last_verified: YYYY-MM-DD # Last review date
tags: [feature, topic] # Content tags (Obsidian convention)
---
```

**Minimal Schema (COMMAND, JOURNAL):**

```yaml
---
afx: true
type: COMMAND
status: Living
tags: [afx, command, topic]
---
```

**Research Schema (RES, ADR):**

```yaml
---
afx: true
id: 0001 # Optional numbered ID
type: RES # RES | ADR
status: Approved # Draft | Approved | Deprecated
owner: "@handle"
date: YYYY-MM-DD # Decision/creation date
tags: [topic1, topic2]
---
```

**Document Types:**

| Type      | Purpose               | Location                            |
| --------- | --------------------- | ----------------------------------- |
| `SPEC`    | Feature specification | docs/specs/{feature}/spec.md        |
| `DESIGN`  | Technical design      | docs/specs/{feature}/design.md      |
| `TASKS`   | Implementation tasks  | docs/specs/{feature}/tasks.md       |
| `JOURNAL` | Session log           | docs/specs/{feature}/journal.md     |
| `RES`     | Research/exploration  | docs/specs/{feature}/research/\*.md |
| `ADR`     | Architecture decision | docs/specs/{feature}/research/\*.md |
| `COMMAND` | AFX slash command     | .claude/commands/afx-\*.md          |
