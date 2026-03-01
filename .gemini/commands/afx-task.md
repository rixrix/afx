---
afx: true
type: COMMAND
status: Living
tags: [afx, command, task, management]
---

# /afx:task

Verify and summarize task implementation status.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-task.md`

## Gemini-Specific Guidance

When managing tasks:

1.  **Verification**: Use `read_file` to compare implementation against task requirements in `tasks.md`.
2.  **Audit**: Use `grep_search` to review all tasks for completion criteria.
3.  **Closing Tasks**: Use `read_file` to ensure both `[Agent OK]` and `[Human OK]` columns are marked before closing.

## Usage

```bash
/afx:task verify <task-id>
/afx:task audit
/afx:task close <task-id>
/afx:task list [phase]
```
