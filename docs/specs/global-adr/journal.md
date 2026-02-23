---
afx: true
type: JOURNAL
status: Living
tags: [global-adr, journal]
---

# Journal - global-adr

<!-- prefix: GA -->

> Quick captures and discussion history.
> NOTE: This is an append-only log. All architectural decisions, failed experiments, and historical context go here.

## Captures

<!-- Cleared — covered by GA-D001 -->

---

## Discussions

### GA-D001 - 2026-02-24 - Global ADR Implementation & afx-init Integration

`[adr, framework, afx-init, dogfooding, architecture]`

**Context**: Session began with setting up AFX to dogfood on itself. User proposed adding a global folder for ADRs and cross-cutting content not tied to individual specs. Evolved into full implementation of `docs/adr/` support including the `/afx:init adr` subcommand.

**Summary**: Implemented first-class `docs/adr/` support for AFX. Evaluated naming options (`_project`, `_global`, `_shared`, `decisions`, `adr`) — chose `docs/adr/` as the industry standard (Nygard convention, `adr-tools`). Created ADR-0001 (self-referential), scaffolded the `global-adr` feature spec, and added the `adr` subcommand to `/afx:init`.

**Decisions**:

- Global ADRs live at `docs/adr/` (industry standard path)
- Numbering format: `ADR-NNNN-kebab-slug.md` (zero-padded 4 digits)
- `/afx:init adr <title>` generates **real content** via Write tool, not placeholder templates
- Config uses `paths.adr` field in `.afx.yaml` with `docs/adr` default
- `afx-init.md` gains `## Configuration` block matching other command patterns

**Tips/Ideas**:

- Bash heredoc scripts in commands cause agents to output blank templates — use Write tool instructions instead
- The `## Configuration` block with "Read `.afx.yaml`..." is the established pattern across all AFX commands
- Test commands via `unset CLAUDECODE && claude -p "/afx-init ..." --allowedTools '...'` from `tmp/`

**Key Artifacts**:

- [ADR-0001](../../adr/ADR-0001-global-adr-directory.md) — The decision record
- [afx-init.md](../../../.claude/commands/afx-init.md) — Updated with `## 5. adr` subcommand
- [design.md](design.md) — Full `/afx:init` change spec
- [tasks.md](tasks.md) — Phase 0 complete, Phase 1 tasks 1.3-1.4 complete

**Participants**: @rix, Claude

---

## Work Sessions

| Date       | Task          | Action                           | Files Modified                                                       | Agent | Human |
| ---------- | ------------- | -------------------------------- | -------------------------------------------------------------------- | ----- | ----- |
| 2026-02-24 | Phase 0 (all) | Scaffolded ADR dir + config      | .afx.yaml, ADR-0001, feature spec                                    | [OK]  | [OK]  |
| 2026-02-24 | 1.3, 1.4      | Added adr subcommand to afx-init | afx-init.md, design.md                                               | [OK]  | [OK]  |
| 2026-02-24 | Phase 0-1     | VERIFIED                         | Tested /afx:init adr in tmp/, generates real content                 | [OK]  | [OK]  |
| 2026-02-24 | 3.1-3.3       | Phase 3 Documentation complete   | agenticflowx.md, cheatsheet.md, CLAUDE.md                            | [OK]  | -     |
| 2026-02-24 | 3.1-3.3       | VERIFIED                         | Docs reviewed: prompts/, .afx.yaml.template, install.sh also updated | [OK]  | [OK]  |
