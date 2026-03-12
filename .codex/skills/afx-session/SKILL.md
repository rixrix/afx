---
name: afx-session
description: Session discussion capture and recall for multi-agent workflows.
---

# AFX session

Use this skill when the user requests:

- `afx-session`
- `/afx:session`
- AFX session subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-session.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully in Codex using available tools.

## Execution Rules

1. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides). Use defaults from command spec if neither exists.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.
5. Prefer `rg` for search and non-destructive git operations.

## Compatibility Note

`/afx:session` is a Claude slash command name. In Codex, interpret it as an instruction to run the equivalent AFX workflow via this skill.
