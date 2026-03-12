---
name: afx-report
description: Traceability metrics and project health reporting for AgenticFlowX.
---

# AFX report

Use this skill when the user requests:

- `afx-report`
- `/afx:report`
- AFX report subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-report.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully using available tools.

## Execution Rules

1. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides). Use defaults from command spec if neither exists.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.

## Compatibility Note

`/afx:report` is a Claude slash command name. In Antigravity, interpret it as an instruction to run the equivalent AFX workflow via this skill.
