---
afx: true
type: COMMAND
status: Living
tags: [afx, command, development, traceability]
---

# /afx:dev

Development actions with AFX traceability.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-dev.md`

## Gemini-Specific Guidance

During development:

1.  **Traced Implementation**: When implementing code, use your ability to generate clean, idiomatic code while ensuring every function includes the mandatory `@see` annotations.
2.  **Refactoring**: Use `codebase_investigator` to ensure refactors maintain architectural integrity and that all `@see` links are preserved.
3.  **Debugging**: Use `grep_search` to trace errors against specifications and design documents.

## Usage

```bash
/afx:dev code
/afx:dev refactor
/afx:dev fix
/afx:dev debug [error]
/afx:dev test [scope]
```
