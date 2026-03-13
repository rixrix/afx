---
mode: agent
description: Verify and summarize task implementation status.
---

# AFX task

Use this prompt when a user asks for `afx-task`, `/afx:task`, or task verification/summary/list operations in AFX.

Source of truth: `.claude/commands/afx-task.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides); use source defaults when neither exists.
4. Preserve output format and task-audit semantics from the source.
5. Do not invent new workflow steps outside the source command definition.
