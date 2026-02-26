---
mode: agent
description: Help with AFX context commands for saving and loading project context.
---

# AFX context

Use this prompt when a user asks for `afx-context`, `/afx:context`, or context bundle save/load operations in AFX.

Source of truth: `.claude/commands/afx-context.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and context-bundle semantics from the source.
5. Do not invent new workflow steps outside the source command definition.
