# Documentation References (Living Documentation Traceability)

> Add this section to your CLAUDE.md to enable @see annotation requirements.

```markdown
### Documentation References (Living Documentation Traceability)

> **AFX**: Bidirectional code↔spec linking ensures AI agents maintain alignment with specifications.

All spec-driven files MUST have a top-level JSDoc with `@see` references linking back to the relevant spec documents.

**Required links** (enforced by `/afx-check trace`):

| File Type         | Required Links                                           |
| ----------------- | -------------------------------------------------------- |
| `*.repository.ts` | spec.md requirement + design.md section                  |
| `*.service.ts`    | spec.md requirement + design.md section                  |
| `*.action.ts`     | spec.md requirement + design.md section (if spec-driven) |
| `*.model.ts`      | design.md section (if spec-driven)                       |
| `*.constants.ts`  | research doc or design.md (if decision-driven)           |

**Optional links** (allowed but not enforced):

| Target     | When to use                                                                                                          |
| ---------- | -------------------------------------------------------------------------------------------------------------------- |
| `tasks.md` | Developer wants a breadcrumb to the originating task — useful but not required since tasks are transactional history |

**Format:**

\`\`\`typescript
/\*\*

- [Brief description]
-
- @see docs/specs/[feature]/spec.md [FR-X]
- @see docs/specs/[feature]/design.md [DES-SECTION]
  \*/
  \`\`\`

**Example (single requirement):**

\`\`\`typescript
/\*\*

- User Repository Interface
-
- @see docs/specs/user-auth/spec.md [FR-1]
- @see docs/specs/user-auth/design.md [DES-REPO]
  \*/
  \`\`\`

**Example (multiple requirements from same spec):**

\`\`\`typescript
/\*\*

- Authentication service — handles login, session, and token refresh.
-
- @see docs/specs/user-auth/spec.md [FR-1] [FR-2] [NFR-1]
- @see docs/specs/user-auth/design.md [DES-AUTH] [DES-SESSION]
  \*/
  \`\`\`

Multiple Node IDs on the same `@see` line means the function implements all of those requirements. Use one `@see` line per file, with multiple IDs space-separated.

**Node ID Format:**

- **Spec anchors:** Use `[FR-X]` or `[NFR-X]` matching the requirement ID in the spec table (e.g., `[FR-1]`, `[NFR-3]`)
- **Design anchors:** Use `[DES-SECTION]` with uppercase kebab-case section name (e.g., `[DES-REPO]`)
- **Task anchors (optional):** Use `[X.Y]` where X is phase, Y is task number (e.g., `[2.1]`)
- **Research anchors:** Link directly to research file (e.g., `research/decision-name.md`)

**Inline Annotations:**

Use standard annotation format + `@see` link. **At least one link MUST point to a spec or design** (`docs/specs/`). External links are optional.

\`\`\`typescript
// ❌ BAD: Orphaned TODO
// TODO: implement pagination

// ❌ BAD: Only external link (no spec)
// FIXME #789: Race condition
// @see https://github.com/org/repo/issues/789

// ✅ GOOD: Spec link required
// TODO: Implement pagination for claim history
// @see docs/specs/feature/spec.md [FR-4]
// @see docs/specs/feature/design.md [DES-API]

// ✅ GOOD: Spec + optional external link
// FIXME: Race condition in concurrent updates
// @see docs/specs/feature/design.md [DES-CONCURRENCY]
// @see https://github.com/org/repo/issues/789
\`\`\`

Standard annotations: `TODO`, `FIXME`, `XXX`, `HACK`, `NOTE`, `BUG`, `OPTIMIZE`, `REVIEW`
```
