---
name: afx-design
description: Design authoring — generate, validate, review, and approve technical design documents (design.md)
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,design,architecture,validation,lifecycle"
  afx-argument-hint: "author | validate | review | approve"
---

# /afx-design

Technical design authoring, validation, review, and approval for `design.md` artifacts.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.templates` - Where spec templates live (default: `docs/agenticflowx/templates`)

If neither file exists, use defaults.

## Usage

```bash
/afx-design author <name>                  # Generate design.md from approved spec
/afx-design validate <name>                # Check design structure and traceability
/afx-design review <name>                  # Advisory quality check for design gaps
/afx-design approve <name>                 # Approve design (unlocks task planning)
```

## Purpose

Owns the `design.md` artifact exclusively. Handles design authoring from approved specs, structural validation, quality review, and approval gating that unlocks the task planning phase.

---

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace (including source code for context)
- Create/update `design.md` only in `docs/specs/**/`
- Append to `docs/specs/**/journal.md` (captures only, via Proactive Capture Protocol)

### Forbidden

- Create/modify/delete source code in application directories
- Create/modify/delete `spec.md` (owned by `/afx-spec`)
- Create/modify/delete `tasks.md` (owned by `/afx-task`)
- Create/modify/delete folders or any non-design spec files
- Delete any files or directories
- Run build/test/deploy/migration commands
- Modify `.afx.yaml` or `.afx/` configuration

If out-of-scope work is requested, return:

```text
Out of scope for /afx-design (design-management mode). Use /afx-spec for spec changes, /afx-task for task planning.
```

---

### Timestamp Format (MANDATORY)

All timestamps MUST use ISO 8601 with millisecond precision: `YYYY-MM-DDTHH:MM:SS.mmmZ` (e.g., `2025-12-17T14:30:00.000Z`). Never write short formats like `2025-12-17 14:30`.

### Frontmatter (MANDATORY)

When creating or modifying `design.md`, enforce the canonical AFX frontmatter schema:

```yaml
---
afx: true
type: DESIGN
status: Draft
owner: "@handle"
version: "1.0"
created_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
updated_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
tags: ["{feature}"]
spec: spec.md
---
```

**Canonical field order**: `afx → type → status → owner → version → created_at → updated_at → tags → spec`. Use double quotes for all string values.

**Immutable fields** (must NOT be changed during approval): `afx`, `type`, `owner`, `created_at`.

### Proactive Journal Capture

When this skill detects a high-impact context change, auto-capture to `journal.md` per the [Proactive Capture Protocol](../afx-session/SKILL.md#proactive-capture-protocol-mandatory).

**Triggers for `/afx-design`**: Design decision with significant trade-offs, architecture change from original spec intent, approval with conditions.

---

## Lifecycle Precondition (BLOCKING)

**CRITICAL**: Design authoring is gated behind spec approval.

| Action   | Precondition                   | Check                    |
| -------- | ------------------------------ | ------------------------ |
| `author` | `spec.md` status == `Approved` | Read spec.md frontmatter |
| `approve`| `design.md` has content        | Check design is authored |

Before authoring or approving, the agent **MUST**:

1. Read `spec.md` frontmatter for the target feature
2. Check the `status` field
3. If `status` is NOT `Approved`, **STOP** and output:

```text
BLOCKED: Cannot author design.md content.

Precondition not met:
  spec.md status is "{current_status}" (required: "Approved")

Approve the spec first:
  /afx-spec review {name}
  /afx-spec approve {name}
```

---

## Post-Action Checklist (MANDATORY)

After completing any action that modifies `design.md`, you MUST:

1. **Update `updated_at`**: Set to current ISO 8601 timestamp in `design.md` frontmatter.
2. **Verify `spec` backlink**: Ensure `spec: spec.md` is present in frontmatter.
3. **Contextual Tagging**: If changes introduce new domains, frameworks, or concepts (e.g., adding Redis, a new API pattern), append relevant keywords to the `tags` array.
4. **Version & State Management**: If modifying a `design.md` that is currently `status: Approved`, evaluate the change. If it alters architecture or scope, bump `version` (e.g., "1.0" → "1.1") and revert `status: Draft` to force re-approval.
5. **Format Preservation**: Frontmatter fields must remain in canonical order. Use double quotes for all string values.
6. **Node ID Integrity**: Every major design section MUST have a `[DES-ID]` Node ID in its heading (e.g., `## [DES-API] API Contracts`). When adding new sections, scan existing IDs to avoid duplicates.

