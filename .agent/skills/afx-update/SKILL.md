---
name: afx-update
description: Check for upstream AFX updates and apply them safely.
---

# AFX update

Use this skill when the user requests:

- `afx-update`
- `/afx:update`
- AFX update subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-update.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully using available tools.

## Execution Rules

1. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides). Use defaults from command spec if neither exists.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.

## Compatibility Note

`/afx:update` is a Claude slash command name. In Antigravity, interpret it as an instruction to run the equivalent AFX workflow via this skill.
