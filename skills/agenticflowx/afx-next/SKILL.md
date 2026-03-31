---
name: afx-next
description: Context-aware guidance — analyzes git state, active tasks, and session history to recommend the best next action
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,context,guidance,golden-thread"
---

# /afx-next

The "Golden Thread" command. intelligently analyzes your current context (git state, active tasks, session history) and tells you exactly what to do next.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.adr` - Where global ADR files live (default: `docs/adr`)

If neither file exists, use defaults.

## Usage

```bash
/afx-next
```

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace
- Analyze git state, active tasks, and session history

### Forbidden

- Create/modify/delete any files
- Run build/test/deploy/migration commands

If implementation is requested, respond with:

```text
Out of scope for /afx-next (read-only advisor mode). Use the suggested command to proceed.
```

---

## Agent Instructions

### Analysis Logic

You must perform a deep context scan to determine the user's state. Follow this priority logic:

1.  **Check Plan Mode / Gates**:
    - Is `<system-reminder>Plan mode is active</system-reminder>` present?
      - **Suggestion**: "Continue planning. Edit the plan or request review."
    - Is a task waiting for review?
      - **Suggestion**: `/afx-task complete <task> "note"` (if you are the reviewer) or "Wait for human review."

2.  **Check Global ADRs** (`ls docs/adr/*.md`):
    - Are there ADRs with `status: Proposed`?
      - **Situation**: Architectural decisions are pending review.
      - **Suggestion**: "Review Proposed ADR: docs/adr/ADR-NNNN-*.md"

3.  **Check Git State** (`git status --short`):
    - Are there uncommitted changes?
      - **Situation**: Work is in progress but not saved/verified.
      - **Suggestion**:
        1.  If strictly code changes: `/afx-check path <path>` (Verify it works)
        2.  If ready to commit: `/afx-task code` (Completing the subtask)
        3.  If just exploring: `/afx-session note "findings"` (Capture thought)

3.  **Check Active Task** (`/afx-next` logic):
    - Is there an active task in `journal.md` or GitHub?
      - **Situation**: Task is assigned but git is clean.
      - **Suggestion**: `/afx-task code` (Start/Resume implementation)

4.  **Check recent completion**:
    - Did the last session end with "Completed"?
      - **Situation**: Task done, need verification.
      - **Suggestion**: `/afx-task verify <task-id>` (Verify against spec)

5.  **Check Idle State**:
    - No active task, clean git state.
      - **Situation**: Ready for new work.
      - **Suggestion**: `/afx-task pick <spec>` (Pick up next task)

6.  **Fallbacks**:
    - Confused?
      - **Suggestion**: `/afx-help guides` (Browse workflows) or `/afx-next` (Re-orient)

### Output Format

```markdown
## Context: {Brief State Description}

**Detected**: {Uncommitted changes | Active Task X.Y | Idle | Review Pending}

Next (ranked):
  1. /afx-command <args>                         # Context-driven: {why this is best}
  2. /afx-alt1                                   # Context-driven: {reason}
  3. /afx-alt2                                   # Context-driven: {reason}
  ──
  4. /afx-next                            # Re-orient
  5. /afx-session note "<note>"                   # Capture context
```

## Examples

**Scenario 1: Mid-Implementation**
(User has modified files but hasn't run checks)

```markdown
## Context: Implementation in Progress

**Detected**: 3 uncommitted files (modified), Task 7.4 Active

Next (ranked):
  1. /afx-check path apps/webapp/claims           # Context-driven: Verify uncommitted changes
  2. /afx-task code "continue"                     # Context-driven: Continue writing code
  3. /afx-dev test claims                         # Context-driven: Run tests before commit
  ──
  4. /afx-next                             # Re-orient
  5. /afx-session note "context"                   # Capture before switching
```

**Scenario 2: Task Done**
(User just finished coding, git is clean/committed)

```markdown
## Context: Implementation Complete?

**Detected**: Git Clean, Task 7.4 marked "Done" in last session log.

Next (ranked):
  1. /afx-task verify 7.4                        # Context-driven: Validate against spec
  2. /afx-task complete 7.4 "done"                # Context-driven: Mark task complete
  3. /afx-task pick docs/specs/{feature}          # Context-driven: Move to next task
  ──
  4. /afx-next                             # Re-orient
  5. /afx-session note "<note>"                    # Capture learnings
```

**Scenario 3: Proposed ADRs**
(User created an ADR but hasn't finalized it)

```markdown
## Context: Architectural Decision Pending

**Detected**: 1 Proposed ADR (docs/adr/ADR-0001-database-choice.md)

Next (ranked):
  1. Review docs/adr/ADR-0001-database-choice.md # Context-driven: ADR needs review
  2. /afx-research explore "database choice"      # Context-driven: Research before deciding
  3. /afx-session note "ADR review"                # Context-driven: Capture review notes
  ──
  4. /afx-next                             # Re-orient
  5. /afx-help                                    # See all options
```

**Scenario 4: Idle**
(No active task)

```markdown
## Context: Ready for Work

**Detected**: No active tasks found.

Next (ranked):
  1. /afx-task pick <feature>                    # Context-driven: Pick next pending task
  2. /afx-init feature <name>                    # Context-driven: Start something new
  3. /afx-discover capabilities                   # Context-driven: Explore project state
  ──
  4. /afx-next                             # Check full project state
  5. /afx-session recap all                       # Refresh memory from past sessions
```
