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

All AFX commands use two-tier config resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).
See `.afx/.afx.yaml` for all available options.

## Usage

```bash
/afx-help
/afx-help guides  # View role-based workflows (Dev, QA, Ops, etc.)
```

## Available Commands

### Context & Guidance

```bash
/afx-next                        # The "Golden Thread" - what to do next?
```

### Work Orchestration

```bash
/afx-work status              # Quick state check after interruption
/afx-work next <spec-path>    # Pick next task from spec
/afx-work resume [spec|num]   # Continue in-progress work
/afx-work sync [spec] [issue] # Bidirectional GitHub sync
/afx-work plan [instruction]  # Generate tickets OR update feature spec
```

### Task Verification

```bash
/afx-task audit <task-id>        # Audit task implementation vs spec
/afx-task summary <task-id>      # Get implementation summary
/afx-task list [phase]           # List tasks by phase
/afx-task progress               # Overall task completion
```

### Quality Checks

```bash
/afx-check path <feature-path>   # Trace execution path UI → DB (Gate 1)
/afx-check lint [path]           # Audit annotations for PRD compliance
/afx-check links <spec-path>     # Verify cross-references
/afx-check all <feature-path>    # Run all checks
```

### Development Actions

```bash
/afx-dev code [instruction]      # Implement with @see traceability
/afx-dev debug [error]           # Debug with spec trace
/afx-dev refactor [scope]        # Refactor maintaining spec alignment
/afx-dev review [scope]          # Code review against specs
/afx-dev test [scope]            # Run/generate tests
/afx-dev optimize [target]       # Performance optimization
```

### Session Notes

```bash
/afx-session note "content" [tag] # Smart Note (capture/append logic)
/afx-session save [feature]       # Save session to log (formerly record)
/afx-session show [feature|all]   # Display recent discussions
/afx-session recap [feature|all]  # Multi-topic summary
/afx-session promote <id>         # Promote to ADR
```

### Help & Guides

```bash
/afx-help guides                         # List all role-based guides
```

### Framework Maintenance

```bash
/afx-update check [--repo owner/repo --ref branch]  # Check local vs upstream AFX version
/afx-update apply [flags]                            # Apply AFX update via installer
```

---

## Quick Reference

> **Human Cheatsheet**: [cheatsheet.md](../../docs/agenticflowx/cheatsheet.md)

| Command             | Purpose                    |
| ------------------- | -------------------------- |
| `/afx-next`         | "What do I do now?"        |
| `/afx-work status`  | "Where was I?"             |
| `/afx-work next`    | "What's next task?"        |
| `/afx-task audit`   | "Is task done correctly?"  |
| `/afx-check path`   | "Does code actually work?" |
| `/afx-session note` | "Remember this idea"       |
| `/afx-session save` | "Save this discussion"     |
| `/afx-update check` | "Is AFX up to date?"       |

---

## Typical Workflow

```
1. /afx-work status           # Check current state
2. /afx-work next <spec>      # Get next task assignment
3. /afx-dev code              # Implement with traceability
4. /afx-check path <path>     # Verify execution path
5. /afx-task audit <task>     # Audit task vs spec
6. /afx-session record        # Save session notes
```

## Quick Start / Cheatsheet

| I want to...              | Run...                            |
| :------------------------ | :-------------------------------- |
| **Start/Resume Work**     | `/afx-work status` (Find context) |
| **Pick Next Task**        | `/afx-work next <spec>`           |
| **Code Feature**          | `/afx-dev code`                   |
| **Check It Runs**         | `/afx-check path <path>`          |
| **Check It Matches Spec** | `/afx-task audit <task-id>`       |
| **View Progress**         | `/afx-task progress`              |
| **Log Discussion**        | `/afx-session capture "note"`     |
| **Review Usage**          | `/afx-help`                       |

---

## Guides (Role-Based Workflows)

Run `/afx-help guides` to view these.

### 1. The "Feature Builder" (Developer)

**Goal**: Build a new requirement from scratch.

```bash
# 1. Get Task
/afx-work next user-auth
# 2. Implement
/afx-dev code "Implement claim form"
# 3. Verify
/afx-check path apps/webapp/claims
# 4. Audit
/afx-task audit 2.1
# 5. Log
/afx-session record
```

### 2. The "Bug Hunter" (Debugger)

**Goal**: Fix a reported bug.

```bash
# 1. Trace & Fix
/afx-dev debug "Submit button unresponsive"
# 2. Verify Fix
/afx-check path apps/webapp/claims
# 3. Ensure Compliance
/afx-task audit 2.1
```

### 3. The "Product Owner" (Ticket Creator)

**Goal**: Define new work (Task, Feature, Bug).

```bash
# New Task (from Spec)
/afx-work plan "Create phase 3 tasks"
# New Feature Spec
/afx-init spec "new-feature"
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
/afx-work approve user-auth 2.1 "Verified edge cases"
```

### 6. The "Security Auditor" (SecOps)

**Goal**: Vulnerability assessment.

```bash
# 1. Find Orphans & TODOs
/afx-check lint
# 2. Review for Security
/afx-dev review security
# 3. Audit Scope
/afx-task audit 2.1
```

### 7. The "DevOps Engineer" (Ops)

**Goal**: Maintain project health.

```bash
# 1. Optimization
/afx-dev optimize "Claim submission query"
# 2. Health Check
/afx-report health
# 3. Sync
/afx-work sync user-auth
```

---

## Command Categories

| Category    | Commands | Purpose                        |
| ----------- | -------- | ------------------------------ |
| **Work**    | work     | Work orchestration             |
| **Task**    | task     | Task verification against spec |
| **Check**   | check    | Quality gates and compliance   |
| **Dev**     | dev      | Development actions            |
| **Session** | session  | Session discussion capture     |
| **Update**  | update   | Framework maintenance          |
| **Help**    | help     | This reference                 |

---

## See Also

- [AFX Manual](../../docs/agenticflowx/agenticflowx.md) - Full AFX documentation
- [CLAUDE.md](../../CLAUDE.md) - Project coding standards
