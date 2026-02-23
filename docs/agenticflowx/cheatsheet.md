---
afx: true
type: GUIDE
status: Living
tags: [afx, reference, cheatsheet]
---

# AFX Command Cheatsheet

> One-page reference for the AgenticFlowX workflow.

## The Golden Rule

| Command     | When to use         |
| :---------- | :------------------ |
| `/afx:next` | **Whenever stuck.** |

---

## Phase 1: Plan & Init

| Goal                    | Command                           | Notes                                |
| :---------------------- | :-------------------------------- | :----------------------------------- |
| **New Feature**         | `/afx:init feature <name>`        | Creates full scaffold (`docs/specs`) |
| **New ADR**             | `/afx:init adr <title>`           | Creates global ADR in `docs/adr/`    |
| **Discover Project**    | `/afx:discover capabilities`      | Understand existing setup            |
| **Find Infrastructure** | `/afx:discover infra [type]`      | Locate provisioning scripts          |
| **Find Scripts**        | `/afx:discover scripts [keyword]` | Find automation/deployment scripts   |
| **New Tasks**           | `/afx:work plan "Add search"`     | Generates tasks from spec            |
| **Resume Work**         | `/afx:work status`                | "Where was I?" (After break)         |
| **Pick Task**           | `/afx:work next <spec>`           | Assigns next unchecked task          |

---

## Phase 2: Develop (The Loop)

**Cycle**: Assign Task (`work next`) → Code (`dev code`) → Verify (`check path`)

| Goal             | Command                       | Notes                                  |
| :--------------- | :---------------------------- | :------------------------------------- |
| **Implement**    | `/afx:dev code`               | Write code. **Must** add `@see` links. |
| **Debug**        | `/afx:dev debug <error>`      | Trace error against spec.              |
| **Refactor**     | `/afx:dev refactor`           | Clean code, preserve `@see` links.     |
| **Capture Idea** | `/afx:session note "content"` | Save thought without stopping.         |
| **Save Context** | `/afx:session save`           | Summarize discussion to `journal.md`.  |

---

## Phase 3: Verify (Quality Gates)

**Gate 1 (Blocking)**: `/afx:check path` must pass before marking complete.

| Goal              | Command                     | Notes                                   |
| :---------------- | :-------------------------- | :-------------------------------------- |
| **Check Runtime** | `/afx:check path <path>`    | **Mandatory**. Traces execution flow.   |
| **Audit Task**    | `/afx:task audit <task-id>` | Static check: Does file match spec?     |
| **Lint Specs**    | `/afx:check lint`           | Find orphaned code (missing `@see`).    |
| **Verify Links**  | `/afx:check links <spec>`   | Ensure specs don't have broken anchors. |

---

## Phase 4: Ship & Context

| Goal             | Command                             | Notes                                  |
| :--------------- | :---------------------------------- | :------------------------------------- |
| **Human Verify** | `/afx:work approve <task> "note"`   | Mark task as human-verified.           |
| **Close Issue**  | `/afx:work close <issue> "summary"` | Updates docs, syncing logs, closes.    |
| **Context**      | `/afx:context save`                 | Bundle context for next agent/session. |
| **Load Context** | `/afx:context load`                 | Load context from previous agent.      |

---

## Reference: Annotations

All code MUST link back to specs (PRDs).

```typescript
// TODO: Implement search filter
// @see docs/specs/user-auth/tasks.md#7.4-filters

export function search() { ... }
// @see docs/specs/user-auth/design.md#search-api
```

## File Layout

```text
docs/adr/                  # Global ADRs (cross-cutting decisions)
├── ADR-0001-slug.md
└── ...

docs/specs/{feature}/      # Feature specs
├── spec.md       # Requirements (What)
├── design.md     # Architecture (How)
├── tasks.md      # Checklist (Progress)
├── journal.md    # Discussion Log (History)
└── research/     # Feature-local decisions (ADRs)
```
