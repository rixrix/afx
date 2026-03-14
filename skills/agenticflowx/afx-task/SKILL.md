---
name: afx-task
description: Task verification and auditing — audit implementation vs spec, show progress, list tasks by phase, and generate summaries
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,task,verification,audit,progress"
---

# /afx-task

Verify and summarize task implementation status.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)

If neither file exists, use defaults.

## Usage

```bash
/afx-task audit <task-id>              # Verify task implementation
/afx-task audit <spec>#<task-id>       # Explicit spec (e.g., user-auth#7.1)
/afx-task audit <task-id> <tasks.md>   # Explicit path to tasks.md

/afx-task summary <task-id>             # Get implementation summary
/afx-task list [phase]                  # List tasks (optionally filtered by phase)
/afx-task progress                      # Show status across all phases
```

## Purpose

Close the loop between "task marked done" and "task actually implemented correctly". Unlike `/afx-check path` (execution path) which verifies **runtime integrity**, this audits if a **specific task matches its spec** (static verification).

## Context Resolution

When task ID alone is provided (e.g., `7.1`), resolve spec in this order:

1. **Conversation context** - Recently discussed spec (file reads, GitHub issues, prior commands)
2. **Branch name** - Extract from `feat/{feature-name}` pattern
3. **Open GitHub issues** - If only one feature has open issues
4. **Fallback** - Require explicit: `/afx-task audit user-auth#7.1`

---

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx-task` action, suggest the most appropriate next command based on context:

| Context                               | Suggested Next Command                         |
| ------------------------------------- | ---------------------------------------------- |
| After `audit` ([OK] Implemented)      | `/afx-work next <spec>` for next task          |
| After `audit` ([PARTIAL])             | `/afx-dev code` to complete implementation     |
| After `audit` ([MISSING])             | `/afx-dev code` to implement                   |
| After `summary` (understanding task)  | `/afx-dev code` or `/afx-work next`            |
| After `list` (seeing tasks)           | `/afx-task audit <task-id>` or `/afx-dev code` |
| After `progress` (reviewing progress) | `/afx-work next <spec>` for next pending task  |

**Suggestion Format** (5 ranked options, ideal → less ideal):

```
Next (ranked):
  1. /afx-work next docs/specs/{feature}        # Ideal: Move to next task
  2. /afx-dev code                              # Implement if task incomplete
  3. /afx-check path <path>                     # Verify execution path
  4. /afx-task audit {next-task-id}             # Audit another task
  5. /afx-session capture "<note>"              # Note findings before switching
```

---

### 1. Parse Arguments

```bash
/afx-task audit 7.1                    # Infer spec
/afx-task audit user-auth#7.1    # Explicit spec#task
/afx-task audit 7.1 docs/specs/user-auth/tasks.md  # Explicit path
```

Extract:

- `subcommand`: audit | summary | list | progress
- `task_id`: e.g., "7.1"
- `spec_name`: e.g., "user-auth" (optional)
- `tasks_path`: e.g., "docs/specs/user-auth/tasks.md" (optional)

---

### 2. Resolve Spec Context

If spec not explicit:

```bash
# 1. Check conversation - look for recent tasks.md reads or GitHub issues
# 2. Check branch
git branch --show-current
# feat/user-auth → spec = "user-auth"

# 3. Check open issues
gh issue list --state open --json title | grep -i "feature\|claims"

# 4. If ambiguous, error:
Error: Ambiguous spec. Use: /afx-task audit user-auth#7.1
```

---

### 3. Audit Mode

**Usage**: `/afx-task audit <task-id>`

Steps:

1. **Read tasks.md** - Find task definition

   ```bash
   # Look for "7.1" or "### 7.1" or "#### 7.1" in tasks.md
   ```

   ```bash
   # Look in GitHub issue or journal.md for task entries
   ```

2. **Check files exist** - Verify files mentioned in task exist

   ```bash
   # For each file in task description, check existence
   ls -la <file-path>
   ```

3. **Scan for incomplete markers**

   ```bash
   # In files related to this task:
   grep -r "TODO.*7.1\|FIXME.*7.1" --include="*.ts"
   grep -r "// TODO" <task-files>  # General incomplete markers
   ```

4. **Output verification result**:

```markdown
## Task 7.1 Audit

**Spec**: user-auth
**Task**: Create supplier constants
**Status**: [OK] Implemented | [PARTIAL] Partial | [MISSING] Missing

### Task Definition (from tasks.md)

> {task description from spec}

### Implementation Evidence

| Check                 | Status | Details                                |
| --------------------- | ------ | -------------------------------------- |
| Files exist           | [OK]   | feature-claim-supplier.constants.ts    |
| @see backlinks        | [OK]   | 2 files reference this task            |
| Session log entry     | [OK]   | 2025-12-13: Created supplier constants |
| No incomplete markers | [OK]   | No TODO/FIXME for 7.1                  |

### Files Modified

- `packages/db/src/core/constants/feature-claim-supplier.constants.ts`

