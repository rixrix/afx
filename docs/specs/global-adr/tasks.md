---
afx: true
type: TASKS
status: Draft
owner: "@rix"
version: 1.0
tags: [global-adr, framework, tasks]
---

# Tasks: global-adr

## Phase 0: Foundation (done)

- [x] 0.1 Create `docs/adr/` directory structure
- [x] 0.2 Write ADR-0001 (self-referential decision record)
- [x] 0.3 Add `paths.adr` to `.afx.yaml`

## Phase 1: Core Integration

- [x] 1.1 Update `.afx.yaml.template` with `paths.adr` field and docs
- [x] 1.2 Update `afx-cli` to create `docs/adr/` in target projects
- [x] 1.3 Add `adr <title>` subcommand to `/afx-init` command
- [x] 1.4 Implement auto-increment numbering for ADR files

## Phase 2: Command Awareness

- [x] 2.1 Update `/afx-next` to surface Proposed ADRs needing review
- [x] 2.2 Update `/afx-context` to include ADRs in handoff bundles
- [x] 2.3 Update `/afx-discover` to report ADR count and recent decisions

## Phase 3: Documentation

- [x] 3.1 Update `docs/agenticflowx/agenticflowx.md` with ADR workflow
- [x] 3.2 Update `docs/agenticflowx/cheatsheet.md` with ADR commands
- [x] 3.3 Update `CLAUDE.md` with ADR references

---

## Work Sessions

<!-- Task execution log - updated by /afx-work next, /afx-dev code -->

| Date       | Task          | Action                           | Files Modified                                                       | Agent | Human |
| ---------- | ------------- | -------------------------------- | -------------------------------------------------------------------- | ----- | ----- |
| 2026-02-24 | Phase 0 (all) | Scaffolded ADR dir + config      | .afx.yaml, ADR-0001, feature spec                                    | [x]  | [x]  |
| 2026-02-24 | 1.3, 1.4      | Added adr subcommand to afx-init | afx-init.md, design.md                                               | [x]  | [x]  |
| 2026-02-24 | Phase 0-1     | VERIFIED                         | Tested /afx-init adr in tmp/, generates real content                 | [x]  | [x]  |
| 2026-02-24 | 3.1-3.3       | Phase 3 Documentation complete   | agenticflowx.md, cheatsheet.md, CLAUDE.md                            | [x]  | [ ]   |
| 2026-02-24 | 3.1-3.3       | VERIFIED                         | Docs reviewed: prompts/, .afx.yaml.template, afx-cli also updated   | [x]  | [x]  |
