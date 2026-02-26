---
mode: agent
description: Help with AFX check commands for path, lint, links, and gate validation.
---

# AFX check

Use this prompt when a user asks for `afx-check`, `/afx:check`, or quality/path/link validation actions in AFX.

Source of truth: `.claude/commands/afx-check.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format, gate behavior, and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
