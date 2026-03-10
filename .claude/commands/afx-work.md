---
afx: true
type: COMMAND
status: Living
tags: [afx, command, workflow, state]
---

# /afx:work

Workflow state management for AgenticFlowX sessions.

## Configuration

**Read `.afx.yaml`** at project root to resolve paths:

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `prefixes` - Feature prefix mappings for discussion IDs

If `.afx.yaml` doesn't exist, use defaults.

## Usage

```bash
/afx:work status              # Quick state check
/afx:work next <spec-path>    # Pick next task from spec
/afx:work resume [spec|num]   # Continue in-progress work
/afx:work sync [spec] [issue] # Bidirectional GitHub sync
/afx:work plan [instruction]  # Generate tickets from specs
/afx:work approve [feature] <task> "<note>"  # Human approval complete
/afx:work reopen [feature] <task> "<reason>" # Reopen task for fixes
/afx:work close [feature] <issue> "<summary>" # Close issue and update docs
```

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx:work` action, suggest the most appropriate next command based on context:

| Context                           | Suggested Next Command                                        |
| --------------------------------- | ------------------------------------------------------------- |
| After `status` (has pending work) | `/afx:work resume` or `/afx:dev code`                         |
| After `status` (no active work)   | `/afx:spec list` or `/afx:work next <spec>` to start new task |
| After `next` (task assigned)      | `/afx:dev code` to implement                                  |
| After `next` (blocked by verify)  | `/afx:check path <path>` to unblock                           |
| After `resume` (context restored) | `/afx:dev code` to continue implementation                    |
| After `sync` (synced)             | `/afx:work next <spec>` or `/afx:dev code`                    |
| After `plan` (tickets generated)  | `/afx:spec validate <spec>` then create GitHub issues         |
| After `approve` (task approved)   | `/afx:work next <spec>` to continue                           |
| After `reopen` (task reopened)    | `/afx:dev code` to fix the issue                              |
| After `close` (issue closed)      | `gh pr create` or `/afx:spec status <spec>`                   |

**Suggestion Format** (5 ranked options, ideal → less ideal):

```
Next (ranked):
  1. /afx:dev code                              # Ideal: Continue implementation
  2. /afx:check path <path>                     # Verify before moving on
  3. /afx:task audit <task-id>                  # Audit task completion
  4. /afx:session capture "<note>"              # Capture context if switching
  5. /afx:work status                           # Re-orient if confused
```

---

## Subcommands

---

## 1. status

Check current working state after an interruption (restart, close lid, context switch, new session).

### Usage

```bash
/afx:work status
```

### Purpose

Restore agent context when resuming work. Identifies:

1. What spec/feature was being worked on
2. Which GitHub issue is active
3. What was the last completed action
4. What work remains

### Actions

Execute these checks in order:

#### 1. Check Git State

```bash
git status --short
git branch --show-current
```

#### 2. Find Active GitHub Issues

```bash
gh issue list --state open --label "agenticflow" --json number,title,labels
```

If no `agenticflow` label exists, check for feature-related issues:

```bash
gh issue list --state open --search "feature" --json number,title,state
```

#### 3. Read Active Issue Details

For each open issue found:

```bash
gh issue view {number}
```

Look for:

- Session Log section - find last entry date and task
- Subtasks section - count checked vs unchecked
- Discovered Issues - note any pending items

#### 4. Check Spec State

Read the active spec state from tasks and journal:

```bash
cat docs/specs/{feature}/tasks.md
cat docs/specs/{feature}/journal.md
```

### Output Format

```markdown
## Session State

**Branch**: {branch name}
**Uncommitted Changes**: {count} files or "None"
**Active Issue**: #{number} - {title} or "None found"
**Spec Path**: docs/specs/{feature}/ or "Unknown"

## Last Session

| Date               | Task   | Action   |
| ------------------ | ------ | -------- |
| {from Session Log} | {task} | {action} |

## Pending Work

From GitHub issue subtasks:

- [ ] {unchecked item 1}
- [ ] {unchecked item 2}

## Resume Instructions

{Based on state, provide appropriate guidance}

Next: /afx:work resume {spec} # Or /afx:dev code if ready
```

### Error Handling

**No open issues found:**

```
No active AgenticFlowX issues.

