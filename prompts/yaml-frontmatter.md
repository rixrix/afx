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
version: "1.0" # Semantic versioning (quoted string)
created_at: YYYY-MM-DDTHH:MM:SS.mmmZ # ISO 8601 creation timestamp (millisecond precision)
updated_at: YYYY-MM-DDTHH:MM:SS.mmmZ # Last review timestamp (millisecond precision)
tags: [feature, topic] # Content tags (Obsidian convention)
---
```

**Minimal Schema (JOURNAL):**

```yaml
---
afx: true
type: JOURNAL
status: Living
owner: "@handle"
created_at: YYYY-MM-DDTHH:MM:SS.mmmZ
updated_at: YYYY-MM-DDTHH:MM:SS.mmmZ
tags: [feature, journal]
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
version: "1.0"
created_at: YYYY-MM-DDTHH:MM:SS.mmmZ # Decision/creation timestamp (millisecond precision)
updated_at: YYYY-MM-DDTHH:MM:SS.mmmZ
tags: [topic1, topic2]
---
```

**Document Types:**

| Type      | Purpose               | Location                                                     |
| --------- | --------------------- | ------------------------------------------------------------ |
| `SPEC`    | Feature specification | docs/specs/{feature}/spec.md                                 |
| `DESIGN`  | Technical design      | docs/specs/{feature}/design.md                               |
| `TASKS`   | Implementation tasks  | docs/specs/{feature}/tasks.md                                |
| `JOURNAL` | Session log           | docs/specs/{feature}/journal.md                              |
| `RES`     | Research/exploration  | docs/specs/{feature}/research/\*.md                          |
| `ADR`     | Architecture decision | docs/adr/ (global) or docs/specs/{feature}/research/ (local) |
