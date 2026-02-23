# AFX Combined CLAUDE.md Snippet

> Copy everything below this line into your CLAUDE.md file.

---

## Documentation References (Living Documentation Traceability)

> **AFX**: Bidirectional code↔spec linking ensures AI agents maintain alignment with specifications.

All spec-driven files MUST have a top-level JSDoc with `@see` references linking back to the relevant spec documents.

**Required for:**

| File Type         | Required Links                                            |
| ----------------- | --------------------------------------------------------- |
| `*.repository.ts` | design.md section + tasks.md task number                  |
| `*.service.ts`    | design.md section + tasks.md task number                  |
| `*.action.ts`     | design.md section + tasks.md task number (if spec-driven) |
| `*.model.ts`      | design.md section (if spec-driven)                        |
| `*.constants.ts`  | research doc or design.md (if decision-driven)            |

**Format:**

```typescript
/**
 * [Brief description]
 *
 * @see docs/specs/[feature]/design.md#[section]
 * @see docs/specs/[feature]/tasks.md#[task-number]
 */
```

**Example:**

```typescript
/**
 * User Repository Interface
 *
 * @see docs/specs/user-auth/design.md#repository-implementation
 * @see docs/specs/user-auth/tasks.md#21-create-repository-interface
 */
```

**Anchor Format:**

- **Section anchors:** Use kebab-case matching heading text (e.g., `#repository-implementation`)
- **Task anchors:** Use pattern `#XY-task-description` where X is phase, Y is task number (e.g., `#21-create-repository-interface`)
- **Research anchors:** Link directly to research file (e.g., `research/decision-name.md`)

**Inline Annotations:**

Use standard annotation format + `@see` link. **At least one link MUST point to a spec** (`docs/specs/`). External links are optional.

```typescript
// ❌ BAD: Orphaned TODO
// TODO: implement pagination

// ✅ GOOD: Spec link required
// TODO: Implement pagination for claim history
// @see docs/specs/feature/tasks.md#42-pagination
```

Standard annotations: `TODO`, `FIXME`, `XXX`, `HACK`, `NOTE`, `BUG`, `OPTIMIZE`, `REVIEW`

### AFX Frontmatter Schema

All AFX-managed files use YAML frontmatter for Obsidian/Dataview compatibility. The `afx: true` marker identifies AFX-owned documents.

**Full Schema (SPEC, DESIGN, TASKS):**

```yaml
---
afx: true # AFX ownership marker (required)
type: SPEC # Document type (required)
status: Draft # Draft | Approved | Living
owner: "@handle" # GitHub handle
priority: High # High | Medium | Low (SPEC only)
version: 1.0 # Semantic versioning
created: YYYY-MM-DDTHH:MM:SSZ # ISO 8601 creation timestamp
last_verified: YYYY-MM-DD # Last review date
tags: [feature, topic] # Content tags (Obsidian convention)
---
```

**Minimal Schema (COMMAND, JOURNAL):**

```yaml
---
afx: true
type: COMMAND
status: Living
tags: [afx, command, topic]
---
```

**Document Types:**

| Type      | Purpose               | Location                                                     |
| --------- | --------------------- | ------------------------------------------------------------ |
| `SPEC`    | Feature specification | docs/specs/{feature}/spec.md                                 |
| `DESIGN`  | Technical design      | docs/specs/{feature}/design.md                               |
| `TASKS`   | Implementation tasks  | docs/specs/{feature}/tasks.md                                |
| `JOURNAL` | Session log           | docs/specs/{feature}/journal.md                              |
| `RES`     | Research/exploration  | docs/specs/{feature}/research/\*.md                          |
| `ADR`     | Architecture decision | docs/adr/ (global) or docs/specs/{feature}/research/ (local) |

## AgenticFlowX - Session Continuity

This project uses **AgenticFlowX (AFX)** for spec-driven development with session continuity. GitHub tickets serve as living execution logs, not just task lists.

### Core Principle

The spec tells you _what_ to build. The GitHub ticket tells you _where you left off_.

### Session Continuity Rules

**CRITICAL**: After completing work on a GitHub ticket, ALWAYS update:

