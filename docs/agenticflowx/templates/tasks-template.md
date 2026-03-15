---
afx: true
type: TASKS
status: Living
owner: "@handle"
version: 2.0
last_verified: YYYY-MM-DD
---

# Feature Name - Implementation Tasks

**Version:** 2.0
**Date:** YYYY-MM-DD
**Status:** Planning
**Spec:** [spec.md](./spec.md)
**Design:** [design.md](./design.md)

> This document follows a Work Breakdown Structure (WBS). Every task MUST link back to the spec or design via `@see`. Tasks cannot be marked `[x]` (complete) until path-verification passes (`/afx-check path`).

---

## Implementation Order

| Priority | Phase | Description | Status |
| -------- | ----- | ----------- | ------ |
| **1** | **Phase 1** | **[High-level phase description]** | **Active** |
| 1.1   | Phase 1.1   | [Specific component/service task]  | Pending |
| 1.2   | Phase 1.2   | [Specific component/service task]  | Pending |
| **2** | **Phase 2** | **[High-level phase description]** | **Pending** |
| -     | Phase 3     | [Backlog / Future task]            | Backlog |

---

## Phase 1: [Phase Overview Name]

> **Goal:** [What should be achieved when this phase is done?]
> **Design Ref:** [Link to anchor in design.md]

### 1.1 [Task Component/File Name]

- [ ] **Data layer**: Update `schema.sql` or `schema.prisma`.
- [ ] **Service layer**: Create `feature.service.ts` logic.
- [ ] **UI layer**: Wire frontend component to `feature.action.ts`.
- [ ] **Testing**: Create/Update unit tests.

### 1.2 [Another Task Name]

- [ ] [Subtask 1]
- [ ] [Subtask 2]

---

## Phase 2: [Another Phase Name]

> **Goal:** [What should be achieved when this phase is done?]

### 2.1 [Task Name]

- [ ] [Subtask implementation checklist]

---

## Verification & Handoff

- [ ] All code contains `@see` backlinks to the target `tasks.md` phase or `spec.md` FR.
- [ ] `/afx-check path` executed and passed for all major execution routes.
- [ ] Feature flagged appropriately (if required).
- [ ] E2E/Unit tests complete.
