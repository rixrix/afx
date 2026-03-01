---
afx: true
type: COMMAND
status: Living
tags: [afx, command, session, context]
---

# /afx:session

Session discussion capture and recall for multi-agent workflows.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-session.md`

## Gemini-Specific Guidance

To preserve session context:

1.  **Capturing Discussions**: Use `write_file` to append structured metadata and discussion summaries to `journal.md`.
2.  **Recall**: Use `read_file` to browse and restore previous session contexts.
3.  **Note Taking**: Use `write_file` for smart notes, ensuring they are auto-tagged and linked to the correct feature journal.

## Usage

```bash
/afx:session save [feature]
/afx:session recall <session-id>
/afx:session list
/afx:session note "content" [tags]
/afx:session show [feature|all]
/afx:session recap [feature|all]
/afx:session promote <id>
```