### Backlinks Found

- feature-claim-supplier.constants.ts:1 → @see tasks.md#71-create-supplier-constants

### Verdict

[OK] **Task 7.1 is fully implemented**

Next: /afx-work next docs/specs/{feature} # Proceed to next task
```

---

### 4. Summary Mode

**Usage**: `/afx-task summary <task-id>`

Generate concise summary of what was built:

1. Read task definition from tasks.md
2. Find session log entries
3. Find files modified
4. Summarize implementation

**Output**:

```markdown
## Task 7.1 Summary

**Task**: Create supplier constants
**Completed**: 2025-12-13

**What was built**:
Created hardcoded supplier list with UUID-format IDs for Phase 1
implementation. Includes manufacturer-to-supplier mapping and helper
functions for dropdown population.

**Files**:

- `packages/db/src/core/constants/feature-claim-supplier.constants.ts`

**Key additions**:

- `SUPPLIERS` constant with 3 suppliers
- `getSupplierOptions()` for dropdowns
- `getSupplierByManufacturer()` for auto-suggestion

**Related**:

- @see docs/specs/user-auth/research/supplier-assignment.md

Next: /afx-dev code # Continue with related work
```

---

### 5. List Mode

**Usage**: `/afx-task list [phase]`

List tasks from tasks.md:

```markdown
## Tasks - user-auth

### Phase 7: Supplier Assignment

| Task | Description                      | Status    |
| ---- | -------------------------------- | --------- |
| 7.1  | Create supplier constants        | [x]      |
| 7.2  | Add supplier dropdown to Portal  | [x]      |
| 7.3  | Add supplier assignment to Admin | [x]      |
| 7.4  | Add supplier filter (optional)   | [PENDING] |

### Phase 6: Testing

| Task | Description           | Status    |
| ---- | --------------------- | --------- |
| 6.1  | Repository unit tests | [MISSING] |
| 6.2  | Service unit tests    | [MISSING] |

Next: /afx-task audit 7.1 # Audit a specific task
```

---

### 6. Progress Mode

**Usage**: `/afx-task progress`

Show overall task completion:

```markdown
## Task Progress - user-auth

| Phase | Total | Done | Remaining |
| ----- | ----- | ---- | --------- |
| 0     | 4     | 4    | 0         |
| 1     | 3     | 3    | 0         |
| 2     | 4     | 4    | 0         |
| 3     | 5     | 5    | 0         |
| 4     | 4     | 4    | 0         |
| 5     | 3     | 2    | 1         |
| 6     | 5     | 0    | 5         |
| 7     | 4     | 3    | 1         |

**Overall**: 32/37 tasks (86%)

**Next**: Phase 5.3 or Phase 6.1

Next: /afx-work next docs/specs/{feature} # Pick up next pending task
```

---

## Verification Status Definitions

| Status            | Meaning                     | Criteria                                 |
| ----------------- | --------------------------- | ---------------------------------------- |
| [OK] Implemented  | Task fully complete         | Files exist, backlinks present, no TODOs |
| [PARTIAL] Partial | Task started but incomplete | Some files exist, or TODOs remain        |
| [MISSING] Missing | Task not started            | No files, no session log, no backlinks   |

---

## Integration with Other Commands

| Command        | Relationship                                            |
| -------------- | ------------------------------------------------------- |
| `/afx-check`   | Checks execution path; `/afx-task` audits spec usage    |
| `/afx-work`    | Shows workflow state; `/afx-task` shows task completion |
| `/afx-session` | Captures discussions; `/afx-task` reads session logs    |
| `/afx-dev`     | Implements code; `/afx-task` validates implementation   |

---

## Examples

### Verify task with inferred context

```bash
# On branch feat/user-auth
/afx-task audit 7.1
# → Checks user-auth task 7.1
```

### Verify with explicit spec

```bash
/afx-task audit user-auth#7.1
# → Explicitly checks user-auth task 7.1
```

### Get summary of completed task

```bash
/afx-task summary 7.1
# → Shows what was built for task 7.1
```

### List all Phase 6 tasks

```bash
/afx-task list 6
# → Shows all testing tasks
```

### Check overall progress

```bash
/afx-task progress
# → Shows completion across all phases
```

---

## Error Handling

**Task not found**:

```
Error: Task 7.5 not found in docs/specs/user-auth/tasks.md
Available tasks in Phase 7: 7.1, 7.2, 7.3, 7.4
```

**Ambiguous spec**:

```
Error: Cannot determine spec context.
Recent activity spans multiple specs: user-auth, users-permissions

Specify explicitly:
  /afx-task audit user-auth#7.1
  /afx-task audit users-permissions#3.2
```

**No tasks.md found**:

```
Error: No tasks.md found at docs/specs/user-auth/tasks.md

Check:
  1. Spec name is correct
  2. tasks.md exists in spec folder
  3. Use explicit path: /afx-task audit 7.1 path/to/tasks.md
```
