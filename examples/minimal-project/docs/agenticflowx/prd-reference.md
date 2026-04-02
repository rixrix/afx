---
afx: true
type: FRAMEWORK
status: Living
owner: "@rix"
version: "1.0"
created_at: "2026-03-31T00:00:00.000Z"
updated_at: "2026-03-31T00:00:00.000Z"
tags: ["framework", "prd", "reference", "templates"]
---

# AFX PRD Technical Reference

> The definitive guide to AgenticFlowX's spec-driven file system.
> Covers file anatomy, frontmatter schemas, Node ID syntax, traceability flow, and standards lineage.

---

## File System Overview

Every AFX feature lives in `docs/specs/{feature-name}/` and follows a strict 4-file structure:

```
docs/specs/{feature-name}/
├── spec.md        ← Requirements (WHAT to build)
├── design.md      ← Architecture (HOW to build it)
├── tasks.md       ← Implementation checklist (WHEN/WHO builds it)
├── journal.md     ← Session log & discussion history
└── research/      ← ADRs and research artifacts
```

### Traceability Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ spec.md  │────▶│design.md │────▶│ tasks.md │────▶│  Code    │
│          │     │          │     │          │     │          │
│ [FR-1]   │     │ [DES-API]│     │ [1.1]    │     │ @see ... │
│ [FR-2]   │     │ [DES-DB] │     │ [1.2]    │     │ @see ... │
│ [NFR-1]  │     │          │     │ [2.1]    │     │          │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
      ▲                ▲                ▲                │
      │                │                │                │
      └────────────────┴────────────────┴────────────────┘
                    Backlinks (frontmatter + @see)
