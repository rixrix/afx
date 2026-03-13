---
mode: agent
description: The "Golden Thread" command. Intelligently analyzes your current context (git state, active tasks, session history) and tells you exactly what to do next.
---

# AFX next

Use this prompt when a user asks for `afx-next`, `/afx:next`, or AFX next-step guidance.

Source of truth: `.claude/commands/afx-next.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides); use source defaults when neither exists.
4. Preserve output format, ranking, and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
