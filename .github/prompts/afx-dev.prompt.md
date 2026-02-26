---
mode: agent
description: Help with AFX dev commands for implementation, debugging, refactoring, and review.
---

# AFX dev

Use this prompt when a user asks for `afx-dev`, `/afx:dev`, or implementation/debug/refactor/review actions in AFX.

Source of truth: `.claude/commands/afx-dev.md`

## Instructions

1. Read the source command file fully before taking action.
2. Execute only the requested subcommand behavior.
3. Honor `.afx.yaml` path settings; use source defaults when absent.
4. Preserve output format and spec-traceability requirements from the source.
5. Do not invent new workflow steps outside the source command definition.
