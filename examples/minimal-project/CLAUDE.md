# CLAUDE.md - Example Project

This is a minimal example project using AFX (AgenticFlowX) for spec-driven development.

## Project Overview

A simple example demonstrating AFX workflow integration.

## Documentation References (Living Documentation Traceability)

All spec-driven files MUST have a top-level JSDoc with `@see` references linking back to the relevant spec documents.

**Required for:**

| File Type      | Required Links                           |
| -------------- | ---------------------------------------- |
| `*.service.ts` | design.md section + tasks.md task number |
| `*.action.ts`  | design.md section + tasks.md task number |

**Format:**

```typescript
/**
 * [Brief description]
 *
 * @see docs/specs/[feature]/design.md#[section]
 * @see docs/specs/[feature]/tasks.md#[task-number]
 */
```

**Anchor Format:**

- **Section anchors:** Use kebab-case matching heading text (e.g., `#data-model`)
- **Task anchors:** Use pattern `#XY-task-description` (e.g., `#21-create-service`)

Standard annotations: `TODO`, `FIXME`, `XXX`, `HACK`, `NOTE`, `BUG`, `OPTIMIZE`, `REVIEW`

## AgenticFlowX - Session Continuity

This project uses **AgenticFlowX (AFX)** for spec-driven development.

### Core Principle

The spec tells you _what_ to build. The GitHub ticket tells you _where you left off_.

### Commands

**Discovery**

- `/afx-discover capabilities` - Understand project setup (what exists)
- `/afx-discover infra [type]` - Find infrastructure/provisioning scripts
- `/afx-discover scripts [keyword]` - Find automation/deployment scripts

**Work Orchestration**

- `/afx-work status` - Quick state check
- `/afx-work next <spec-path>` - Pick next task from spec
- `/afx-next` - Context-aware guidance

**Quality Checks**

- `/afx-check path <feature-path>` - Trace execution path (BLOCKING gate)
- `/afx-check lint [path]` - Audit annotations

**Development**

- `/afx-dev code [instruction]` - Implement with @see traceability
- `/afx-init feature <name>` - Create new feature spec

**Session**

- `/afx-session note "content"` - Capture notes
- `/afx-session save [feature]` - Save session to journal
- `/afx-help` - Show all commands
