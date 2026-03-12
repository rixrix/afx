---
name: afx-next
description: The "Golden Thread" command. Intelligently analyzes your current context (git state, active tasks, session history) and tells you exactly what to do next.
---

# AFX next

Use this skill when the user requests:

- `afx-next`
- `/afx:next`
- AFX next subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-next.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully using available tools.

## Execution Rules

1. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides). Use defaults from command spec if neither exists.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.

## Compatibility Note

`/afx:next` is a Claude slash command name. In Antigravity, interpret it as an instruction to run the equivalent AFX workflow via this skill.
