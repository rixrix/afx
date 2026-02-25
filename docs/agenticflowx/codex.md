---
afx: true
type: GUIDE
status: Living
tags: [afx, codex, skills, commands]
---

# AFX Codex Commands

AFX supports Codex via skills named `afx-xxx`.

## Naming

- Claude: `/afx:work next user-auth`
- Codex: `afx-work next user-auth` (or natural language asking for `afx-work`)

## Layout

- Versioned and runtime path: `.codex/skills/afx-*`

## Parity Map

| Claude Slash Command | Codex Skill    |
| -------------------- | -------------- |
| `/afx:next`          | `afx-next`     |
| `/afx:discover`      | `afx-discover` |
| `/afx:work`          | `afx-work`     |
| `/afx:dev`           | `afx-dev`      |
| `/afx:check`         | `afx-check`    |
| `/afx:task`          | `afx-task`     |
| `/afx:session`       | `afx-session`  |
| `/afx:init`          | `afx-init`     |
| `/afx:context`       | `afx-context`  |
| `/afx:spec`          | `afx-spec`     |
| `/afx:report`        | `afx-report`   |
| `/afx:help`          | `afx-help`     |

## Behavior Contract

Each Codex skill delegates to the canonical command spec in `.claude/commands/afx-*.md`. This keeps Claude and Codex behavior aligned without duplicating workflow logic.
