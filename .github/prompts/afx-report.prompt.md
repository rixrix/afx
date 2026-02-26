---
mode: agent
description: Help with AFX report commands for health, coverage, and orphan analysis.
---

# AFX report

Use this prompt when a user asks for `afx-report`, `/afx:report`, or health/coverage/orphan reporting actions in AFX.

Source of truth: `.claude/commands/afx-report.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and reporting semantics from the source.
5. Do not invent new workflow steps outside the source command definition.
