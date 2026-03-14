---
afx: true
type: TASKS
status: Living
owner: '@owner'
version: 1.0
created: '{YYYY-MM-DDTHH:MM:SS.mmmZ}'
last_verified: '{YYYY-MM-DDTHH:MM:SS.mmmZ}'
tags: ['{feature}']
spec: spec.md
design: design.md
---

# {Feature Name} - Implementation Tasks

---

## Task Numbering Convention

Tasks use hierarchical numbering for cross-referencing:

- **0.x** - Pre-implementation cleanup (if needed)
- **1.x** - {Phase 1 name}
- **2.x** - {Phase 2 name}
- **3.x** - {Phase 3 name}
- **n.x** - {Continue as needed}

References:

- `[REQ-FR-1]` = Functional Requirement 1 from spec.md
- `[DESIGN-3.1]` = Section 3.1 from design.md

---

## Phase 0: Pre-Implementation Cleanup

> Optional. Include only if cleanup is needed before implementation.

### 0.1 {Cleanup Task Name}

- [ ] {Task item}
- [ ] {Task item}

---

## Phase 1: {Phase Name}

> GitHub Issue #XX | Ref: [DESIGN-X.X], [REQ-FR-X]

### 1.1 {Task Group Name}

> File: `path/to/file.ts` (if applicable)

- [ ] {Task item}
- [ ] {Task item}
- [ ] {Task item}

### 1.2 {Task Group Name}

- [ ] {Task item}
- [ ] {Task item}

---

## Phase 2: {Phase Name}

> GitHub Issue #XX | Ref: [DESIGN-X.X], [REQ-FR-X]

### 2.1 {Task Group Name}

- [ ] {Task item}
- [ ] {Task item}

### 2.2 {Task Group Name}

- [ ] {Task item}
- [ ] {Task item}

---

## Phase N: {Additional Phases}

> Add more phases as needed following the same pattern.

---

## Implementation Flow

```
Phase 0: Pre-Implementation (if needed)
    ↓
Phase 1: {Phase 1 name}
    ↓
Phase 2: {Phase 2 name}
    ↓
Phase N: {Continue as needed}
```

---

## Cross-Reference Index

| Task | Spec Requirement | Design Section |
| ---- | ---------------- | -------------- |
| 1.x  | FR-1, FR-2       | 3.1            |
| 2.x  | FR-3, FR-4       | 3.2, 3.3       |
| n.x  | {Requirements}   | {Sections}     |

---

## Notes

- Tasks are marked complete (`[x]`) as implementation progresses
- GitHub issue numbers are added when issues are created
- Cross-references help trace requirements → design → implementation

---

## Work Sessions

<!-- Task execution log — updated by /afx-work, /afx-dev -->

| Date | Task | Action | Files Modified | Agent | Human |
| ---- | ---- | ------ | -------------- | ----- | ----- |
