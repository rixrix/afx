---
afx: true
type: COMMAND
status: Living
tags: [afx, command, context, guidance]
---

# /afx:next

The "Golden Thread" command. intelligently analyzes your current context (git state, active tasks, session history) and tells you exactly what to do next.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.adr` - Where global ADR files live (default: `docs/adr`)

If neither file exists, use defaults.

## Usage

```bash
/afx:next
```

## Agent Instructions

### Analysis Logic

You must perform a deep context scan to determine the user's state. Follow this priority logic:

1.  **Check Plan Mode / Gates**:
    - Is `<system-reminder>Plan mode is active</system-reminder>` present?
      - **Suggestion**: "Continue planning. Edit the plan or request review."
    - Is a task waiting for review?
      - **Suggestion**: `/afx:work approve <task> "note"` (if you are the reviewer) or "Wait for human review."

2.  **Check Global ADRs** (`ls docs/adr/*.md`):
    - Are there ADRs with `status: Proposed`?
      - **Situation**: Architectural decisions are pending review.
      - **Suggestion**: "Review Proposed ADR: docs/adr/ADR-NNNN-*.md"

3.  **Check Git State** (`git status --short`):
    - Are there uncommitted changes?
      - **Situation**: Work is in progress but not saved/verified.
      - **Suggestion**:
        1.  If strictly code changes: `/afx:check path <path>` (Verify it works)
        2.  If ready to commit: `/afx:dev code` (Completing the subtask)
        3.  If just exploring: `/afx:session note "findings"` (Capture thought)

3.  **Check Active Task** (`/afx:work status` logic):
    - Is there an active task in `journal.md` or GitHub?
      - **Situation**: Task is assigned but git is clean.
      - **Suggestion**: `/afx:dev code` (Start/Resume implementation)

4.  **Check recent completion**:
    - Did the last session end with "Completed"?
      - **Situation**: Task done, need verification.
      - **Suggestion**: `/afx:task audit <task-id>` (Verify against spec)

5.  **Check Idle State**:
    - No active task, clean git state.
      - **Situation**: Ready for new work.
      - **Suggestion**: `/afx:work next <spec>` (Pick up next task)

6.  **Fallbacks**:
    - Confused?
      - **Suggestion**: `/afx:help guides` (Browse workflows) or `/afx:work status` (Re-orient)

### Output Format

```markdown
## Context: {Brief State Description}

**Detected**: {Uncommitted changes | Active Task X.Y | Idle | Review Pending}

### Recommended Next Step

**> /afx:command <args>**
_{Reasoning why this is the best step}_

### Alternatives

1. /afx:alt1 - {Reason}
2. /afx:alt2 - {Reason}
```

## Examples

**Scenario 1: Mid-Implementation**
(User has modified files but hasn't run checks)

```markdown
## Context: Implementation in Progress

**Detected**: 3 uncommitted files (modified), Task 7.4 Active

### Recommended Next Step

**> /afx:check path apps/webapp/claims**
_You have code changes that haven't been verified yet. Run the runtime check to ensure nothing is broken._

### Alternatives

1. /afx:dev code "continue" - If you are still writing code.
2. /afx:session note "context" - If you are switching contexts.
```

**Scenario 2: Task Done**
(User just finished coding, git is clean/committed)

```markdown
## Context: Implementation Complete?

**Detected**: Git Clean, Task 7.4 marked "Done" in last session log.

### Recommended Next Step

**> /afx:task audit 7.4**
_The task seems finished. Validate it against the spec requirements in tasks.md._
```

**Scenario 3: Proposed ADRs**
(User created an ADR but hasn't finalized it)

```markdown
## Context: Architectural Decision Pending

**Detected**: 1 Proposed ADR (docs/adr/ADR-0001-database-choice.md)

### Recommended Next Step

**> Review docs/adr/ADR-0001-database-choice.md**
_An architectural decision is currently Proposed. Review the context and rationale to move it to Accepted or Rejected._
```

**Scenario 4: Idle**
(No active task)

```markdown
## Context: Ready for Work

**Detected**: No active tasks found.

### Recommended Next Step

**> /afx:work next <feature>**
_Pick up the next pending task from the current feature spec._

### Alternatives

1. /afx:work status - Check full project state.
2. /afx:init feature - Start something new.
```