---

## Agent Instructions

### Persistence Checkpoint (MANDATORY)

Do not auto-write design files. Before persisting any changes to `design.md`:

1. Present the proposed content to the user
2. Wait for explicit confirmation before writing
3. `journal.md` append-only entries may be written without checkpoint

### Next Command Suggestion (MANDATORY)

After EVERY `/afx-design` action, suggest the next command:

| Context                              | Suggested Next Command                            |
| ------------------------------------ | ------------------------------------------------- |
| After `author`                       | `/afx-design review <name>` to validate quality   |
| After `validate` (passed)            | `/afx-design review <name>` for quality check     |
| After `validate` (failed)            | Fix listed structural issues                      |
| After `review` (critical issues)     | Fix issues, then `/afx-design validate <name>`    |
| After `review` (no critical issues)  | `/afx-design approve <name>` to approve design    |
| After `approve`                      | `/afx-task plan <name>` to generate tasks         |

---

## Subcommands

### author <name>

**Purpose:** Generate technical design document from approved spec.

**Lifecycle Gate:** `spec.md` status MUST be `Approved`.

**Implementation:**

1. **Read Approved Spec**
   - Load `spec.md` — extract requirements (FR-xxx, NFR-xxx), user stories, acceptance criteria, dependencies
   - Load `journal.md` — extract any design discussions or decisions already captured
   - Read source code if relevant — understand existing patterns and architecture

2. **Generate Design Content** using the design template (`docs/agenticflowx/templates/design.md`):
   - `## [DES-OVR] Overview` — brief technical approach summary
   - `## [DES-ARCH] Architecture` — system context, component diagram
   - `## [DES-UI] User Interface & UX` — component composition (if applicable)
   - `## [DES-DEC] Key Decisions` — decision table with rationale
   - `## [DES-DATA] Data Model` — schemas, TypeScript interfaces
   - `## [DES-API] API Contracts` — server actions, input/output types
   - `## [DES-FILES] File Structure` — new files and modifications
   - `## [DES-DEPS] Dependencies` — external and internal packages
   - `## [DES-SEC] Security Considerations`
   - `## [DES-ERR] Error Handling`
   - `## [DES-TEST] Testing Strategy`
   - `## [DES-ROLLOUT] Migration / Rollout Plan`
   - Every section MUST link back to spec requirements via `@see` with Node IDs

3. **Persistence Checkpoint** (MANDATORY)
   - Present the proposed design.md content to the user
   - Wait for explicit confirmation before writing

4. **Write design.md**
   - Replace scaffold content with authored design
   - Preserve frontmatter, update `updated_at`
   - Ensure `spec: spec.md` backlink is present

5. **Update journal.md** — append entry recording design authoring session

**`@see` Annotation Format in design.md:**

```markdown
## [DES-API] API Contracts
<!-- @see spec.md [FR-1] [FR-2] -->

{Design content referencing these requirements}
```

---

### validate <name>

**Purpose:** Structural compliance check for design.md — deterministic, blocking for approval.

**Implementation:**

1. **File Existence**: Check `design.md` exists at `docs/specs/<name>/design.md`
2. **Frontmatter Validation**:
   - Has `afx: true`, `type: DESIGN`, `status` field
   - Has `spec: spec.md` backlink
   - Has `version` (quoted string)
   - Has `created_at` and `updated_at` (non-midnight timestamps)
   - Field order is canonical
3. **Node ID Check**:
   - Every `##` heading has a `[DES-ID]` prefix
   - No duplicate Node IDs within the file
4. **Template Section Compliance**: Check required sections exist:
   - `[DES-OVR]` Overview
   - `[DES-ARCH]` Architecture
   - `[DES-DEC]` Key Decisions
   - `[DES-DATA]` Data Model
   - `[DES-API]` API Contracts
   - `[DES-FILES]` File Structure
   - `[DES-SEC]` Security Considerations
   - `[DES-ERR]` Error Handling
   - `[DES-TEST]` Testing Strategy
