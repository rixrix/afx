---
mode: agent
description: Help with AFX work commands for status, next tasks, resume, sync, and planning.
---

# AFX work

Use this prompt when a user asks for `afx-work`, `/afx:work`, or work orchestration/status actions in AFX.

Source of truth: `.claude/commands/afx-work.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format, status transitions, and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
