---
afx: true
type: TASKS
status: Draft
owner: "@rix"
version: 1.0
tags: [afx-update, tasks]
---

# Tasks: afx-update

## Phase 1: PRD Finalization

- [x] 1.1 Draft `spec.md` requirements (FR/NFR)
- [x] 1.2 Draft `design.md` command behavior and safety model
- [x] 1.3 Review and approve PRDs (spec/design/tasks)

## Phase 2: Command Implementation

- [x] 2.1 Create runtime skill file `.claude/skills/afx-update.md` (`check`, `apply`)
- [x] 2.2 Implement `check` execution steps in command markdown (bash + curl, read-only)
- [x] 2.3 Implement `apply` execution steps in command markdown (installer update flow + flags)
- [x] 2.4 Add agents skill `.agents/skills/afx-update/SKILL.md`

## Phase 3: Ecosystem Parity

- [x] 3.1 Update skill references in `.claude/skills/afx-help.md`
- [x] 3.2 Update Codex parity docs (`docs/agenticflowx/codex.md`)
- [x] 3.3 Update repo guidance (`AGENTS.md`, `prompts/agents.md`, `README.md`, `CLAUDE.md`, `docs/_index.md`)

## Phase 4: Validation

- [x] 4.1 Validate command markdown syntax and examples
- [x] 4.2 Run `/afx-update check` in a test project and verify status outputs
- [x] 4.3 Run `/afx-update apply --dry-run` in a test project and verify installer invocation
- [x] 4.4 Confirm Claude/Codex parity and next-command suggestions

---

## Work Sessions

<!-- Task execution log - updated by /afx-work next, /afx-dev code -->

| Date       | Task             | Action                                                                      | Files Modified                                                                                                                                                                                                                          | Agent | Human |
| ---------- | ---------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- | ----- |
| 2026-02-25 | 1.1, 1.2         | Drafted PRDs for afx-update                                                 | spec.md, design.md, tasks.md                                                                                                                                                                                                            | [x]  | [x]  |
| 2026-02-25 | 1.3              | Approved PRDs                                                               | spec.md, tasks.md, journal.md                                                                                                                                                                                                           | [x]  | [x]  |
| 2026-02-25 | 2.1-2.4, 3.1-3.3 | Implemented `/afx-update` + `afx-update` parity                             | .claude/skills/afx-update.md, .agents/skills/afx-update/\*, .claude/skills/afx-help.md, docs/agenticflowx/codex.md, AGENTS.md, prompts/agents.md, README.md, CLAUDE.md, docs/\_index.md, docs/agenticflowx/agenticflowx.md, tasks.md | [x]  | [ ]   |
| 2026-02-25 | 4.1, 4.4         | Validated docs parity and command references                                | tasks.md                                                                                                                                                                                                                                | [x]  | [ ]   |
| 2026-02-25 | 4.2, 4.3         | Ran update scenario matrix in tmp app; fixed Unknown-version check behavior | .claude/skills/afx-update.md, tasks.md, journal.md                                                                                                                                                                                      | [x]  | [ ]   |
