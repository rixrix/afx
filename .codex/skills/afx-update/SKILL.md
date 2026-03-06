---
name: afx-update
description: Check for upstream AFX updates and apply them safely.
---

# AFX update

Use this skill when the user requests:

- `afx-update`
- `/afx:update`
- AFX update checks or update apply actions

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-update.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully in Codex using available tools.

## Execution Rules

1. Read `.afx.yaml` if present; otherwise use defaults described in the command spec.
2. Execute only the requested subcommand(s).
3. Preserve command safety and update behavior exactly as defined in the command spec.
4. End with ranked next-command suggestions matching the command spec.
5. Prefer `check` before `apply` unless user explicitly asks to apply immediately.

## Compatibility Note

`/afx:update` is a Claude slash command name. In Codex, interpret it as an instruction to run the equivalent AFX workflow via this skill.
