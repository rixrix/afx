---
mode: agent
description: Session discussion capture and recall for multi-agent workflows.
---

# AFX session

Use this prompt when a user asks for `afx-session`, `/afx:session`, or session/journal capture actions in AFX.

Source of truth: `.claude/commands/afx-session.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and journaling requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
