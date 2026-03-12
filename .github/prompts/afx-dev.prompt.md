---
mode: agent
description: Development actions with AFX traceability.
---

# AFX dev

Use this prompt when a user asks for `afx-dev`, `/afx:dev`, or implementation/debug/refactor/review actions in AFX.

Source of truth: `.claude/commands/afx-dev.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides); use source defaults when neither exists.
4. Preserve output format and spec-traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
