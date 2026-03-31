---
name: afx-init
description: Feature scaffolding — create spec directories and generate ADRs
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,init,scaffolding,feature,adr"
  afx-argument-hint: "feature | adr"
---

# /afx-init

Feature spec scaffolding and ADR creation for AgenticFlowX projects.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.adr` - Where global ADRs live (default: `docs/adr`)
- `paths.templates` - Where templates live (default: `docs/agenticflowx/templates`)

If neither file exists, use defaults.

## Usage

```bash
/afx-init feature <name>   # Create new feature spec directory
/afx-init adr <title>      # Create numbered ADR in docs/adr/
```

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace
- Create new directories and markdown files in:
  - `docs/specs/` (feature scaffolding)
  - `docs/adr/` (ADR creation)

### Forbidden

- Create/modify/delete source code in application directories
- Modify existing spec content (only scaffolds new empty specs)
- Delete any files or directories
- Run build/test/deploy/migration commands
- Modify `.afx.yaml` or `.afx/` configuration

If implementation is requested, respond with:

```text
Out of scope for /afx-init (scaffolding mode). Use /afx-dev code after spec approval.
```

---

### Timestamp Format (MANDATORY)

All timestamps MUST use ISO 8601 with millisecond precision: `YYYY-MM-DDTHH:MM:SS.mmmZ` (e.g., `2025-12-17T14:30:00.000Z`). Never write short formats like `2025-12-17 14:30`.

### Proactive Journal Capture

When this skill detects a high-impact context change, auto-capture to `journal.md` per the [Proactive Capture Protocol](../afx-session/SKILL.md#proactive-capture-protocol-mandatory).

**Triggers for `/afx-init`**: Feature scope decision during scaffolding.

## Post-Action Checklist (MANDATORY)

After scaffolding any new feature or artifact, you MUST:

1. **Canonical Frontmatter**: All generated files use the canonical schema — `afx → type → status → owner → version → created_at → updated_at → tags → [backlinks]`. Double quotes for all string values. `version` quoted as `"1.0"`.
2. **Full Spec Body**: `spec.md` must contain ALL template sections (Problem Statement, User Stories, FR/NFR tables, Acceptance Criteria, Non-Goals, Open Questions, Dependencies). Do NOT generate a stripped-down skeleton.
3. **Node IDs in Design**: `design.md` scaffold must include `[DES-ID]` prefixes on all `##` headings.
4. **Timestamps**: Use current ISO 8601 with millisecond precision for `created_at` and `updated_at`. Never use midnight timestamps.
5. **Feature Registration**: If `.afx.yaml` has a `features` list, register the new feature.

---

## Agent Instructions

### Next Command Suggestion (MANDATORY)

After EVERY `/afx-init` action, suggest the most appropriate next command:

| Context             | Suggested Next Command                         |
| ------------------- | ---------------------------------------------- |
| After `feature`     | `/afx-spec validate <name>` to review scaffold |
| After `adr` created | Edit `docs/adr/ADR-NNNN-*.md` to fill content  |

---

## Subcommands

---

## 1. feature

Create a new feature spec directory with all four artifact files.

### Usage

```bash
/afx-init feature <name>
```

`<name>` must be kebab-case (e.g., `user-authentication`, `shopping-cart`).

### Process

1. **Validate name**: Must be kebab-case. Error if not.
2. **Check existence**: If `docs/specs/<name>/` already exists, stop with error.
3. **Confirm with user**: Show the file list below and wait for confirmation before creating anything.
4. **Create files** using the **Write tool** — read each canonical template from `docs/agenticflowx/templates/` and substitute:
   - `{Feature Name}` → Title-cased name (e.g., `user-auth` → `User Auth`)
   - `{feature}` → the kebab-case name
   - `{YYYY-MM-DDTHH:MM:SS.mmmZ}` → current ISO 8601 timestamp (both `created_at` and `updated_at`)
   - `@owner` → `@handle`
   - `<!-- prefix: XX -->` in journal.md → auto-derived: take the first letter of each hyphen-separated word, uppercase (e.g., `user-auth` → `UA`, `shopping-cart` → `SC`). For single-word names, use the first two letters.
5. **Create `research/`** subdirectory (empty).

**Files created:**

```
docs/specs/<name>/
├── spec.md      — from docs/agenticflowx/templates/spec-template.md
├── design.md    — from docs/agenticflowx/templates/design-template.md
├── tasks.md     — from docs/agenticflowx/templates/tasks-template.md
├── journal.md   — from docs/agenticflowx/templates/journal-template.md
└── research/    — empty directory
```

### Output

```
Feature scaffolded: docs/specs/{name}/

  spec.md      — define requirements here first
  design.md    — technical architecture
  tasks.md     — implementation tasks
  journal.md   — discussion capture (prefix: {XX})
  research/    — ADRs and research notes

Next: /afx-spec validate {name}
```

---

## 2. adr

Create a global architecture decision record in `docs/adr/`.

### Usage

```bash
/afx-init adr <title>
```

`<title>` is a short noun phrase (e.g., `"database choice"`, `"api versioning strategy"`). Gets kebab-cased into the filename slug.

### Process

1. Read `paths.adr` from `.afx.yaml` (default: `docs/adr`)
2. Use **Glob** to scan `docs/adr/ADR-*.md` for the highest existing `ADR-NNNN` number
3. Increment → next number, zero-padded to 4 digits
4. Slugify title → kebab-case
5. Read `docs/agenticflowx/templates/adr.md` for the file structure and frontmatter format
6. **Generate real content** using the Write tool — use the title to write a meaningful first draft:
   - **Context**: Describe the problem space and why this decision is needed now
   - **Decision**: State "To be decided" with the key options identified
   - **Rationale**: Leave as "Pending analysis"
   - **Consequences**: List likely trade-offs for each option being considered
   - **Alternatives Considered**: List 2-3 concrete alternatives relevant to the title
7. Write `docs/adr/ADR-{NNNN}-{slug}.md` with the generated content

**IMPORTANT**: Do NOT copy the template with `{placeholder}` text. Generate real, meaningful content for each section based on the ADR title and available project context.

### Output

```
ADR created: docs/adr/ADR-{NNNN}-{slug}.md

Next: Edit docs/adr/ADR-{NNNN}-{slug}.md to complete the decision
```

---

## Error Handling

**Feature already exists:**

```
Error: 'user-auth' already exists at docs/specs/user-auth/
Use a different name or work with the existing spec.
```

**Invalid name format:**

```
Error: Feature name must be kebab-case (lowercase with hyphens)
Example: /afx-init feature my-new-feature
```

**ADR title missing:**

```
Error: Title required
Usage: /afx-init adr <title>
Example: /afx-init adr "database choice"
```

---

## Related Commands

| Command              | Relationship                           |
| -------------------- | -------------------------------------- |
| `/afx-spec validate` | Check scaffold structure after feature |
| `/afx-spec review`   | Quality review before authoring        |
| `/afx-session note`  | Capture initial ideas in journal       |
| `/afx-check links`   | Verify spec cross-references           |
