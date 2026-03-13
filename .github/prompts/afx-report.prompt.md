---
mode: agent
description: Traceability metrics and project health reporting for AgenticFlowX.
---

# AFX report

Use this prompt when a user asks for `afx-report`, `/afx:report`, or health/coverage/orphan reporting actions in AFX.

Source of truth: `.claude/commands/afx-report.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides); use source defaults when neither exists.
4. Preserve output format and reporting semantics from the source.
5. Do not invent new workflow steps outside the source command definition.
