---
mode: agent
description: AFX (AgenticFlowX) command reference.
---

# AFX help

Use this prompt when a user asks for `afx-help`, `/afx:help`, or AFX command/workflow guidance.

Source of truth: `.claude/commands/afx-help.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output structure and navigation hints from the source.
5. Do not add new workflow steps or command semantics beyond the source.
