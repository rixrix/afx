---
name: afx-spec
description: Specification management, navigation, review, and approval for spec-centric workflows.
---

# AFX spec

Use this skill when the user requests:

- `afx-spec`
- `/afx:spec`
- AFX spec subcommands in natural language

## Source of Truth

Follow the canonical command spec in:

- `.claude/commands/afx-spec.md`

Do not re-invent workflow steps. Read the command file and execute it faithfully in Codex using available tools.

## Execution Rules

1. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides). Use defaults from command spec if neither exists.
2. Execute only the requested subcommand(s).
3. Preserve AFX traceability requirements (`@see`, task/session updates, gates) exactly as defined.
4. End with ranked next-command suggestions matching the command spec.
5. Prefer `rg` for search and non-destructive git operations.

## Compatibility Note

`/afx:spec` is a Claude slash command name. In Codex, interpret it as an instruction to run the equivalent AFX workflow via this skill.
