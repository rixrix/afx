---
mode: agent
description: Help with AFX spec commands for drafting and refining specs, design, and tasks.
---

# AFX spec

Use this prompt when a user asks for `afx-spec`, `/afx:spec`, or spec/design/tasks authoring actions in AFX.

Source of truth: `.claude/commands/afx-spec.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
