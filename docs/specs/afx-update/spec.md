---
afx: true
type: SPEC
status: Approved
owner: "@rix"
version: 1.0
approved_at: "2026-02-25T04:39:00.000Z"
tags: [afx-update, framework, commands]
---

<!-- APPROVED: 2026-02-25 - Do not edit without version bump -->

# Requirements: afx-update

> Add a dedicated AFX update command that can check upstream version status and apply framework updates.

## Functional Requirements

| ID   | Requirement                                                                                                   | Priority |
| ---- | ------------------------------------------------------------------------------------------------------------- | -------- |
| FR-1 | Provide new Claude slash command `/afx:update` with `check` and `apply` subcommands                           | P1       |
| FR-2 | Provide equivalent Codex skill trigger `afx-update` and Claude-compat mapping (`/afx:update` -> `afx-update`) | P1       |
| FR-3 | `check` reports local installed AFX version vs latest upstream release version                                | P1       |
| FR-4 | `apply` runs upstream installer update flow (`install.sh --update`) with supported pass-through flags         | P1       |
| FR-5 | `apply` supports safe preview mode (`--dry-run`) and recommends it when risk is unclear                       | P2       |
| FR-6 | Command/help/docs parity is maintained across `.claude`, `.codex`, README, AGENTS, and Codex parity guide     | P1       |
| FR-7 | `check` and `apply` produce ranked next-command suggestions consistent with AFX command style                 | P2       |

## Non-Functional Requirements

| ID    | Requirement                                                                                 | Priority |
| ----- | ------------------------------------------------------------------------------------------- | -------- |
| NFR-1 | Backward compatible: no breaking changes to existing AFX command names or installation flow | P1       |
| NFR-2 | Idempotent check: running `check` repeatedly does not modify project files                  | P1       |
| NFR-3 | Clear failure modes for network errors, upstream parsing errors, and installer failures     | P1       |
| NFR-4 | Keep Claude/Codex behavior aligned via canonical source of truth in `.claude/commands/`     | P1       |