To start new work:
1. Check docs/specs/ for available features
2. Run `/afx:work next <spec-path>` to pick next task

Next: /afx:work next docs/specs/{feature}
```

**Multiple open issues:**

```
Multiple active issues found:
- #{n1}: {title1}
- #{n2}: {title2}

Select one to focus on, or close completed issues first.

Next: /afx:work resume {spec-name}   # Pick one spec to continue
```

---

## 2. next

Pick up the next available task(s) from a feature spec and generate agent assignment briefs.

### Session:

- Reads `tasks.md` for context
- Updates `tasks.md` with new work entry

### Usage

```bash
/afx:work next
/afx:work next user-auth
/afx:work next docs/specs/user-auth
```

### Context

- Spec path: $ARGUMENTS (required)
- Reads: spec.md, tasks.md, design.md from spec directory
- Checks: GitHub issues via `gh issue view`

### Actions

1. **Resolve feature**:
   - If `spec-path` provided, extract feature name.
   - If not, try to infer from current git branch.

2. **Identify next task**:
   - Read `docs/specs/{feature}/tasks.md`.
   - Find the first unchecked task in the current phase.

3. **Update Work Log**:
   - Open `docs/specs/{feature}/tasks.md`
   - Append row to `## Work Sessions` table:
     `| {date} | {task_id} | Started {task_title} | - | [WAIT] | - |`

### Task Readiness

A task is **ready** when:

1. Task checkbox is unchecked in tasks.md
2. All prerequisite phases are "Complete"
3. GitHub issue is open
4. **Previous task verified** (see Pre-Assignment Check below)

### Pre-Assignment Check (BLOCKING)

Before assigning the next task, verify previous work:

1. Check if there's an in-progress or recently completed task for this spec
2. If yes, check if `/afx:check path` was run on it (look for checkmark in Session Log Verify column)
3. If not verified:
   - **STOP** task assignment
   - Output: `Previous task not verified. Run /afx:check path <path> first.`
   - Show the pending verification command

**Example block message:**

```
BLOCKED: Previous task not verified

Task 2.1 (Claim Form UI) completed but not verified.
Run: /afx:check path src/features/user-auth

Cannot assign Task 2.2 until verification passes.
```

### Parallelization Rules

| Safe to Parallelize                                    | NOT Safe                     |
| ------------------------------------------------------ | ---------------------------- |
| Different packages (`@package/db` + `@package/mailer`) | Same files                   |
| Different apps (admin + portal)                        | Same layer with shared types |
| Read-only tasks                                        | Sequential phases            |

#### Conflict Matrix

| Layer                  | Can Parallel With       |
| ---------------------- | ----------------------- |
| SQL Migrations         | Email Templates, UI     |
| Repository/Service     | Email Templates         |
| Server Actions (Admin) | Server Actions (Portal) |
| UI (Admin)             | UI (Portal)             |

### Output Format

#### 1. State Summary

```markdown
## Project State: {Feature Name}

**Phase:** {current phase}
**Completed:** {list}
**Ready:** {next task(s)}
```

#### 2. Ready Tasks Table

```markdown
| Task | GitHub | Dependencies | Parallelizable With |
| ---- | ------ | ------------ | ------------------- |
| ...  | #XX    | Done         | ...                 |
```

#### 3. Agent Assignment Brief

````markdown
## Agent Assignment: {Task Name}

