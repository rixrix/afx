---
mode: agent
description: Help with AFX task commands for audit, summary, listing, and progress checks.
---

# AFX task

Use this prompt when a user asks for `afx-task`, `/afx:task`, or task verification/summary/list operations in AFX.

Source of truth: `.claude/commands/afx-task.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and task-audit semantics from the source.
5. Do not invent new workflow steps outside the source command definition.
