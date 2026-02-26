---
mode: agent
description: Help with AFX discover commands for capabilities, infrastructure, scripts, and tools.
---

# AFX discover

Use this prompt when a user asks for `afx-discover`, `/afx:discover`, or capability/infrastructure discovery in AFX.

Source of truth: `.claude/commands/afx-discover.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