```

**Forward links** (→): Requirements trace forward into design sections, then into task IDs, then into code via `@see` annotations.

**Backlinks** (←): Each file's frontmatter contains `spec:` and `design:` fields pointing back to its parent. Code uses `@see docs/specs/{feature}/design.md [DES-ID]` annotations.

---

## Standards Lineage

AFX's template system is a pragmatic hybrid of established industry standards:

| Standard                                                                        | Origin                     | Used In            | How AFX Applies It                                                            |
| ------------------------------------------------------------------------------- | -------------------------- | ------------------ | ----------------------------------------------------------------------------- |
| [IEEE 830 / ISO/IEC/IEEE 29148](https://standards.ieee.org/ieee/29148/6937/)    | IEEE, 1998                 | `spec.md`          | Adapted SRS structure for agile feature-level specs                           |
| [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method)                           | Dai Clegg, 1994 (DSDM)     | `spec.md` FR table | Requirement prioritization: Must Have / Should Have / Could Have / Won't Have |
| [User Stories](https://www.mountaingoatsoftware.com/agile/user-stories)         | Mike Cohn / XP (Connextra) | `spec.md`          | "As a [role], I want [feature], So that [benefit]"                            |
| [C4 Model](https://c4model.com/)                                                | Simon Brown                | `design.md`        | System Context + Component diagrams                                           |
| [ADR](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | Michael Nygard, 2011       | `research/*.md`    | Architecture Decision Records: Context → Decision → Consequences              |
| [WBS](https://en.wikipedia.org/wiki/Work_breakdown_structure)                   | PMI PMBOK Guide            | `tasks.md`         | Hierarchical decimal numbering (1.1, 2.3) for task decomposition              |
| [Traceability Matrix](https://standards.ieee.org/ieee/29148/6937/)              | IEEE 830 / DO-178C         | `tasks.md`         | Cross-Reference Index mapping Requirements → Design → Code                    |

---

## Frontmatter Schema

All AFX artifacts use YAML frontmatter with a canonical field order. Double quotes only. No mixed styles.

### Canonical Field Order

```
afx → type → status → owner → version → created_at → updated_at → tags → [depends_on] → [backlinks]
```

### Field Definitions

| Field           | Type     | Required            | Description                                                     |
| --------------- | -------- | ------------------- | --------------------------------------------------------------- |
| `afx`           | boolean  | All files           | Always `true`. Marks the file as AFX-managed.                   |
| `type`          | enum     | All files           | `SPEC` \| `DESIGN` \| `TASKS` \| `JOURNAL` \| `ADR` \| `RES`    |
| `status`        | enum     | All files           | `Draft` \| `Approved` \| `Living`                               |
| `owner`         | string   | All files           | GitHub handle of the responsible person (e.g., `"@rix"`)        |
| `version`       | string   | spec, design, tasks | Semantic version as a quoted string (e.g., `"1.0"`)             |
| `created_at`    | ISO 8601 | All files           | Creation timestamp with ms precision. Immutable after creation. |
| `updated_at`    | ISO 8601 | All files           | Last modification timestamp with ms precision.                  |
| `tags`          | string[] | All files           | Feature name + topic tags for filtering                         |
| `depends_on`    | string[] | Optional (spec)     | Cross-spec feature folder names for dependency graph            |
| `spec`          | path     | design, tasks       | Relative backlink to parent `spec.md`                           |
| `design`        | path     | tasks only          | Relative backlink to parent `design.md`                         |
| `superseded_by` | string   | Optional (ADR)      | ID of the ADR that replaces this one                            |

### Per-Artifact Examples

**spec.md**

```yaml
---
afx: true
type: SPEC
status: Draft
owner: "@rix"
version: "1.0"
created_at: "2026-03-31T14:30:00.000Z"
updated_at: "2026-03-31T14:30:00.000Z"
tags: ["user-auth"]
depends_on:
  - marketplace-auth
---
```

**design.md**

```yaml
---
afx: true
type: DESIGN
status: Draft
owner: "@rix"
version: "1.0"
created_at: "2026-03-31T14:30:00.000Z"
updated_at: "2026-03-31T14:30:00.000Z"
tags: ["user-auth"]
spec: spec.md
---
```

**tasks.md**

```yaml
---
afx: true
type: TASKS
status: Draft
owner: "@rix"
version: "1.0"
created_at: "2026-03-31T14:30:00.000Z"
updated_at: "2026-03-31T14:30:00.000Z"
tags: ["user-auth"]
spec: spec.md
design: design.md
---
```

---

## Node ID System

### Why Node IDs?

Markdown heading anchors (`#api-contracts`) are brittle — renaming a heading breaks all links. Node IDs are immutable, deterministic, and trivially parseable by regex.

### Node ID Types

| Artifact  | Format     | Example                                |
| --------- | ---------- | -------------------------------------- |
| spec.md   | `[FR-N]`   | `[FR-1]`, `[FR-12]`                    |
| spec.md   | `[NFR-N]`  | `[NFR-1]`, `[NFR-5]`                   |
| design.md | `[DES-ID]` | `[DES-API]`, `[DES-DATA]`, `[DES-SEC]` |
| tasks.md  | `[X.Y]`    | `[1.1]`, `[2.3]`, `[0.1]`              |

### Rules

- **Scope**: Node IDs are unique **per-file**. `[FR-1]` in `user-auth/spec.md` and `[FR-1]` in `marketplace/spec.md` are distinct — the file path disambiguates.
- **Immutability**: Once assigned, a Node ID should not change. If a design section is renamed, the `[DES-ID]` stays the same.
- **No duplicates**: Two sections in the same file cannot share a Node ID. Skills that generate content (`afx-design author`, `afx-task plan`) must check for existing IDs before assigning new ones.

### Where Node IDs Appear

**In spec.md** — FR/NFR table rows:

```markdown
| ID   | Requirement                | Priority  |
| ---- | -------------------------- | --------- |
| FR-1 | User can log in with email | Must Have |
| FR-2 | Password reset via email   | Must Have |
```

**In design.md** — section headings:

```markdown
## [DES-API] API Contracts

## [DES-DATA] Data Model

## [DES-SEC] Security Considerations
```

**In tasks.md** — task group headings:

```markdown
### 1.1 Create Database Schema

### 2.3 Implement Login Endpoint
```

---

## @see Traceability

### Syntax

```
@see <file-path> [NODE-ID]
```

The file path is relative to the project root. The Node ID is enclosed in brackets, separated by a space.

### Examples

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

### Annotation Granularity

| Level    | When to Use                                      | Example                             |
| -------- | ------------------------------------------------ | ----------------------------------- |
| Class    | Always for exported classes/interfaces           | JSDoc on `export class AuthService` |
| Function | Always for exported functions                    | JSDoc on `export async function`    |
| Line     | Only for non-obvious requirement implementations | Inline `// @see` comment            |
| Never    | Top-of-file blanket links, annotating every line | -                                   |

### Inline Annotations

Standard annotations (`TODO`, `FIXME`, `XXX`, `HACK`, `NOTE`, `BUG`, `OPTIMIZE`, `REVIEW`) MUST include at least one `@see` link to a spec:

```typescript
// TODO: Implement pagination for claim history
// @see docs/specs/feature/tasks.md [4.2]

// FIXME: Race condition on concurrent logins
// @see docs/specs/user-auth/design.md [DES-SEC]
```

### Regex for Tooling

```regex
@see\s+(.*?\.md)\s+\[(.*?)\]
```

Captures: `group(1)` = file path, `group(2)` = Node ID.

---

## Cross-Spec Dependencies

Features that depend on other features declare this in `spec.md` frontmatter:

```yaml
depends_on:
  - marketplace-auth
  - marketplace-listings
```

**Semantics**: "This feature references or relies on another feature at the spec level." Does not distinguish build-order vs runtime vs co-change — that detail lives in the body's `## Dependencies` table.

**Rules**:

- Lists feature folder names (not file paths)
- Only feature-level dependencies go in frontmatter
- Package-level dependencies (`@package/db`) stay in the body table
- `/afx-check deps` builds and validates the dependency graph
- `/afx-spec review all` uses `depends_on` to check for contradictions across related specs

---

## File Anatomy

### 1. spec.md — Product Specification

```
┌─────────────────────────────────────────────────────────────┐
│ FRONTMATTER                                                 │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ afx: true                                               │ │
│ │ type: SPEC                                              │ │
│ │ status: Draft                                           │ │
│ │ owner: "@rix"                                           │ │
│ │ version: "1.0"                                          │ │
│ │ created_at: "2026-03-31T00:00:00.000Z"                  │ │
│ │ updated_at: "2026-03-31T00:00:00.000Z"                  │ │
│ │ tags: ["user-auth"]                                     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ BODY                                                        │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ # {Feature Name} - Product Specification                │ │
│ │                                                         │ │
│ │ ## References ·············· Upstream context links     │ │
│ │ ## Problem Statement ······ WHY are we building this?   │ │
│ │ ## User Stories ············ WHO benefits and HOW?      │ │
│ │ ## Requirements                                         │ │
│ │   ### Functional Requirements (FR table with MoSCoW)    │ │
│ │   ### Non-Functional Requirements (NFR table)           │ │
│ │ ## Acceptance Criteria ···· Checkboxes per feature      │ │
│ │ ## Non-Goals ··············· Explicit scope boundaries  │ │
│ │ ## Open Questions ·········· Unresolved decisions       │ │
│ │ ## Dependencies ············ External blockers          │ │
│ │ ## Appendix ················ Wireframes, glossary       │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2. design.md — Technical Design

```
┌─────────────────────────────────────────────────────────────┐
│ FRONTMATTER (with spec: spec.md backlink)                   │
│                                                             │
│ BODY — all sections prefixed with [DES-ID] Node IDs         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ## [DES-OVR] Overview                                   │ │
│ │ ## [DES-ARCH] Architecture                              │ │
│ │ ## [DES-UI] User Interface & UX                         │ │
│ │ ## [DES-DEC] Key Decisions                              │ │
│ │ ## [DES-DATA] Data Model                                │ │
│ │ ## [DES-API] API Contracts                              │ │
│ │ ## [DES-FILES] File Structure                           │ │
│ │ ## [DES-DEPS] Dependencies                              │ │
│ │ ## [DES-SEC] Security Considerations                    │ │
│ │ ## [DES-ERR] Error Handling                             │ │
│ │ ## [DES-TEST] Testing Strategy                          │ │
│ │ ## [DES-ROLLOUT] Migration / Rollout Plan               │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 3. tasks.md — Implementation Tasks

```
┌─────────────────────────────────────────────────────────────┐
│ FRONTMATTER (with spec: + design: backlinks)                │
│                                                             │
│ BODY — WBS numbered phases and tasks                        │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ## Task Numbering (WBS Convention)                      │ │
│ │   [FR-1], [NFR-2], [DES-API], [1.1] — Node ID refs      │ │
│ │                                                         │ │
│ │ ## Phase 1: {Name}                                      │ │
│ │   ### 1.1 {Task Group}                                  │ │
│ │     - [ ] Create user model                             │ │
│ │   ### 1.2 {Task Group}                                  │ │
│ │     - [x] Setup auth middleware                         │ │
│ │                                                         │ │
│ │ ## Cross-Reference Index                                │ │
│ │   Task → Spec Requirement → Design Section (Node IDs)   │ │
│ │                                                         │ │
│ │ ## Work Sessions                                        │ │
│ │   Date | Task | Action | Files | Agent | Human          │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 4. journal.md — Session Log

```
┌─────────────────────────────────────────────────────────────┐
│ FRONTMATTER (no version, no backlinks)                      │
│                                                             │
│ BODY (append-only)                                          │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ## Captures ·············· Quick notes (scratchpad)     │ │
│ │ ## Discussions ··········· Permanent records            │ │
│ │   ### UA-D001 - Auth Strategy                           │ │
│ │     Context, Summary, Decisions, Notes, Related Files   │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Skill Toolchain

### Artifact Ownership

| Artifact     | Skill          | Key Commands                             |
| ------------ | -------------- | ---------------------------------------- |
| `spec.md`    | `/afx-spec`    | create, validate, review, approve        |
| `design.md`  | `/afx-design`  | author, validate, review, approve        |
| `tasks.md`   | `/afx-task`    | plan, pick, code, verify, complete, sync |
| `journal.md` | `/afx-session` | note, log, active, recap, promote        |
| Source Code  | `/afx-task`    | code (task-driven with traceability)     |
| Source Code  | `/afx-dev`     | debug, refactor, review, test, optimize  |

### Lifecycle

```
/afx-spec create → /afx-spec approve
  → /afx-design author → /afx-design approve
    → /afx-task plan → /afx-task pick → /afx-task code → /afx-task complete
```

### Quality & Support

| Skill           | Purpose                                                             |
| --------------- | ------------------------------------------------------------------- |
| `/afx-check`    | Read-only quality gate (path, trace, links, schema, deps, coverage) |
| `/afx-report`   | Traceability metrics and orphan detection                           |
| `/afx-next`     | Context-aware "what should I do now?"                               |
| `/afx-scaffold` | Feature spec scaffolding                                            |
| `/afx-adr`      | ADR management — create, review, list, supersede                    |
| `/afx-research` | Research analysis and ADR authoring                                 |
| `/afx-context`  | Session context transfer between agents                             |
| `/afx-discover` | Codebase inventory and discovery                                    |
| `/afx-hello`    | Environment diagnostics                                             |
| `/afx-help`     | Command reference                                                   |

---

## Traceability: How It All Connects

```
REQUIREMENTS (spec.md)          ARCHITECTURE (design.md)        TASKS (tasks.md)
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │  spec:    │                   │  design:  │                   │
│  [FR-1] Login ────┼──────────▶│ [DES-API] Auth ───┼──────────▶│  [1.1] Model ─────┼──▶ Code
│  [FR-2] Reset ────┼──────────▶│ [DES-DATA] DB  ───┼──────────▶│  [2.1] Endpoint ──┼──▶ Code
│  [NFR-1] Perf ────┼──────────▶│ [DES-SEC] Security┼──────────▶│  [3.1] Cache ─────┼──▶ Code
│                   │           │                   │           │                   │
└───────────────────┘           └───────────────────┘           └───────────────────┘
         │                               │                               │
         │         CROSS-REFERENCE INDEX (tasks.md)                      │
         │         ┌──────┬──────────┬────────────────┐                  │
         └────────▶│ Task │ Spec Req │ Design Node ID │◀─────────────────┘
                   ├──────┼──────────┼────────────────┤
                   │ 1.1  │ [FR-1]   │ [DES-API]      │
                   │ 2.1  │ [FR-2]   │ [DES-DATA]     │
                   │ 3.1  │ [NFR-1]  │ [DES-SEC]      │
                   └──────┴──────────┴────────────────┘

CODE (@see annotations with Node IDs)
┌──────────────────────────────────────────────────┐
│  /**                                             │
│   * Submit login credentials.                    │
│   * @see docs/specs/user-auth/design.md [DES-API]│
│   * @see docs/specs/user-auth/tasks.md [1.1]     │
│   */                                             │
│  export async function login(data: LoginInput) { │
│    // implementation                             │
│  }                                               │
└──────────────────────────────────────────────────┘
```

### Link Types

| Direction      | Mechanism                    | Example                                         |
| -------------- | ---------------------------- | ----------------------------------------------- |
| spec → design  | Design author reads spec FRs | Author references [FR-1] when writing [DES-API] |
| design → tasks | Task refs in blockquote      | `> Ref: [DES-API], [FR-1]`                      |
| tasks → code   | `@see` annotations in source | `@see docs/specs/user-auth/tasks.md [1.1]`      |
| code → spec    | `@see` annotations in source | `@see docs/specs/user-auth/design.md [DES-API]` |
| design ← spec  | Frontmatter backlink         | `spec: spec.md`                                 |
| tasks ← design | Frontmatter backlink         | `design: design.md`                             |

---

## References

Full citations for the industry standards that inform AFX's artifact system:

1. **IEEE 830 / ISO/IEC/IEEE 29148** -- _Systems and software engineering -- Life cycle processes -- Requirements engineering._ IEEE, 2018. <https://standards.ieee.org/ieee/29148/6937/>
2. **MoSCoW** -- Dai Clegg, 1994. Requirement prioritization method originating from the Dynamic Systems Development Method (DSDM). <https://en.wikipedia.org/wiki/MoSCoW_method>
3. **User Stories** -- Mike Cohn / Extreme Programming. Connextra format: "As a [role], I want [feature], So that [benefit]". <https://www.mountaingoatsoftware.com/agile/user-stories>
4. **C4 Model** -- Simon Brown. Software architecture model with four levels: Context, Container, Component, Code. <https://c4model.com/>
5. **ADR (Architecture Decision Records)** -- Michael Nygard, 2011. Lightweight records capturing context, decision, and consequences. <https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions>
6. **WBS (Work Breakdown Structure)** -- PMI PMBOK Guide. Hierarchical decomposition of project deliverables into manageable tasks. <https://en.wikipedia.org/wiki/Work_breakdown_structure>
7. **Traceability Matrix** -- IEEE 29148 / DO-178C. Cross-reference mapping from requirements through design to implementation and test. <https://standards.ieee.org/ieee/29148/6937/>
