---
mode: agent
description: Check for upstream AFX updates and apply them safely.
---

# AFX update

Use this prompt when a user asks for `afx-update`, `/afx:update`, or AFX command/runtime update actions.

Source of truth: `.claude/commands/afx-update.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and update semantics from the source.
5. Do not invent new workflow steps outside the source command definition.
