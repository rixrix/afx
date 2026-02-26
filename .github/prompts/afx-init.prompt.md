---
mode: agent
description: Help with AFX init commands for setting up features and ADR artifacts.
---

# AFX init

Use this prompt when a user asks for `afx-init`, `/afx:init`, or initialization of features/ADR artifacts in AFX.

Source of truth: `.claude/commands/afx-init.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and file scaffolding rules from the source.
5. Do not invent new workflow steps outside the source command definition.
