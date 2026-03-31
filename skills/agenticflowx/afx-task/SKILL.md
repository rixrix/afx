---
name: afx-task
description: Implementation lifecycle — plan tasks, pick work, implement code, verify, complete, and sync with GitHub
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,task,implementation,coding,verification,lifecycle"
  afx-argument-hint: "plan | pick | code | verify | complete | sync | brief | review"
---

# /afx-task

Implementation lifecycle engine for `tasks.md` artifacts and source code. Owns the full journey from task planning through coding to completion.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.templates` - Where spec templates live (default: `docs/agenticflowx/templates`)

If neither file exists, use defaults.

## Usage

```bash
# Task Planning (lifecycle-gated)
/afx-task plan <name>                      # Generate tasks.md from approved design

# Work Management
/afx-task pick <id>                        # Check out a task as active
/afx-task complete <id>                    # Mark task done

# Implementation (from afx-dev code)
/afx-task code <id>                        # Implement task with @see traceability

# Verification
/afx-task verify <task-id>                 # Verify task implementation vs spec
/afx-task verify <spec>#<task-id>          # Explicit spec (e.g., user-auth#7.1)
/afx-task brief <task-id>                  # Get implementation summary

# Quality
/afx-task review <name>                    # Check for planning gaps

# GitHub Sync
/afx-task sync [spec] [issue]              # Bidirectional GitHub sync
```

> **Note:** Task listing and phase progress are available in the VSCode AFX extension (Tasks Tab, Pipeline Tab). These subcommands focus on operations that require agent reasoning.

## Purpose

Owns the `tasks.md` artifact AND the implementation engine. Owns coding with traceability, task state management, and GitHub sync. All spec-driven coding is tied to a task ID.

## Context Resolution

When task ID alone is provided (e.g., `7.1`), resolve spec in this order:

1. **Conversation context** - Recently discussed spec (file reads, GitHub issues, prior commands)
2. **Branch name** - Extract from `feat/{feature-name}` pattern
3. **Open GitHub issues** - If only one feature has open issues
4. **Fallback** - Require explicit: `/afx-task verify user-auth#7.1`

---

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace
- Create/update `tasks.md` only in `docs/specs/**/`
- Create/modify source code and test files in application directories (via `code` subcommand)
- Run build, test, and lint commands (via `code` subcommand)
- Run shell commands for GitHub sync (`gh` CLI, via `sync` subcommand)
- Append to `docs/specs/**/journal.md` (captures only, via Proactive Capture Protocol)

### Forbidden

- Create/modify/delete `spec.md` (owned by `/afx-spec`)
- Create/modify/delete `design.md` (owned by `/afx-design`)
- Delete any spec files or directories
- Delete source code files (refactoring may remove code within files, but deleting entire files requires user confirmation)
- Run deploy/migration commands without explicit user confirmation
- Modify `.afx.yaml` or `.afx/` configuration

If out-of-scope work is requested, return:

```text
Out of scope for /afx-task (implementation-lifecycle mode). Use /afx-spec for spec changes, /afx-design for design changes.
```

---

### Timestamp Format (MANDATORY)

All timestamps MUST use ISO 8601 with millisecond precision: `YYYY-MM-DDTHH:MM:SS.mmmZ` (e.g., `2025-12-17T14:30:00.000Z`). Never write short formats like `2025-12-17 14:30`.

### Frontmatter (MANDATORY)

When creating or modifying `tasks.md`, enforce the canonical AFX frontmatter schema:

```yaml
---
afx: true
type: TASKS
status: Draft
owner: "@handle"
version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
updated_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
tags: ["{feature}"]
spec: spec.md
design: design.md
---
```

**Canonical field order**: `afx → type → status → owner → version → created_at → updated_at → tags → spec → design`. Use double quotes for all string values.

**Immutable fields** (must NOT be changed during plan/pick/complete): `afx`, `type`, `owner`, `created_at`.

### Proactive Journal Capture