5. **Traceability Check**: At least one `@see spec.md [FR-X]` or `[NFR-X]` reference exists

**Output:**

```
Validation: user-authentication (design.md)

Frontmatter: ✓ Valid (DESIGN, spec backlink present)
Node IDs: ✓ All sections have [DES-ID], no duplicates
Template Sections: ✓ All 9 required sections present
Traceability: ✓ 12 @see links to spec requirements

Status: PASSED
```

---

### review <name>

**Purpose:** Advisory content quality check — requires agent judgment, not blocking.

**Implementation:**

1. **Completeness**: Does the design cover ALL functional requirements from spec.md?
2. **NFR Coverage**: Are performance, security, scalability, and accessibility addressed architecturally?
3. **Error Boundaries**: Are error scenarios defined for each component?
4. **Consistency**: Does design terminology match spec terminology?
5. **Living Document Purity**: No historical narrative (belongs in journal.md)
6. **Risk Analysis**: High-risk components identified? External dependency SLAs documented?
7. **Cross-Spec Impact**: If `spec.md` has `depends_on`, check that design addresses integration points

**Output:**

```
Review: user-authentication (design.md)

Score: 85% compliant

Critical Issues (0): None

Major Issues (2):
  [GAP] NFR-3 (accessibility) not addressed in design
  [CONSISTENCY] design.md uses "login" but spec.md uses "authentication"

Minor Issues (3):
  [QUALITY] [DES-ERR] Error handling table missing timeout scenarios
  [RISK] External dependency: SendGrid SLA not documented
  [QUALITY] [DES-TEST] Testing strategy lacks integration test plan

Recommendations:
  1. Add accessibility section or note in [DES-UI]
  2. Standardize terminology to "authentication"
```

---

### approve <name>

**Purpose:** Mark design.md as approved, unlocking task planning.

**Implementation:**

1. **Check Precondition**: `spec.md` status must be `Approved`
2. **Check Current Status**: If `design.md` already `Approved`, exit with error
3. **Run Validation**: Execute `/afx-design validate <name>` — if structural issues exist, **BLOCK**
4. **Run Review**: Execute `/afx-design review <name>` — report quality issues (advisory, not blocking)
5. **Approve**:
   - Update `design.md` frontmatter: `status: Draft → Approved`, add `approved_at`, update `updated_at`
   - Add journal entry recording approval
6. **Output**:

```text
Approved: user-authentication (design.md)

✓ spec.md is Approved (precondition met)
✓ Structural validation passed
✓ Status changed: Draft → Approved
✓ /afx-task plan UNLOCKED
✓ Journal updated with approval record

Note: 2 Major and 3 Minor quality issues remain. Address in future versions if needed.

Next: /afx-task plan user-authentication
```

---

## Error Handling

### Common Errors

1. **Spec Not Approved**

   ```text
   BLOCKED: Cannot author design.md content.

   Precondition not met:
     spec.md status is "Draft" (required: "Approved")

   Approve the spec first:
     /afx-spec review {name}
     /afx-spec approve {name}
   ```

2. **Design Already Approved**

   ```text
   Error: design.md already approved.

   To modify an approved design:
     1. Bump version in design.md (e.g., "1.0" → "1.1")
     2. Set status back to Draft
     3. Make changes
     4. Run /afx-design approve {name} again
   ```

3. **Validation Failed**

   ```text
   Approval BLOCKED: user-authentication (design.md)

   Structural issues found:
     ✗ Missing [DES-SEC] Security Considerations section
     ✗ No @see links to spec requirements

   Fix these issues, then run:
     /afx-design validate {name}
     /afx-design approve {name}
   ```

---

## Related Commands

### From Other Commands → `/afx-design`

- `/afx-spec approve` → Suggest `/afx-design author <name>`
- `/afx-check links` → Suggest `/afx-design validate <name>` for design link check

### From `/afx-design` → Other Commands

- `/afx-design approve` → Suggest `/afx-task plan <name>`
- `/afx-design review` (issues found) → Suggest `/afx-design validate <name>` after fixes