**GitHub Issue:** #XX
**Spec:** [tasks.md#{section}]({spec-path}/tasks.md#{anchor})
**Design:** [design.md#{section}]({spec-path}/design.md#{anchor})

### Files

- `path/to/file.ts` - purpose

### Subtasks

- [ ] From tasks.md

### Verify

**Gate 1 - Execution Path (BLOCKING):**

- [ ] `/afx:check path {feature-path}` executed
- [ ] Result: ALL PATHS VERIFIED

**Gate 2 - Code Quality:**

- [ ] `npx tsc --noEmit`
- [ ] `npx nx build {app}`
- [ ] `npx nx test {package}`
- [ ] `/afx:task audit {task}` - Spec compliance

### On Every Subtask Completion

**CRITICAL**: Update Work Sessions table after EACH subtask, not just at the end.

**Step 1**: Update local `tasks.md`:

```markdown
<!-- In docs/specs/{feature}/tasks.md → ## Work Sessions -->

| {YYYY-MM-DDTHH:MM:SS.mmmZ} | {X.Y} | {action taken} | {files modified} | [WAIT] | - |
```

Note: Two verification columns - Agent ([OK]/[WAIT]/[FAIL]) and Human (-/[WAIT]/[OK])

**Step 2**: If GitHub issue linked, sync:

```bash
gh issue edit {number} --body "$(updated body with new session log entry)"
```

See [agenticflowx.md#work-sessions](../../docs/agenticflowx/agenticflowx.md#work-sessions) for full rules.

**Next Command** (after assignment):

```
Next: /afx:dev code
```
````

### On Complete

1. **Run `/afx:check path`** - Must pass before proceeding
2. Verify all subtasks checked
3. Final Session Log entry: `READY FOR REVIEW` with Agent=[OK], Human=[WAIT]
4. Document any Discovered Issues
5. **Request human review** - Post review request format
6. **DO NOT close issue** - Human must review, mark Human=[OK], then close
7. Task is NOT complete until both Agent and Human columns show [OK]

**Next Command** (after task complete):

```
Next: /afx:check path {feature-path}   # Verify before next task
```

### Error Handling

**Missing parameter:**

```
Error: Spec path required
Usage: /afx:work next docs/specs/user-auth
```

**No tasks ready:**

```
Blocked: Phase 1 requires Phase 0-D complete
Next action: Complete #43 first

Next: /afx:work resume {spec}   # Continue blocked task
```

---

## 3. resume

Continue work on an in-progress spec after interruption.

### Usage

```bash
/afx:work resume              # List all in-progress specs
/afx:work resume user-auth  # Resume specific spec
/afx:work resume 1            # Resume first spec from list
```

### Context

- Argument: $ARGUMENTS (optional - spec name, number from list, or omit to list all)
- **Local-first**: Works without GitHub by reading spec files directly
- **GitHub-enhanced**: If `gh` CLI available, enriches with issue data

### Purpose

Unlike `/afx:work next` which finds the next ready task, `/afx:work resume` continues an **existing in-progress task** after interruption (break, context loss, new session).

### Workflow

#### Mode 1: No Arguments (List Sessions)

1. **Scan local specs**: List `docs/specs/*/tasks.md`
2. **Parse tasks.md**: Extract phase/task completion state
3. **Find active phases**: Look for "Next" or "In Progress" status
4. **Read tasks.md**: Find first unchecked task in active phase
5. **Check GitHub** (optional): If `gh` available, get linked issue numbers
6. **Display table**: Show all resumable sessions

```markdown
## Available Sessions

| #   | Spec              | Phase | Next Task                     |
| --- | ----------------- | ----- | ----------------------------- |
| 1   | user-auth         | 7     | 7.1 Create supplier constants |
| 2   | users-permissions | 0     | 0.1 Package scaffolding       |

GitHub: Available (issues linked)

Select spec name or number to resume:

Next: /afx:work resume 1 # Or specify spec name
```

#### Mode 2: With Spec Name/Number

When called with specific spec:

1. **Resolve spec**: Map name/number to `docs/specs/{name}/`
2. **Read tasks.md**: Get current phase status
3. **Read tasks.md**: Find active phase and next unchecked task
4. **Read design.md**: Get relevant section for context
5. **Check GitHub** (optional): Get session log if issue linked in tasks
6. **Generate continuation brief**: Output context for resuming work

### Output Format (Mode 2)

#### 1. Session State

```markdown
## Resuming: {spec-name}

**Active Phase:** {phase number and name}
**Next Task:** {task number and description}
**Last Update:** {date from tasks.md}
```

#### 2. Continuation Point

```markdown
## Continue From

**Task:** {X.Y task description}
**Files to Create/Modify:** {from tasks.md}
**Code Reference:** [design.md#{section}]({spec-path}/design.md#{anchor})
```

#### 3. Context Refresh

```markdown
## Quick Context

- **Spec:** [tasks.md](docs/specs/{name}/tasks.md)
- **Design:** [design.md](docs/specs/{name}/design.md)
- **Research:** {if applicable, link to research/\*.md}

{list from discovered issues if available}
```

#### 4. Verification Commands

```markdown
## Verify After Completion

- [ ] `npx tsc --noEmit`
- [ ] `npx nx build {app}`
- [ ] Update tasks.md checkboxes

Next: /afx:dev code # Continue implementation
```

### Data Sources

| Source            | Data Extracted                                                |
| ----------------- | ------------------------------------------------------------- |
| `spec.md`         | Spec metadata (status, owner, version, tags)                  |
| `tasks.md`        | Task checkboxes `- [x]` vs `- [ ]`, task descriptions         |
| `tasks.md`        | Work Sessions + past session logs synced from GitHub via sync |
| `design.md`       | Implementation context, code samples                          |
| GitHub (optional) | Issue numbers, session logs, discovered issues                |

### Error Handling

**No specs found:**

```
No specs found in docs/specs/
Create a spec directory with spec.md, design.md, tasks.md, journal.md
```

**Spec not found:**

```
Error: Spec 'foo' not found
Available specs: user-auth, users-permissions
```

**No active sessions:**

```
No in-progress sessions found.
All specs are either complete or not started.

Next: /afx:work next docs/specs/{feature}   # Start a new task
```

### Comparison

| Command            | Use Case                       | Input            |
| ------------------ | ------------------------------ | ---------------- |
| `/afx:work next`   | Find next ready task from spec | Spec path        |
| `/afx:work resume` | List all in-progress sessions  | (none)           |
| `/afx:work resume` | Continue specific spec         | Spec name/number |
| `/afx:work status` | Quick "where was I?" check     | (none)           |

---

## 4. sync

Bidirectional synchronization between local AgenticFlowX files and GitHub Issues.

### Usage

```bash
/afx:work sync [spec-name] [issue-number]
```

### Purpose

Ensure **Session Continuity** by syncing:

1. **GitHub → Local**: Pull "Session Log" from issue body/comments into `docs/specs/{module}/tasks.md`.

### Context

- **Data Sources**:
  - `docs/specs/{module}/tasks.md` (Local continuity log)
  - GitHub Issue (Remote continuity log)

### Process

#### Direction 1: GitHub → Local (Session Pull)

1. **Fetch Issue Data**:
   - Access the linked GitHub issue (found in `tasks.md` or argument).
   - Scan Issue Body AND Comments for "Session Log" tables.
2. **Normalize Data**:
   - Extract rows: Date, Task, Action, Files Modified, Verify.
   - Filter out rows already present locally (deduplication).
3. **Update Local File**:
   - Append new rows to `docs/specs/{module}/tasks.md`.
   - If file doesn't exist, create it.

### Output

```markdown
Synced 3 session entries from Issue #123 to tasks.md

Next: /afx:work next docs/specs/{feature} # Continue with next task
```

---

## 5. plan

Plan implementation tasks based on PRD requirements. Creates or updates `tasks.md` and generates GitHub ticket content.

### Usage

```bash
/afx:work plan [instruction]
```

### Context

- **Context**:
  - `spec.md`: Requirements (What)
  - `tasks.md`: Implementation Plan (How)
- **Modes**:
  1. **New Feature**: Generates initial tasks from spec.
  2. **Feature Update (Add Functionality)**: explicitly asks "How do I add X to this existing feature?" and appends new tasks.

### Process

1. **Context Scan**:
   - Agent reads `tasks.md`.
   - Checks if "Phase X" is complete or in progress.
2. **Gap Analysis**:
   - "User wants to add a search bar."
   - "Does `tasks.md` cover this?" -> No.
3. **Plan Update**:
   - **Propose new tasks**: Appends new tasks to the current or new phase in `tasks.md`.
   - **Example**:
     ```markdown
     - [ ] Task 7.5: Add search bar to header
     - [ ] Task 7.6: Implement search logic
     ```
   - **Does NOT** overwrite existing history in `tasks.md` or `journal.md`.
   - **Living Specs**: Ensure `design.md` and `spec.md` are documented to reflect the _current intended factual state_, without historical narrative.
4. **Ticket Generation** (Optional):
   - If user requests, generates GitHub ticket content for the new tasks.

### Output Format (Ticket)

Follow the **GitHub Ticket Template** in `../../docs/agenticflowx/agenticflowx.md`:

```markdown
## [{Phase}] {Title}

> Ref: [tasks.md - {section}](../docs/specs/{module}/tasks.md#{anchor})

### Context for Agent

...

### Subtasks

...
```

### Rules

- **Traceability**: Every ticket MUST reference a `tasks.md` item.
- **Granularity**: Tickets should be 1-2 hours of agent work (approx 10-20 subtasks max).
- **Context**: Always provide links to `design.md` sections relevant to the work.

**Next Command** (after plan generated):

```
Next: gh issue create --title "{title}" --body "{body}"   # Create ticket
```

Or if tasks.md updated:

```
Next: /afx:work next docs/specs/{feature}   # Pick up next task
```

---

## 6. approve

Complete the human approval stage of a task after functional testing and code review.

### Usage

```bash
/afx:work approve [feature] <task> "<note>"
```

Examples:

- `/afx:work approve 7.4 "Tested supplier filter, all 5 suppliers work"`
- `/afx:work approve user-auth 7.4 "Code reviewed, filter works"`

### Context

- `feature`: Optional. Auto-detected from git branch if omitted (e.g., `feat/user-auth` → `user-auth`)
- `task`: Required. Task number (e.g., `7.4`)
- `note`: Required. What was tested/verified

### Purpose

Marks the **human approval** stage complete. This is the final step in the two-stage verification process:

1. **Agent** completes implementation → marks Agent [OK]
2. **Human** tests + reviews code → runs `/afx:work approve` → marks Human [OK]
3. **Documentation Audit**: Ensure any history, failed attempts, or architectural decisions from this task are logged in `journal.md`, and that `design.md` reflects only the final clean state.

### Flexible Verification (Override)

**Default**: Automated tests are **REQUIRED** for approval.
**Override**: If working on legacy code or areas where tests are prohibitively expensive, you may override this requirement.

**Agent Protocol**:

1. **Always Suggest Tests**: "Tests are missing. Should we generate them? `/afx:dev test`"
2. **Accept Override**: If user explicitly says "Legacy code, skip tests", proceed with approval but **Log the Override** in the note.
   - Example: `/afx:work approve 7.4 "Manual verify only (Legacy UI). Filter works."`

### Actions

1. **Resolve feature** (if not provided):

   ```bash
   git branch --show-current  # e.g., feat/user-auth
   ```

   Extract feature name from branch.

2. **Read tasks.md**:
   - Find `docs/specs/{feature}/tasks.md`
   - Locate Work Sessions table

3. **Update Work Sessions table**:
   - Add new row with verification entry
   - Format: `| {date} | {task} | VERIFIED | {note} | - | [OK] | [OK] |`

4. **Confirm tasks.md** (optional):
   - Verify task is marked `[x]` in `docs/specs/{feature}/tasks.md`
   - If not marked, mark it now (acknowledges manual work)

### Output Format

```markdown
[OK] Task {task} approved

**Feature:** {feature}
**Note:** {note}
**Updated:** docs/specs/{feature}/tasks.md

Next (ranked):

1.  /afx:work next docs/specs/{feature}/tasks.md # Pick up next task
2.  /afx:session recap {feature} # Review progress
3.  gh pr create # Create PR if ready
```

### Work Sessions Update

Before:

```
| Date       | Task | Status | Action                | Files Modified       | Agent | Human |
| 2025-12-15 | 7.4  | DONE   | Added supplier filter | feature-filters.tsx | [OK]   | [WAIT] |
```

After:

```
| Date       | Task | Status   | Action                              | Files Modified       | Agent  | Human  |
| 2025-12-15 | 7.4  | DONE     | Added supplier filter               | feature-filters.tsx | [OK]   | -      |
| 2025-12-16 | 7.4  | VERIFIED | Tested supplier filter, all 5 work  | -                    | [OK]   | [OK]   |
```

### Error Handling

**Missing task number:**

```
Error: Task number required
Usage: /afx:work approve 7.4 "approval note"
```

**Missing note:**

```
Error: Verification note required
Usage: /afx:work approve 7.4 "what you tested"
```

**Feature not found:**

```
Error: Cannot detect feature from branch 'main'
Specify feature: /afx:work approve user-auth 7.4 "note"
```

---

## 7. reopen

Reopen a task that failed human verification and needs fixes.

### Usage

```bash
/afx:work reopen [feature] <task> "<reason>"
```

Examples:

- `/afx:work reopen 7.4 "Filter breaks with empty supplier list"`
- `/afx:work reopen user-auth 7.4 "Missing validation on null supplier"`

### Context

- `feature`: Optional. Auto-detected from git branch if omitted
- `task`: Required. Task number to reopen
- `reason`: Required. Why verification failed

### Purpose

When human verification finds issues that need fixing:

- Reopens the task for agent work
- Records the failure reason
- Marks Human [FAIL] in Work Sessions

### Actions

1. **Resolve feature** (same as verify)

2. **Update tasks.md**:
   - Find task in `docs/specs/{feature}/tasks.md`
   - Change `[x]` back to `[ ]`

3. **Update Work Sessions table**:
   - Add new row: `| {date} | {task} | REOPENED | {reason} | - | [WAIT] | [FAIL] |`

### Output Format

```markdown
Task {task} reopened

**Feature:** {feature}
**Reason:** {reason}
**Updated:**

- docs/specs/{feature}/tasks.md (unchecked + Work Sessions updated)

Next (ranked):

1.  /afx:dev code # Fix the issue
2.  /afx:session capture "<note>" # Capture details
3.  /afx:work status # Check current state
```

### Work Sessions Update

```
| Date       | Task | Status   | Action                        | Files Modified | Agent  | Human  |
| 2025-12-15 | 7.4  | DONE     | Added supplier filter         | ...            | [OK]   | -      |
| 2025-12-16 | 7.4  | REOPENED | Filter breaks with empty list | -              | [WAIT] | [FAIL] |
```

### When to Use reopen vs New Ticket

| Situation                       | Action                                  |
| ------------------------------- | --------------------------------------- |
| Bug in original implementation  | `/afx:work reopen`                      |
| Missing edge case (scope creep) | Create new ticket via `gh issue create` |
| Major design flaw               | Discuss first, may need spec update     |

---

## 8. close

Close a GitHub issue and update all associated AgenticFlowX documentation.

### Usage

```bash
/afx:work close [feature] <issue-number> "<summary>"
```

Examples:

- `/afx:work close 51 "Phase 7 complete - supplier assignment with hardcoded constants"`
- `/afx:work close user-auth 51 "Supplier filter and assignment implemented"`

### Context

- `feature`: Optional. Auto-detected from git branch if omitted (e.g., `feat/user-auth` → `user-auth`)
- `issue-number`: Required. GitHub issue number to close
- `summary`: Required. Completion summary for issue comment

### Purpose

Closes a GitHub issue and performs **bidirectional sync** to ensure all AgenticFlowX documentation is updated:

1. **GitHub → Local**: Pull any final updates from issue
2. **Local → GitHub**: Push completion summary
3. **Close issue**: With completion comment
4. **Update all docs**: journal, tasks verification

### Actions

Execute these steps in order:

#### 1. Resolve Feature

```bash
git branch --show-current  # e.g., feat/user-auth
```

Extract feature name from branch if not provided.

#### 2. Verify Issue Exists and is Open

```bash
gh issue view {issue-number} --json state,title,body
```

If issue is already closed, warn and exit.

#### 3. Verify All Tasks Complete

Read `docs/specs/{feature}/tasks.md` and check:

- All subtasks in the phase are marked `[x]`
- If any unchecked tasks remain, **WARN** but allow override

```
Warning: 2 tasks still unchecked in tasks.md
- [ ] 7.3 Some task
- [ ] 7.4 Another task

Continue anyway? (issue will be closed)
```

#### 4. Verify Human Verification Complete

Read `docs/specs/{feature}/tasks.md` Work Sessions table:

- Check last entry has Human = [OK]
- If Human = [WAIT], **BLOCK** and require `/afx:work approve` first

```
BLOCKED: Human verification pending

Last entry shows Human = [WAIT]
Run: /afx:work verify {task} "verification note"

Cannot close issue until human verification complete.
```

#### 5. Bidirectional Sync (GitHub ↔ Local)

**Step 5a - Pull from GitHub:**

```bash
gh issue view {issue-number} --json body,comments
```

- Extract any Session Log entries from issue body/comments
- Check for entries not in local `tasks.md`
- Append missing entries to local file

**Step 5b - Push to GitHub:**

- Read local `tasks.md` Work Sessions table
- Post completion comment to issue with:
  - Final journal state
  - Completion summary

#### 6. Update Local Documentation

**Update `tasks.md` Work Sessions:**

Add final closure entry to Work Sessions:

```markdown
| {date} | - | CLOSED #{issue} | {summary} | [OK] | [OK] |
```

**Update `tasks.md` checkboxes (required):**

Ensure all completed tasks for the closed issue are checked and consistent with Work Sessions entries.

#### 7. Close GitHub Issue

```bash
gh issue close {issue-number} --comment "$(cat <<'EOF'
## Completed

{summary}

### Journal (Final)
{table from tasks.md Work Sessions}



---
Closed via `/afx:work close`
EOF
)"
```

### Output Format

```markdown
Issue #{issue-number} closed

**Feature:** {feature}
**Summary:** {summary}

### Updates Made

| File                          | Action                             |
| ----------------------------- | ---------------------------------- |
| docs/specs/{feature}/tasks.md | Checked completed tasks            |
| docs/specs/{feature}/tasks.md | Added closure row to Work Sessions |
| GitHub Issue #{issue-number}  | Closed with final comment          |

### Synced

- **GitHub → Local:** {N} session entries pulled
- **Local → GitHub:** Completion summary posted

Next (ranked):

1.  `gh pr create` # Create PR for this work
2.  `/afx:work next docs/specs/{feature}` # Continue with next phase
3.  `/afx:session recap {feature}` # Review completed work
```

### Pre-Close Checklist (Auto-Verified)

The command automatically verifies:

- [ ] All phase tasks checked in tasks.md
- [ ] Human verification complete (Human = [OK])
- [ ] No REOPENED entries without subsequent VERIFIED
- [ ] Session log synced with GitHub

### Error Handling

**Missing issue number:**

```
Error: Issue number required
Usage: /afx:work close 51 "completion summary"
```

**Missing summary:**

```
Error: Summary required
Usage: /afx:work close 51 "Phase 7 complete - supplier assignment"
```

**Issue already closed:**

```
Error: Issue #51 is already closed
State: closed on 2025-12-15

To reopen: gh issue reopen 51
```

**Human verification pending:**

```
BLOCKED: Human verification incomplete

Task 7.4 has Agent [OK] but Human [WAIT]
Run: /afx:work verify 7.4 "verification note"

Cannot close until human verification complete.
```

**Feature not found:**

```
Error: Cannot detect feature from branch 'main'
Specify feature: /afx:work close user-auth 51 "summary"
```

### Bidirectional Sync Details

The `close` command ensures consistency between GitHub and local files:

| Direction      | What's Synced                                | Target                 |
| -------------- | -------------------------------------------- | ---------------------- |
| GitHub → Local | Session Log entries from issue body/comments | tasks.md               |
| GitHub → Local | Discovered Issues from issue comments        | journal.md Discussions |
| Local → GitHub | Completion summary                           | Issue close comment    |

### Workflow Integration

```
/afx:work next      → Assigns task, creates session entry
     ↓
/afx:dev code       → Implements, updates session-log
     ↓
/afx:work verify    → Human confirms, marks Human [OK]
     ↓
/afx:work close     → Syncs, updates docs, closes issue  ← YOU ARE HERE
     ↓
gh pr create        → Creates PR for the work
```

---

## Related Commands

| Command            | Relationship                                                                     |
| ------------------ | -------------------------------------------------------------------------------- |
| `/afx:spec`        | Spec-centric navigation and validation; work manages workflow state across specs |
| `/afx:task`        | Verify specific tasks; work manages workflow state                               |
| `/afx:check`       | Quality gates; work next blocks until verified                                   |
| `/afx:session`     | Captures discussions; work reads session logs                                    |
| `/afx:work verify` | Completes human verification stage                                               |
| `/afx:work reopen` | Reopens task that failed verification                                            |
| `/afx:work close`  | Closes issue with bidirectional sync                                             |