When this skill detects a high-impact context change, auto-capture to `journal.md` per the [Proactive Capture Protocol](../afx-session/SKILL.md#proactive-capture-protocol-mandatory).

**Triggers for `/afx-task`**: Spec-implementation mismatch that requires decision, task blocked by external dependency, scope change discovered during coding.

---

## Lifecycle Precondition (BLOCKING)

**CRITICAL**: Task planning is gated behind design approval. Task coding is gated behind task planning.

| Action | Precondition                       | Check                      |
| ------ | ---------------------------------- | -------------------------- |
| `plan` | `design.md` status == `Approved`   | Read design.md frontmatter |
| `code` | `tasks.md` exists with task `{id}` | Read tasks.md              |

Before planning, the agent **MUST**:

1. Read `design.md` frontmatter for the target feature
2. Check the `status` field
3. If `status` is NOT `Approved`, **STOP** and output:

```text
BLOCKED: Cannot author tasks.md content.

Precondition not met:
  design.md status is "{current_status}" (required: "Approved")

Approve the design first:
  /afx-design review {name}
  /afx-design approve {name}
```

---

## Post-Action Checklist (MANDATORY)

After completing any action that modifies `tasks.md` or source code, you MUST:

1. **Update `updated_at`**: Set to current ISO 8601 timestamp in `tasks.md` frontmatter.
2. **Verify backlinks**: Ensure `spec: spec.md` and `design: design.md` are present in `tasks.md` frontmatter.
3. **Contextual Tagging**: If changes introduce new domains or concepts, append to `tags` array.
4. **Version & State Management**: If modifying a `tasks.md` that is currently `status: Living` and the change alters task scope (adding/removing phases), bump `version`.
5. **Format Preservation**: Frontmatter fields must remain in canonical order. Use double quotes.
6. **Work Sessions Table** (CRITICAL — agents frequently get this wrong):
   - The `## Work Sessions` section MUST be the **last section** in `tasks.md`, after all Phase sections and after the Cross-Reference Index. If it has drifted above other sections, move it back to the bottom before appending.
   - After `pick`, `code`, and `complete`, **append a new row** to the table. Do NOT replace existing rows.
   - Use this exact column structure — no variations:

     ```markdown
     | Date       | Task | Action    | Files Modified       | Agent | Human |
     | ---------- | ---- | --------- | -------------------- | ----- | ----- |
     | 2026-03-31 | 1.1  | Picked    | -                    | [x]   | -     |
     | 2026-03-31 | 1.1  | Coded     | auth.service.ts, ... | [x]   | -     |
     | 2026-03-31 | 1.1  | Completed | auth.service.ts, ... | [x]   | -     |
     ```

   - **Date**: `YYYY-MM-DD` (date only, not full ISO timestamp)
   - **Task**: WBS ID (e.g., `1.1`, `2.3`)
   - **Action**: One of `Picked`, `Coded`, `Completed`, `Verified`, `Reviewed`
   - **Files Modified**: Comma-separated list, or `-` if no files changed
   - **Agent/Human**: `[x]` for who performed, `-` for not applicable

7. **`@see` Annotations (code subcommand only)**: Add `@see` links at the **class and function level** via JSDoc on exported classes, interfaces, and functions. Line-level annotations ONLY when a specific line implements a non-obvious requirement. **CRITICAL ANTI-PATTERN**: Do NOT dump blanket `@see` links at the top of the file. Do NOT annotate every line.
8. **Task Checkbox**: After `code` and `complete`, mark the relevant task checkbox `[x]`.

---

## Agent Instructions

### Persistence Checkpoint (MANDATORY)

Do not auto-write `tasks.md` during `plan`. Before persisting:

1. Present the proposed content to the user
2. Wait for explicit confirmation before writing
3. `journal.md` append-only entries may be written without checkpoint
4. Source code changes during `code` do NOT require a checkpoint (normal development flow)

### Next Command Suggestion (MANDATORY)

After EVERY `/afx-task` action, suggest the next command:

| Context                     | Suggested Next Command                          |
| --------------------------- | ----------------------------------------------- |
| After `plan`                | `/afx-task pick <first-task-id>` to start work  |
| After `pick {id}`           | `/afx-task code {id}` to implement              |
| After `code {id}`           | `/afx-task verify {id}` to check implementation |
| After `verify` ([OK])       | `/afx-task complete {id}` to mark done          |
| After `verify` ([PARTIAL])  | `/afx-task code {id}` to finish implementation  |
| After `verify` ([MISSING])  | `/afx-task code {id}` to implement              |
| After `complete {id}`       | `/afx-task pick <next-id>` for next task        |
| After `brief`               | `/afx-task code {id}` or `/afx-task pick`       |
| After `review` (gaps found) | Address gaps in tasks.md                        |
| After `sync`                | `/afx-task pick` to resume work                 |

---

## Subcommands

### plan <name>

**Purpose:** Generate implementation task breakdown from approved design.

**Lifecycle Gate:** `design.md` status MUST be `Approved`.

**Implementation:**

1. **Read Approved Spec + Design**
   - Load `spec.md` — extract requirements for traceability
   - Load `design.md` — extract components, interfaces, data models, Node IDs
   - Load `journal.md` — extract any task-related decisions

2. **Design Feedback** (advisory — does not block planning)

   Scan `design.md` for gaps that will affect task quality. For each major design section, check if it has substantive content (not just placeholder text). Report findings before generating tasks:

   ```
   Design Feedback:
     ⚠ [DES-ERR] Error handling section is empty — tasks will define error cases inline
     ⚠ [DES-TEST] No integration test strategy specified
     ✓ [DES-API] API contracts well-defined
     ✓ [DES-DATA] Data model complete

   Recommendation: /afx-design review {name} to address gaps before finalizing tasks
   ```

   If critical sections are empty (`[DES-ARCH]`, `[DES-API]`, `[DES-DATA]`), warn the user but continue — do not block.

3. **Generate Task Breakdown** using the tasks template (`docs/agenticflowx/templates/tasks.md`):
   - Organize into phases (setup, core, integration, testing, docs)
   - Each task must have:
     - WBS numbering (Phase.Task, e.g., `1.1`, `2.3`)
     - Clear description of what to implement
     - File scope — list the specific files this task creates or modifies
     - `@see` links using Node ID syntax: `@see design.md [DES-API]`, `@see spec.md [FR-1]`
     - Acceptance criteria (how to verify the task is done)
   - **Parallelization**: Tasks within a phase should be **independent by default** — no shared mutable state, no file overlap. When two tasks in the same phase DO depend on each other, note the dependency explicitly: `<!-- depends: 1.1 -->`. Cross-phase dependencies are implicit (phase N depends on phase N-1).
   - Order phases by dependency (setup before core, core before integration)
   - Generate Cross-Reference Index table linking tasks → spec requirements → design sections

4. **Persistence Checkpoint** (MANDATORY) — present to user, wait for confirmation

5. **Write tasks.md** — replace scaffold, preserve frontmatter, update `updated_at`, set backlinks

6. **Update journal.md** — append entry recording task planning session

---

### pick {id}

**Purpose:** Check out a task as active.

**Implementation:**

1. Read `tasks.md`, find task `{id}`
2. Verify task is not already marked complete (`[x]`)
3. **Check dependencies**: If the task has a `<!-- depends: X.Y -->` comment, verify that task X.Y is marked complete. If not, warn the user and suggest picking the dependency first.
4. **Locate `## Work Sessions`** — it must be the last section. If missing, create it at the bottom. If misplaced, move it to the bottom.
5. Append a row to the Work Sessions table:

   ```markdown
   | 2026-04-01 | {id} | Picked | - | [x] | - |
   ```

6. Update `updated_at` in `tasks.md` frontmatter
7. Output task description and acceptance criteria for context

---

### code {id}

**Purpose:** The implementation engine. Loads full spec context and writes code with `@see` traceability.

**Absorbed from:** `afx-dev code`

**Implementation:**

1. **Load Context**
   - Read `spec.md` — requirements and acceptance criteria
   - Read `design.md` — architecture, data models, API contracts, Node IDs
   - Read `tasks.md` — task definition, acceptance criteria, related tasks
   - Read existing source code — understand current patterns and architecture

2. **Implement**
   - Write source code fulfilling the task requirements
   - Follow existing code patterns and architecture in the project
   - Run build/test/lint as needed

3. **Add `@see` Annotations** (class and function level):

   ```typescript
   /**
    * User authentication service
    *
    * @see docs/specs/user-auth/design.md [DES-API]
    * @see docs/specs/user-auth/tasks.md [2.1]
    */
   export class AuthService {
     /**
      * @see docs/specs/user-auth/spec.md [FR-1]
      * @see docs/specs/user-auth/design.md [DES-SEC]
      */
     async login(credentials: LoginInput): Promise<AuthResult> {
       // implementation
     }
   }
   ```

   **Annotation Rules:**
   - Annotate exported classes, interfaces, and functions that fulfill spec requirements
   - Use Node ID syntax: `@see path/to/file.md [NODE-ID]`
   - Line-level annotations ONLY for non-obvious requirement implementations
   - **NEVER** dump blanket `@see` at the top of the file
   - **NEVER** annotate every line — that creates noise

4. **Update tasks.md**:
   - Mark task checkbox `[x]`
   - **Locate `## Work Sessions`** at the bottom. Append a `Coded` row with the files you modified:
     ```markdown
     | 2026-03-31 | {id} | Coded | auth.service.ts, auth.action.ts | [x] | - |
     ```
   - Update `updated_at`

---

### verify <task-id>

**Purpose:** Verify task implementation against spec requirements (static verification).

Unlike `/afx-check path` which verifies runtime execution paths, this verifies if a specific task matches its spec.

**Implementation:**

1. **Read tasks.md** — find task definition
2. **Check files exist** — verify files mentioned in task exist
3. **Scan for `@see` backlinks** — check source code for `@see` references to this task
4. **Scan for incomplete markers** — grep for `TODO`, `FIXME` related to this task
5. **Check Work Sessions table** — verify a session log entry exists
6. **Output verification result**:

```markdown
## Task 7.1 Verify

**Spec**: user-auth
**Task**: Create supplier constants
**Status**: [OK] Implemented | [PARTIAL] Partial | [MISSING] Missing

### Implementation Evidence

| Check                 | Status | Details                                |
| --------------------- | ------ | -------------------------------------- |
| Files exist           | [OK]   | feature-claim-supplier.constants.ts    |
| @see backlinks        | [OK]   | 2 files reference this task            |
| Session log entry     | [OK]   | 2025-12-13: Created supplier constants |
| No incomplete markers | [OK]   | No TODO/FIXME for 7.1                  |

### Verdict

[OK] **Task 7.1 is fully implemented**
```

**Verification Status Definitions:**

| Status            | Meaning                     | Criteria                                 |
| ----------------- | --------------------------- | ---------------------------------------- |
| [OK] Implemented  | Task fully complete         | Files exist, backlinks present, no TODOs |
| [PARTIAL] Partial | Task started but incomplete | Some files exist, or TODOs remain        |
| [MISSING] Missing | Task not started            | No files, no session log, no backlinks   |

---

### complete {id}

**Purpose:** Mark task as done.

**Implementation:**

1. Read `tasks.md`, find task `{id}`
2. Verify task checkbox is marked `[x]` (should be done by `code`)
3. If not marked, mark it now
4. **Locate `## Work Sessions`** at the bottom of `tasks.md`. Append a row:

   ```markdown
   | 2026-03-31 | {id} | Completed | auth.service.ts, auth.action.ts | [x] | - |
   ```

5. Update `updated_at` in `tasks.md` frontmatter
6. Output confirmation and suggest next task

---

### sync [spec] [issue]

**Purpose:** Bidirectional GitHub sync.

**Implementation:**

1. **Tasks → GitHub**: For each uncompleted task in `tasks.md`, ensure a corresponding GitHub issue or checklist item exists
2. **GitHub → Tasks**: For each closed GitHub issue, check if corresponding task checkbox is marked
3. **Reconcile**: Report discrepancies (task done in code but issue open, or issue closed but task unchecked)
4. Uses `gh` CLI for GitHub operations

---

### brief <task-id>

**Purpose:** Generate concise summary of what was built for a task.

**Implementation:**

1. Read task definition from tasks.md
2. Find session log entries in Work Sessions table
3. Find files modified (from session logs and `@see` backlinks)
4. Summarize implementation

---

### review <name>

**Purpose:** Check for planning gaps — advisory, not blocking.

**Implementation:**

1. Extract all requirements from `spec.md` (FR-xxx, NFR-xxx)
2. Extract all tasks from `tasks.md` with their `@see` references
3. Cross-reference:
   - Find requirements without corresponding tasks (gaps)
   - Find tasks without requirement links (orphans)
   - Calculate coverage percentage
4. Check if design sections have corresponding tasks
5. Output gap analysis:

```
Gap Analysis: user-authentication

Requirements Coverage: 6/8 (75%)

Requirements WITHOUT Tasks (GAPS):
  ✗ [FR-4] Password complexity
  ✗ [NFR-3] Token expiry

Orphaned Tasks (no requirement link):
  ⚠ Task 1.1: Setup database schema

Recommendations:
  1. Add task for [FR-4] (password complexity)
  2. Add task for [NFR-3] (token expiry)
  3. Link task 1.1 to a requirement or remove if unnecessary
```

---

## Error Handling

### Common Errors

1. **Design Not Approved (plan)**

   ```text
   BLOCKED: Cannot author tasks.md content.

   Precondition not met:
     design.md status is "Draft" (required: "Approved")

   Approve the design first:
     /afx-design review {name}
     /afx-design approve {name}
   ```

2. **Task Not Found**

   ```text
   Error: Task 7.5 not found in docs/specs/user-auth/tasks.md
   Available tasks in Phase 7: 7.1, 7.2, 7.3, 7.4
   ```

3. **Ambiguous Spec**

   ```text
   Error: Cannot determine spec context.
   Recent activity spans multiple specs: user-auth, users-permissions

   Specify explicitly:
     /afx-task verify user-auth#7.1
   ```

4. **Task Already Complete**

   ```text
   Task 2.1 is already marked complete.

   To re-open: uncheck the task in tasks.md and run /afx-task pick 2.1
   ```

---

## Related Commands

### From Other Commands → `/afx-task`

- `/afx-design approve` → Suggest `/afx-task plan <name>`
- `/afx-check trace` → Suggest `/afx-task verify` if broken `@see` links found
- `/afx-next` → Suggest `/afx-task pick` if tasks are pending

### From `/afx-task` → Other Commands

- `/afx-task plan` → Suggest `/afx-task pick <first-id>`
- `/afx-task complete` → Suggest `/afx-task pick <next-id>` or `/afx-check path` for gate verification
- `/afx-task verify` ([OK]) → Suggest `/afx-task complete <id>`
- `/afx-task review` (gaps) → Suggest editing `tasks.md` to add missing tasks