1. **Session Log**: Add timestamped entry with task, action, files modified
2. **Discovered Issues**: Document any unexpected findings
3. **Decisions Made**: Record rationale for choices
4. **Subtask Checkboxes**: Mark completed items

### Agent Resumption Workflow

When starting or resuming work on a ticket:

1. **READ** GitHub ticket - see current state, what's done, what's pending
2. **CHECK** Session Log - understand last session's work
3. **CHECK** Discovered Issues - see pending edge cases
4. **READ** linked spec/design - get exact values, interfaces, patterns
5. **CONTINUE** from next unchecked subtask
6. **UPDATE** Session Log when done

### Global vs Feature Context (UI/UX)

- **Global Brain (`CLAUDE.md`)**: Contains your system-wide design tokens (e.g., "Use Tailwind", "Use Shadcn components", "Brand colors").
- **Feature Brain (`docs/specs/*/design.md`)**: Contains the specific component composition and visual layout for the current feature.
  **Rule:** ALWAYS check `CLAUDE.md` for global UI constraints before implementing a feature's local design spec. Do not define global component library rules inside local feature specs.

### Commands

**Discovery**

- `/afx:discover capabilities` - High-level project overview (what exists)
- `/afx:discover infra [type]` - Find infrastructure provisioning scripts
- `/afx:discover scripts [keyword]` - Find automation/deployment scripts
- `/afx:discover tools` - List dev/deployment tools

**Work Orchestration**

- `/afx:work status` - Quick state check after interruption
- `/afx:work next <spec-path>` - Pick next task from spec
- `/afx:work resume [spec|num]` - Continue in-progress work
- `/afx:work sync [spec] [issue]` - Bidirectional GitHub sync
- `/afx:work plan [instruction]` - Generate tickets from specs

**Task Verification**

- `/afx:task verify <task-id>` - Verify task implementation vs spec
- `/afx:task summary <task-id>` - Get implementation summary
- `/afx:task list [phase]` - List tasks by phase
- `/afx:task status` - Overall task completion

**Quality Checks**

- `/afx:check path <feature-path>` - Trace execution path UI → DB (Gate 1)
- `/afx:check lint [path]` - Audit annotations for PRD compliance
- `/afx:check links <spec-path>` - Verify cross-references
- `/afx:check all <feature-path>` - Run all checks

**Development Actions**

- `/afx:dev code [instruction]` - Implement with @see traceability
- `/afx:dev debug [error]` - Debug with spec trace
- `/afx:dev refactor [scope]` - Refactor maintaining spec alignment
- `/afx:dev review [scope]` - Code review against specs
- `/afx:dev test [scope]` - Run/generate tests

**Session Capture**

- `/afx:session note "content" [tags]` - Smart note (unifies capture/append)
- `/afx:session save [feature]` - Save session to log
- `/afx:session show [feature|all]` - Show recent discussions
- `/afx:session search "query"` - Search notes across journals
- `/afx:session recap [feature|all]` - Recap for resumption
- `/afx:session promote <id>` - Promote discussion to ADR
- `/afx:next` - Context-aware "Golden Thread" guidance

**Reporting**

- `/afx:report health [spec]` - Overall traceability metrics
- `/afx:report orphans [path]` - Code without @see links
- `/afx:report coverage <spec>` - Spec → Code coverage map

**Setup & Context**

- `/afx:init feature <name>` - Create new feature spec
- `/afx:init adr <title>` - Create global ADR in `docs/adr/`
- `/afx:context save [feature]` - Generate context bundle
- `/afx:context load` - Load context from previous context
- `/afx:help` - Show command reference

### Session Discussion Capture

Use `/afx:session` to capture important discussions with AI agents:

```bash
/afx:next                                  # "What do I do now?"
/afx:session note "content"                # Smart note (auto-tags)
/afx:session note --ref UA-D001 "content"  # Append to discussion
/afx:session save [feature]                # Summarize session to log
/afx:session show [feature|all]            # Show recent discussions
/afx:session search "query"                # Search notes
/afx:session promote <id>                  # Promote to ADR
```

Discussions are stored in `docs/specs/{feature}/journal.md` with auto-generated tags for filtering.
