---
name: afx-check
description: Execute the AFX check command workflow in Codex. Trigger when the user asks for afx-check, /afx:check, or the corresponding check subcommands.
---

# AFX check

Use this skill when the user requests:

- `afx-check`
- `/afx:check`
- AFX check subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-check.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully in Codex using available tools.

## Execution Rules

1. Read `.afx.yaml` if present; otherwise use defaults described in the command spec.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.
5. Prefer `rg` for search and non-destructive git operations.

## Compatibility Note

`/afx:check` is a Claude slash command name. In Codex, interpret it as an instruction to run the equivalent AFX workflow via this skill.
