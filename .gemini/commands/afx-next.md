---
afx: true
type: COMMAND
status: Living
tags: [afx, command, context, guidance]
---

# /afx:next

The "Golden Thread" command. intelligently analyzes your current context (git state, active tasks, session history) and tells you exactly what to do next.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-next.md`

## Gemini-Specific Guidance

To perform the deep context scan required by AFX, you should leverage Gemini's specialized tools:

1.  **Context Analysis**: Use `codebase_investigator` if you need a high-level architectural overview or to understand complex dependencies related to the current task.
2.  **State Detection**:
    - Use `run_shell_command` with `git status --short` and `git branch --show-current`.
    - Use `grep_search` to find active tasks in `tasks.md` and recent entries in `journal.md`.
3.  **Refined Suggestions**: Ensure your recommended next steps align perfectly with the AFX priority logic (Plan Mode → Git State → Active Task → Recent Completion → Idle).

## Usage

```bash
/afx:next
```
