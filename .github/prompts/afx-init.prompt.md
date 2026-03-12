---
mode: agent
description: Feature spec scaffolding for AgenticFlowX projects.
---

# AFX init

Use this prompt when a user asks for `afx-init`, `/afx:init`, or initialization of features/ADR artifacts in AFX.

Source of truth: `.claude/commands/afx-init.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides); use source defaults when neither exists.
4. Preserve output format and file scaffolding rules from the source.
5. Do not invent new workflow steps outside the source command definition.
