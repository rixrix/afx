---
name: afx-help
description: AFX command reference — lists all available commands, role-based workflow guides, and quick-start cheatsheet
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,help,reference,guides"
---

# /afx-help

AFX (AgenticFlowX) command reference.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

If neither file exists, use defaults. See `.afx/.afx.yaml` for all available options.

## Usage

```bash
/afx-help
/afx-help guides  # View role-based workflows (Dev, QA, Ops, etc.)
```

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace
- Display command reference and workflow guides

### Forbidden

- Create/modify/delete any files
- Run build/test/deploy/migration commands

If implementation is requested, respond with:

```text
Out of scope for /afx-help (read-only reference mode). Use the suggested command to proceed.
```

---

## Available Commands

### Context & Guidance

```bash
/afx-next                        # The "Golden Thread" - what to do next?
```

### Task Lifecycle

```bash
/afx-task plan <name>         # Generate tasks from approved design
/afx-task pick <id>           # Check out a task as active
/afx-task code <id>           # Implement task with @see traceability
/afx-task complete <id>       # Mark task done
/afx-task sync [spec] [issue] # Bidirectional GitHub sync
```

### Spec Lifecycle

```bash
/afx-spec create <name>                    # Scaffold + author spec.md
/afx-spec validate <name>                  # Check spec structure integrity
/afx-spec discuss <name>                   # Interactive gap analysis + journal
/afx-spec review <name>                    # Automated quality scoring
/afx-spec approve <name> [--reviewer "@handle"]  # Lifecycle gate
```

### Design Lifecycle

```bash
/afx-design author <name>                  # Generate design.md from approved spec
/afx-design validate <name>                # Check design structure and traceability
/afx-design review <name>                  # Advisory quality check for design gaps
/afx-design approve <name>                 # Approve design (unlocks task planning)
```

### Task Verification

```bash
/afx-task verify <task-id>     # Audit task implementation vs spec
/afx-task brief <task-id>      # Get implementation summary
/afx-task review <name>        # Check for planning gaps
```

### Quality Checks

```bash
/afx-check path <feature-path>   # Trace execution path UI → DB (Gate 1)
/afx-check trace [path]          # Audit annotations for PRD compliance
/afx-check links <spec-path>     # Verify cross-references
/afx-check deps [feature]        # Validate dependency graph
/afx-check coverage <spec-path>  # Spec-to-code coverage map
/afx-check all <feature-path>    # Run all checks
```

### Development Actions

```bash
/afx-dev debug [error]           # Debug with spec trace
/afx-dev refactor [scope]        # Refactor maintaining spec alignment
/afx-dev review [scope]          # Code review against specs
/afx-dev test [scope]            # Run/generate tests
/afx-dev optimize [target]       # Performance optimization
```

### Session Notes

```bash
/afx-session note "content" [tags]  # Smart Note (capture/append logic)
/afx-session log [feature]         # Save session to log
/afx-session recap [feature|all]    # AI synthesis for session resumption
/afx-session promote <id>           # Promote to ADR
```

### Reporting

```bash
/afx-report orphans [path]      # Find code without @see links
/afx-report coverage <spec>     # Spec → Code coverage map
/afx-report stale [days]        # Specs not updated recently
```

### Help & Guides

```bash
/afx-help guides                         # List all role-based guides
```

### Environment Check

```bash
/afx-hello                    # Verify AFX installation and environment
```

---

## Quick Reference

> **Human Cheatsheet**: [cheatsheet.md](../../docs/agenticflowx/cheatsheet.md)

| Command             | Purpose                    |
| ------------------- | -------------------------- |
| `/afx-next`         | "What do I do now?"        |
| `/afx-task pick`    | "What's next task?"        |
| `/afx-task verify`   | "Is task done correctly?"  |
| `/afx-check path`   | "Does code actually work?" |
| `/afx-session note` | "Remember this idea"       |
| `/afx-session log` | "Save this discussion"     |
| `/afx-hello`        | "Is AFX set up correctly?" |

