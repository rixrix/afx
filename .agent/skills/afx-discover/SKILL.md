---
name: afx-discover
description: Discover what exists in your project - infrastructure scripts, automation tools, deployment workflows, and development capabilities.
---

# AFX discover

Use this skill when the user requests:

- `afx-discover`
- `/afx:discover`
- AFX discover subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-discover.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully using available tools.

## Execution Rules

1. Read `.afx.yaml` if present; otherwise use defaults described in the command spec.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.

## Compatibility Note

`/afx:discover` is a Claude slash command name. In Antigravity, interpret it as an instruction to run the equivalent AFX workflow via this skill.
