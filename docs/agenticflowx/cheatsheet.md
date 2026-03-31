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
| `/afx-next` | **Whenever stuck.** |

---

## Phase 1: Plan & Init

| Goal                    | Command                           | Notes                                 |
| :---------------------- | :-------------------------------- | :------------------------------------ |
| **New Feature**         | `/afx-init feature <name>`        | Creates full scaffold (`docs/specs`)  |
| **New ADR**             | `/afx-init adr <title>`           | Creates global ADR in `docs/adr/`     |
| **Discover Project**    | `/afx-discover capabilities`      | Understand existing setup             |
| **Find Infrastructure** | `/afx-discover infra [type]`      | Locate provisioning scripts           |
| **Find Scripts**        | `/afx-discover scripts [keyword]` | Find automation/deployment scripts    |
| **Diagnostics**         | `/afx-hello`                      | Verify AFX installation & environment |

---

## Phase 2: Design

| Goal         | Command                | Notes                               |
| :----------- | :--------------------- | :---------------------------------- |
| **Author**   | `/afx-design author`   | Draft design doc from approved spec |
| **Validate** | `/afx-design validate` | Check design completeness           |
| **Review**   | `/afx-design review`   | Review design against spec          |
| **Approve**  | `/afx-design approve`  | Mark design as approved             |

---

## Phase 3: Task Planning & Execution (The Loop)

**Cycle**: Plan Tasks (`task plan`) -> Pick Task (`task pick`) -> Code (`task code`) -> Verify (`task verify`)

| Goal              | Command                       | Notes                                  |
| :---------------- | :---------------------------- | :------------------------------------- |
| **Plan Tasks**    | `/afx-task plan`              | Generate tasks from approved design    |
| **Pick Task**     | `/afx-task pick <spec>`       | Assigns next unchecked task            |
| **Implement**     | `/afx-task code`              | Write code. **Must** add `@see` links. |
| **Verify Task**   | `/afx-task verify <task-id>`  | Static check: Does file match spec?    |
| **Complete Task** | `/afx-task complete <task>`   | Mark task as complete                  |
| **Sync**          | `/afx-task sync`              | Bidirectional GitHub sync              |
| **Brief**         | `/afx-task brief <task-id>`   | Get implementation summary             |
| **Review**        | `/afx-task review`            | Review task implementation             |
| **Capture Idea**  | `/afx-session note "content"` | Save thought without stopping.         |
| **Save Context**  | `/afx-session log`            | Summarize discussion to `journal.md`.  |

---

## Phase 4: Develop (Supporting)

| Goal         | Command                  | Notes                              |
| :----------- | :----------------------- | :--------------------------------- |
| **Debug**    | `/afx-dev debug <error>` | Trace error against spec.          |
| **Refactor** | `/afx-dev refactor`      | Clean code, preserve `@see` links. |
| **Review**   | `/afx-dev review`        | Code review against specs.         |
| **Test**     | `/afx-dev test`          | Run/generate tests.                |
| **Optimize** | `/afx-dev optimize`      | Performance optimization.          |

---

## Phase 5: Verify (Quality Gates)

**Gate 1 (Blocking)**: `/afx-check path` must pass before marking complete.

| Goal              | Command                      | Notes                                   |
| :---------------- | :--------------------------- | :-------------------------------------- |
| **Check Runtime** | `/afx-check path <path>`     | **Mandatory**. Traces execution flow.   |
| **Audit Task**    | `/afx-task verify <task-id>` | Static check: Does file match spec?     |
| **Lint Specs**    | `/afx-check trace`           | Find orphaned code (missing `@see`).    |
| **Verify Links**  | `/afx-check links <spec>`    | Ensure specs don't have broken anchors. |
| **Check Deps**    | `/afx-check deps`            | Verify dependency constraints.          |
| **Coverage**      | `/afx-check coverage`        | Spec-to-code coverage analysis.         |

---

## Phase 6: Ship & Context

| Goal             | Command             | Notes                                  |
| :--------------- | :------------------ | :------------------------------------- |
| **Where am I?**  | `/afx-next`         | Context-aware next action guidance.    |
| **Context**      | `/afx-context save` | Bundle context for next agent/session. |
| **Load Context** | `/afx-context load` | Load context from previous agent.      |

---

## Reference: Annotations

All code MUST link back to specs (PRDs).

```typescript
// TODO: Implement search filter
// @see docs/specs/user-auth/tasks.md [FR-1]

export function search() { ... }
// @see docs/specs/user-auth/design.md [DES-API]
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