---

## Typical Workflow

```
1. /afx-next                  # Check current state
2. /afx-task pick <id>        # Get next task assignment
3. /afx-task code <id>        # Implement with traceability
4. /afx-check path <path>     # Verify execution path
5. /afx-task verify <task>     # Audit task vs spec
6. /afx-session log          # Save session notes
```

## Quick Start / Cheatsheet

| I want to...              | Run...                            |
| :------------------------ | :-------------------------------- |
| **Start/Resume Work**     | `/afx-next` (Find context)        |
| **Pick Next Task**        | `/afx-task pick <id>`             |
| **Code Feature**          | `/afx-task code <id>`             |
| **Check It Runs**         | `/afx-check path <path>`          |
| **Check It Matches Spec** | `/afx-task verify <task-id>`       |
| **Log Discussion**        | `/afx-session note "content"`     |
| **Review Usage**          | `/afx-help`                       |

---

## Guides (Role-Based Workflows)

Run `/afx-help guides` to view these.

### 1. The "Feature Builder" (Developer)

**Goal**: Build a new requirement from scratch.

```bash
# 1. Get Task
/afx-task pick 1.1
# 2. Implement
/afx-task code 1.1
# 3. Verify
/afx-check path apps/webapp/claims
# 4. Audit
/afx-task verify 2.1
# 5. Log
/afx-session log
```

### 2. The "Bug Hunter" (Debugger)

**Goal**: Fix a reported bug.

```bash
# 1. Trace & Fix
/afx-dev debug "Submit button unresponsive"
# 2. Verify Fix
/afx-check path apps/webapp/claims
# 3. Ensure Compliance
/afx-task verify 2.1
```

### 3. The "Product Owner" (Ticket Creator)

**Goal**: Define new work (Task, Feature, Bug).

```bash
# New Task (from Spec)
/afx-task plan "Create phase 3 tasks"
# New Feature Spec
/afx-spec create "new-feature"
# New Bug Report
gh issue create --label "bug" --title "Fix login timeout"
```

### 4. The "Architect" (Planner)

**Goal**: Design system and ensure integrity.

```bash
# 1. Verify Spec Integrity
/afx-check links docs/specs/user-auth
# 2. Promote Decision
/afx-session promote user-auth UA-D001
```

### 5. The "Tester" (QA)

**Goal**: Quality assurance and sign-off.

```bash
# 1. Generate Tests
/afx-dev test packages/db
# 2. Verify Flows
/afx-check path apps/webapp/claims
# 3. Approve
/afx-task complete 2.1 "Verified edge cases"
```

### 6. The "Security Auditor" (SecOps)

**Goal**: Vulnerability assessment.

```bash
# 1. Find Orphans & TODOs
/afx-check trace
# 2. Review for Security
/afx-dev review security
# 3. Audit Scope
/afx-task verify 2.1
```

### 7. The "DevOps Engineer" (Ops)

**Goal**: Maintain project health.

```bash
# 1. Optimization
/afx-dev optimize "Claim submission query"
# 2. Find Orphaned Code
/afx-report orphans
# 3. Sync
/afx-task sync user-auth
```

---

## Command Categories

| Category    | Commands | Purpose                         |
| ----------- | -------- | ------------------------------- |
| **Spec**    | spec     | Spec authoring and review       |
| **Design**  | design   | Design authoring and review     |
| **Task**    | task     | Implementation lifecycle        |
| **Dev**     | dev      | Development actions             |
| **Check**   | check    | Quality gates and compliance    |
| **Session** | session  | Session discussion capture      |
| **Report**  | report   | Traceability metrics            |
| **Hello**   | hello    | Environment and install check   |
| **Help**    | help     | This reference                  |

---

## See Also

- [AFX Manual](../../docs/agenticflowx/agenticflowx.md) - Full AFX documentation
- [CLAUDE.md](../../CLAUDE.md) - Project coding standards
