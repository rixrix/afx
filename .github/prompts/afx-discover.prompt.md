---
mode: agent
description: Discover what exists in your project - infrastructure scripts, automation tools, deployment workflows, and development capabilities.
---

# AFX discover

Use this prompt when a user asks for `afx-discover`, `/afx:discover`, or capability/infrastructure discovery in AFX.

Source of truth: `.claude/commands/afx-discover.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Read config: `.afx/.afx.yaml` (defaults) + `.afx.yaml` (user overrides); use source defaults when neither exists.
4. Preserve output format and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
