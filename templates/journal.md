---
afx: true
type: JOURNAL
status: Living
owner: "@{owner}"
tags: [{ feature }, journal]
---

# Journal - {Feature Name}

<!-- prefix: XX -->

> Quick captures and discussion history for AI-assisted development sessions.
> See [agenticflowx.md](../agenticflowx.md) for workflow.

## Captures

<!-- Quick notes during active chat - cleared when recorded -->

---

## Discussions

<!-- Recorded discussions with IDs: XX-D001, XX-D002, etc. -->
<!-- Chronological order: oldest first, newest last -->

### XX-D001 - YYYY-MM-DD - Topic Title

`status:active` `[tag1, tag2]`

**Context**: What prompted this discussion

**Summary**: Key points in 2-3 sentences

**Progress**:

- [x] Completed item _(N1)_
- [ ] Pending item 2

**Decisions**:

- Decision 1
- Decision 2

**Tips/Ideas**:

- Tip 1
- Tip 2

**Notes**:

- **[XX-D001.N1]** **[YYYY-MM-DDTHH:MM:SS.mmmZ]** Note content `[tags]`

**Related Files**: file1.ts, file2.ts
**Participants**: @{owner}

---

## Work Sessions

<!-- Task execution log - updated by /afx:work next, /afx:dev code -->

| Date | Task | Action | Files Modified | Agent | Human |
| ---- | ---- | ------ | -------------- | ----- | ----- |

---

## Template Notes

### Discussion Entry Structure

Each discussion has:

| Field             | Purpose                                             |
| ----------------- | --------------------------------------------------- |
| `status:active`   | Inline status tag (active/blocked/closed)           |
| `[tags]`          | Auto-generated from content keywords                |
| **Context**       | What prompted the discussion                        |
| **Summary**       | 2-3 sentence overview                               |
| **Progress**      | Checkbox items for tracking (auto-synced on append) |
| **Decisions**     | Key decisions made                                  |
| **Tips/Ideas**    | Insights captured during discussion                 |
| **Notes**         | Later additions via `/afx:session note --ref ID`    |
| **Related Files** | Cumulative list of files mentioned across all notes |
| **Participants**  | Who was involved                                    |

### Related Files Tracking

The `**Related Files**:` field is **cumulative** - it grows as notes are appended:

1. When recording a discussion, include files mentioned in context
2. When appending notes, add any new files mentioned to the list
3. Keep files comma-separated for easy scanning
4. Include both source files and config files as relevant

**Example accumulation**:

```markdown
# Initial record

**Related Files**: .env, packages/configs/src/backend.ts

# After N1 mentions amplify config

**Related Files**: .env, packages/configs/src/backend.ts, infrastructure/amplify/amplify.yml

# After N2 mentions dashboard config

**Related Files**: .env, packages/configs/src/backend.ts, infrastructure/amplify/amplify.yml, infrastructure/amplify/amplify-dashboard.yml
```

### Prefix Convention

Each feature journal uses a 2-4 character prefix for discussion IDs:

| Feature           | Prefix | Example    |
| ----------------- | ------ | ---------- |
| (global)          | `GEN`  | `GEN-D001` |
| user-auth         | `UA`   | `UA-D001`  |
| infrastructure    | `INF`  | `INF-D001` |
| users-permissions | `UP`   | `UP-D001`  |

Define prefix in `<!-- prefix: XX -->` comment after title.
