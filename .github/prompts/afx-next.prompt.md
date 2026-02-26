---
mode: agent
description: Help with AFX next-step guidance and priority recommendations.
---

# AFX next

Use this prompt when a user asks for `afx-next`, `/afx:next`, or AFX next-step guidance.

Source of truth: `.claude/commands/afx-next.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format, ranking, and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
