---
afx: true
type: COMMAND
status: Living
tags: [afx, command, spec, specification, review, approval]
---

# /afx:spec

Specification management, navigation, review, and approval for spec-centric workflows.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.templates` - Where spec templates live (default: `docs/agenticflowx/templates`)

If neither file exists, use defaults.

## Usage

```bash
# Discovery & Navigation
/afx:spec list                              # Show all specs with status
/afx:spec show <name>                       # Display spec overview + metrics
/afx:spec create <name>                     # Initialize new spec
/afx:spec status <name>                     # Show completion metrics

# Validation & Analysis
/afx:spec validate <name>                   # Check spec integrity
/afx:spec phases <name>                     # List phases and their status
/afx:spec requirements <name> [--type=FR]   # List requirements from spec.md
/afx:spec coverage <name>                   # Show requirements vs tasks gaps

# Collaboration & Review
/afx:spec discuss <name>                    # Interactive spec discussion
/afx:spec review <name>                     # Comprehensive automated review

# Approval Workflow
/afx:spec approve <name>                    # Mark spec as approved
/afx:spec sign-off <name> --reviewer "@handle"  # Human approval with signature
```

## Purpose

Provides a spec-centric interface for managing specifications throughout their lifecycle. Consolidates operations currently scattered across `/afx:init`, `/afx:work`, `/afx:check`, `/afx:task`, and `/afx:session`.

---

## Documentation Principles

**CRITICAL RULE**: Maintain strict separation between State and Event/Log.

- **Living Documents (State)**: `spec.md` and `design.md` represent the _current factual state_ of the system. They must NOT contain historical backstory, abandoned ideas, or chronological narratives. Always overwrite them to reflect reality.
- **Historical Logs (Event)**: `journal.md` and `tasks.md` represent the _history_ of how the system evolved. All architectural decisions, failed experiments, and brainstorming belong in the append-only `journal.md`.

---

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx:spec` action, suggest the most appropriate next command based on context:

| Context                             | Suggested Next Command                                    |
| ----------------------------------- | --------------------------------------------------------- |
| After `list` (no specs exist)       | `/afx:spec create <name>` to initialize first spec        |
| After `list` (specs exist)          | `/afx:spec show <name>` to view first Draft spec          |
| After `show` (status: Draft)        | `/afx:spec discuss <name>` to review and iterate          |
| After `show` (status: Approved)     | `/afx:work next <name>` to start implementation           |
| After `create`                      | `/afx:spec show <name>` to view created spec              |
| After `status`                      | `/afx:spec phases <name>` for detailed breakdown          |
| After `validate` (passed)           | `/afx:spec review <name>` for quality check               |
| After `validate` (failed)           | Fix missing files or broken links                         |
| After `phases`                      | `/afx:work next <name>` if tasks exist                    |
| After `requirements`                | `/afx:spec coverage <name>` to check task coverage        |
| After `coverage` (gaps found)       | `/afx:spec discuss <name>` to address gaps                |
| After `discuss`                     | `/afx:spec review <name>` to validate changes             |
| After `review` (critical issues)    | `/afx:spec discuss <name>` to fix issues                  |
| After `review` (no critical issues) | `/afx:spec approve <name>` to approve spec                |
| After `approve`                     | `/afx:spec sign-off <name> --reviewer` for human sign-off |
| After `sign-off`                    | `/afx:work plan <name>` to generate implementation tasks  |

**Suggestion Format** (5 ranked options, ideal → less ideal):

```
Next (ranked):
  1. /afx:spec discuss docs/specs/{feature}    # Ideal: Iterate on spec
  2. /afx:spec review {feature}                # Review quality
  3. /afx:spec approve {feature}               # Approve if ready
  4. /afx:work next {feature}                  # Start implementation
  5. /afx:session save "<note>"                # Capture findings
```

---

## Subcommands

### list

**Purpose:** Show all specs with status, owner, and progress

**Implementation:**

1. Read `.afx.yaml` to get `paths.specs` (default: `docs/specs`)
2. Scan spec directory for subdirectories
3. For each spec found:
   - Read `spec.md` frontmatter for: status, owner, version, tags
   - Read `tasks.md` to count total vs completed tasks
   - Calculate overall progress percentage
   - Get last modified timestamp from `journal.md`
4. Output table sorted by status (Draft → Approved → Living):

```
Spec                 Status    Owner    Progress    Last Updated
-------------------------------------------------------------------
user-authentication  Draft     @alice   0/12 (0%)   2 hours ago
payment-flow         Approved  @bob     8/15 (53%)  1 day ago
api-gateway          Living    @carol   12/12 (100%) 3 days ago
```

**Next Command:**

- If no specs exist: `/afx:spec create <name>`
- If Draft specs exist: `/afx:spec show <first-draft-spec>`
- If only Approved specs: `/afx:work status` (show workflow)

---

### show <name>

**Purpose:** Display spec overview with metrics and recent activity

**Implementation:**

1. Validate spec exists at `docs/specs/<name>/`
2. Read and display `spec.md` overview (frontmatter + top sections)
3. Calculate and display metrics:
   - Phase completion table (from tasks.md)
   - Task summary (completed/total by phase)
   - Recent journal entries (last 3)
   - Verification status (Gate 1-4 from tasks.md)
4. Output format:

```markdown
# User Authentication Spec

**Status:** Draft
**Owner:** @alice
**Version:** 1.0
**Tags:** auth, security, api

## Phase Completion

| Phase      | Tasks | Status        |
| ---------- | ----- | ------------- |
| 1. Setup   | 0/3   | ░░░░░░░░░░ 0% |
| 2. Core    | 0/6   | ░░░░░░░░░░ 0% |
| 3. Testing | 0/3   | ░░░░░░░░░░ 0% |

## Recent Activity

- 2 hours ago: Initial spec created
- 1 hour ago: Requirements defined
- 30 min ago: Design approach documented
```

**Next Command:**

- If status=Draft: `/afx:spec discuss <name>` or `/afx:spec review <name>`
- If status=Approved + tasks incomplete: `/afx:work next <name>`
- If status=Approved + tasks complete: `/afx:check all`

---

### create <name>

**Purpose:** Initialize new spec (delegates to /afx:init)

**Implementation:**

1. Delegate to `/afx:init feature <name>`
2. Provide context: "Created via /afx:spec create"
3. After creation completes, suggest next command

**Next Command:**

- `/afx:spec show <name>` to view created spec
- Then edit spec.md to define requirements

---

### status <name>

**Purpose:** Show detailed completion metrics

**Implementation:**

1. Read all 4 spec files
2. Calculate comprehensive metrics:
   - Total requirements count (from spec.md FR-xxx, NFR-xxx)
   - Total tasks (from tasks.md)
   - Completed tasks (both `[OK]` columns marked)
   - Phase completion percentages
   - Gate verification status (Gate 1-4 pass/fail from tasks)
   - Last journal update timestamp
   - Days since spec creation
3. Output format:

```
Status: user-authentication

Requirements: 8 total (5 FR, 3 NFR)
Tasks: 12 total, 0 completed (0%)
Phases: 3 total, 0 complete (0%)

Gate Status:
  Gate 1 (Path):  0/12 tasks verified
  Gate 2 (Lint):  0/12 tasks verified
  Gate 3 (Links): Not run
  Gate 4 (Audit): Not run

Last Updated: 2 hours ago (journal.md)
Created: 3 days ago
```

**Next Command:**

- `/afx:spec phases <name>` for detailed phase breakdown
- `/afx:work next <name>` if tasks exist

---

### validate <name>

**Purpose:** Check spec structure integrity

**Implementation:**

1. Check required files exist:
   - `docs/specs/<name>/spec.md`
   - `docs/specs/<name>/design.md`
   - `docs/specs/<name>/tasks.md`
   - `docs/specs/<name>/journal.md`
2. Validate frontmatter in each file:
   - Has `afx: true`
   - Has correct `type` (SPEC, DESIGN, TASKS, JOURNAL)
   - Has `status` field
3. Check internal cross-references (delegate to `/afx:check links`)
4. Report findings:

```
Validation: user-authentication

File Structure: ✓ All 4 files present
Frontmatter: ✓ Valid in all files
Cross-references: ✓ All links valid

Status: PASSED
```

If validation fails:

```
Validation: user-authentication

File Structure: ✗ Missing files
  - tasks.md not found

Frontmatter: ✗ Invalid
  - spec.md: missing 'status' field
  - design.md: 'type' should be DESIGN, found SPEC

Status: FAILED (2 critical issues)
```

**Next Command:**

- If passed: `/afx:spec review <name>` for quality check
- If failed: Fix listed issues, then re-validate

---

### phases <name>

**Purpose:** List all phases with completion status

**Implementation:**

1. Parse `tasks.md` to extract phases (level 2 headers: `## Phase N:...`)
2. For each phase:
   - Extract phase number and name
   - Count total tasks in phase
   - Count completed tasks (`[OK][OK]`)
   - Calculate percentage
3. Output table with progress bars:

```
Phases: user-authentication

Phase  Name             Tasks      Status
------------------------------------------------
1      Setup            0/3 (0%)   ░░░░░░░░░░
2      Core Auth        0/6 (0%)   ░░░░░░░░░░
3      Testing          0/3 (0%)   ░░░░░░░░░░
------------------------------------------------
Total                   0/12 (0%)  ░░░░░░░░░░
```

**Next Command:**

- `/afx:work next <name>` if tasks exist
- `/afx:spec coverage <name>` to check task coverage

---

### requirements <name> [--type=FR|NFR]

**Purpose:** List functional and non-functional requirements from spec.md

**Implementation:**

1. Parse `spec.md` to extract requirements:
   - Functional Requirements: Lines matching `FR-\d+:` pattern
   - Non-Functional Requirements: Lines matching `NFR-\d+:` pattern
   - User Stories: Lines matching `US-\d+:` or `As a...` pattern
2. Apply filter if `--type` specified
3. Output numbered list:

```
Requirements: user-authentication

Functional Requirements (FR):
  FR-1: Users can log in with email and password
  FR-2: Users can request password reset via email
  FR-3: System validates email format
  FR-4: System enforces password complexity rules
  FR-5: Users can logout

Non-Functional Requirements (NFR):
  NFR-1: Login response time < 200ms (p95)
  NFR-2: Password hashed with bcrypt (cost factor 12)
  NFR-3: JWT tokens expire after 24 hours

Total: 5 FR, 3 NFR
```

**Next Command:**

- `/afx:spec coverage <name>` to check which requirements have tasks
- `/afx:spec phases <name>` to see task breakdown

---

### coverage <name>

**Purpose:** Show requirements vs tasks gap analysis

**Implementation:**

1. Extract requirements from `spec.md` (FR-xxx, NFR-xxx)
2. Extract tasks from `tasks.md` with their `@see` references
3. Cross-reference:
   - Find requirements without corresponding tasks (gaps)
   - Find tasks without requirement links (orphans)
   - Calculate coverage percentage
4. Output gap analysis:

```
Coverage: user-authentication

Requirements Coverage: 6/8 (75%)

Requirements WITH Tasks:
  ✓ FR-1: Login (tasks 2.1, 2.2)
  ✓ FR-2: Password reset (task 3.1)
  ✓ FR-3: Email validation (task 2.1)
  ✓ FR-5: Logout (task 2.3)
  ✓ NFR-1: Performance (task 4.1)
  ✓ NFR-2: Security (task 2.2)

Requirements WITHOUT Tasks (GAPS):
  ✗ FR-4: Password complexity
  ✗ NFR-3: Token expiry

Orphaned Tasks (no requirement link):
  ⚠ Task 1.1: Setup database schema

Recommendations:
  1. Add task for FR-4 (password complexity)
  2. Add task for NFR-3 (token expiry)
  3. Link task 1.1 to a requirement or remove if unnecessary
```

**Next Command:**

- If gaps found: `/afx:spec discuss <name>` to address gaps
- If orphans found: Edit tasks.md to add `@see` links or remove tasks
- If 100% coverage: `/afx:spec review <name>` for quality check

---

### discuss <name>

**Purpose:** Interactive spec discussion and collaborative gap analysis

**Implementation:**

1. **Load Context**
   - Read all 4 spec files (spec.md, design.md, tasks.md, journal.md)
   - Parse requirements, design decisions, tasks, previous discussions

2. **Analyze for Issues**
   - Vague requirements (lacks acceptance criteria)
   - Missing non-functional requirements (performance, security, scalability, UX)
   - Design decisions without rationale
   - Tasks without clear acceptance criteria
   - Inconsistencies between spec.md and design.md
   - Edge cases not addressed (error handling, validation, limits)
   - Ambiguous terminology
   - **Historical context in living documents**: Spec or Design contains chronological history (should be in Journal)

3. **Present Findings**

   ```
   Spec Discussion: user-authentication

   Issues Identified (5):

   1. [QUALITY] Vague Requirement (FR-1)
      "Users can log in with email and password"
      → Missing acceptance criteria
      → What happens on failure? After 3 attempts? 5 attempts?

   2. [GAP] Missing NFR (Security)
      → No requirement for session timeout
      → No requirement for brute-force protection

   3. [CONSISTENCY] Design vs Spec Mismatch
      design.md mentions OAuth, but spec.md only requires email/password

   4. [EDGE CASE] Error Handling Not Specified
      → What if email service is down during password reset?
      → How to handle concurrent login attempts?

   5. [AMBIGUOUS] Terminology Inconsistency
      spec.md uses "login", design.md uses "authentication", tasks.md uses both
   ```

4. **Ask Clarifying Questions** (use AskUserQuestion)
   - "FR-1: Should we implement account lockout after N failed attempts? If so, how many attempts and lockout duration?"
   - "NFR: What's the acceptable session timeout duration? 15 min? 24 hours?"
   - "Design: Should we support OAuth in addition to email/password, or postpone OAuth to v2?"
   - "Edge Case: For password reset, if email delivery fails, should we retry? Queue? Show user error?"

5. **Capture Discussion** in journal.md

   ```markdown
   ## Discussion: Spec Review (2024-01-15 14:30)

   ### Issues Identified

   - FR-1 lacks acceptance criteria (failure scenarios, lockout policy)
   - Missing NFRs: session timeout, brute-force protection
   - Design mentions OAuth but spec doesn't require it
   - Edge case: email service downtime during password reset
   - Terminology inconsistency: login vs authentication

   ### Questions & Answers

   - Q: Account lockout after failed attempts?
   - A: Yes, 5 attempts → 15 min lockout

   - Q: Session timeout duration?
   - A: 24 hours idle timeout

   - Q: OAuth support in v1?
   - A: No, postpone to v2. Remove OAuth from design.md

   - Q: Email delivery failure handling?
   - A: Queue retry (3 attempts), show generic success message to user

   ### Decisions Made

   - Add NFR for session timeout (24h idle)
   - Add NFR for brute-force protection (5 attempts → 15 min lockout)
   - Remove OAuth from design.md (v2 feature)
   - Use "authentication" consistently across all docs

   ### Action Items

   - [ ] Update spec.md: Add acceptance criteria to FR-1
   - [ ] Update spec.md: Add NFR for session timeout
   - [ ] Update spec.md: Add NFR for brute-force protection
   - [ ] Update design.md: Remove OAuth section
   - [ ] Update design.md: Add email retry queue design
   - [ ] Update all docs: Replace "login" with "authentication"
   ```

**Next Command:**

- `/afx:spec review <name>` after edits made
- Edit spec files to address action items

---

### review <name>

**Purpose:** Comprehensive automated spec review with issue detection

**Implementation:**

1. **Completeness Check**
   - spec.md has all required sections (Overview, Requirements, Success Criteria)
   - design.md has architecture description (data models, API endpoints, algorithms)
   - tasks.md maps to all design sections
   - journal.md has initial rationale

2. **Quality Check**
   - Requirements are testable (acceptance criteria defined)
   - Design decisions have documented rationale
   - Tasks have clear completion criteria
   - No orphaned requirements (not referenced in design)
   - No orphaned design sections (not referenced in tasks)
   - **Living document purity**: spec.md and design.md are free of historical narrative

3. **Consistency Check**
   - Terminology consistent across spec/design/tasks
   - Requirements numbering sequential (no gaps)
   - Cross-references valid (all `@see` links exist)
   - Phase definitions align across documents

4. **Gap Analysis**
   - Missing NFRs (performance, security, scalability, UX, accessibility)
   - Edge cases not addressed (errors, timeouts, race conditions)
   - Error handling not specified
   - Data validation rules missing
   - Integration points not defined

5. **Risk Analysis**
   - High-risk requirements (complex, uncertain, external dependencies)
   - Dependencies on external systems
   - Assumptions that need validation

6. **Output Report**

   ```
   Review: user-authentication

   Score: 72% compliant

   Critical Issues (2):
     [COMPLETENESS] spec.md missing "Success Criteria" section
     [QUALITY] FR-1 not testable - lacks acceptance criteria

   Major Issues (4):
     [GAP] Missing NFR for security (session timeout)
     [GAP] Missing NFR for performance (login response time SLA)
     [CONSISTENCY] Terminology mismatch: spec.md uses "login", design.md uses "auth"
     [QUALITY] design.md contains historical backstory about choosing the auth provider (move to journal.md)

   Minor Issues (5):
     [QUALITY] Task 2.1 could have clearer acceptance criteria
     [CONSISTENCY] Phase numbering skips from 2 to 4 (missing 3)
     [GAP] Edge case: email service downtime not addressed
     [GAP] Missing accessibility NFR (WCAG compliance)
     [RISK] External dependency: email service (SendGrid) - SLA unknown

   Recommendations:
     1. Fix 2 Critical issues before approval
     2. Add missing NFRs for security and performance
     3. Standardize terminology to "authentication"
     4. Address email service downtime scenario
     5. Document SendGrid SLA or add fallback plan
   ```

**Next Command:**

- If Critical issues exist: `/afx:spec discuss <name>` to fix issues
- If no Critical issues: `/afx:spec approve <name>` to approve spec

---

### approve <name>

**Purpose:** Mark spec as approved (automated validation + status change)

**Implementation:**

1. **Check Current Status**
   - Read spec.md frontmatter
   - If already "Approved", exit with error: "Spec already approved. Use version bump to modify."

2. **Pre-Approval Validation**
   - Run `/afx:spec validate <name>` (structure check)
   - Run `/afx:spec review <name>` (quality check)
   - Count Critical issues from review

3. **Approval Decision**
   - If Critical issues > 0: **BLOCK APPROVAL**

     ```
     Approval BLOCKED: user-authentication

     Cannot approve with Critical issues:
       [COMPLETENESS] spec.md missing "Success Criteria" section
       [QUALITY] FR-1 not testable - lacks acceptance criteria

     Fix these issues first, then run:
       /afx:spec review user-authentication
       /afx:spec approve user-authentication
     ```

   - If Critical issues = 0: **APPROVE**

     ```
     Approved: user-authentication

     ✓ Validation passed (structure intact)
     ✓ Review passed (0 Critical issues)
     ✓ Status changed: Draft → Approved
     ✓ Spec frozen (further changes require version bump)
     ✓ Journal updated with approval record

     Note: 3 Major and 5 Minor issues remain. Address in future versions if needed.
     ```

4. **Update spec.md Frontmatter**

   ```yaml
   ---
   afx: true
   type: SPEC
   status: Approved # Changed from Draft
   owner: "@alice"
   version: 1.0
   approved_at: "2024-01-15T14:30:00Z" # Added timestamp
   ---
   ```

5. **Freeze spec.md**
   - Add comment at top:
     ```markdown
     <!-- APPROVED: 2024-01-15 - Do not edit without version bump -->
     ```

6. **Add Journal Entry**

   ```markdown
   ## Approval: Spec Approved (2024-01-15 14:30)

   Spec approved and frozen. Further changes require version bump.

   Approved by: Claude (automated validation)
   Review score: 72% compliant (0 Critical, 3 Major, 5 Minor issues)

   Validation Summary:
   ✓ Structure: All 4 files present
   ✓ Frontmatter: Valid
   ✓ Cross-references: All links valid
   ✓ Quality: 0 Critical issues

   Next step: Human sign-off via `/afx:spec sign-off user-authentication --reviewer "@handle"`
   ```

**Next Command:**

- `/afx:spec sign-off <name> --reviewer "@handle"` for human approval
- `/afx:work plan <name>` to generate implementation tasks (if tasks exist)

---

### sign-off <name> --reviewer "@handle"

**Purpose:** Human approval with signature and timestamp (compliance/audit trail)

**Arguments:**

- `<name>` - Spec name (required)
- `--reviewer "@handle"` - Who is signing off (required)
- `--scope "description"` - What is being approved (optional, defaults to "Full spec")
- `--notes "context"` - Additional review notes (optional)

**Implementation:**

1. **Validate Preconditions**
   - Spec status must be "Approved" (automated approval first)
   - If not approved, exit with error:

     ```
     Sign-off BLOCKED: user-authentication

     Spec must be approved before human sign-off.
     Current status: Draft

     Run this first:
       /afx:spec approve user-authentication
     ```

2. **Record Sign-Off in journal.md**

   ```markdown
   ## Sign-Off: Human Approval (2024-01-15 15:00)

   Reviewed and approved by: @alice
   Timestamp: 2024-01-15T15:00:00Z
   Scope: Full spec (functional requirements, design architecture, task breakdown)

   Approval attestation:
   ✓ Requirements are clear and complete
   ✓ Design approach is sound
   ✓ Tasks cover all requirements
   ✓ Acceptance criteria are testable

   Review notes: Looks good for v1. Address brute-force protection in v1.1.

   Signed: @alice
   ```

3. **Update spec.md Frontmatter**

   ```yaml
   ---
   afx: true
   type: SPEC
   status: Approved
   owner: "@alice"
   reviewer: "@alice" # Added reviewer
   approved_at: "2024-01-15T14:30:00Z"
   signed_at: "2024-01-15T15:00:00Z" # Added sign-off timestamp
   version: 1.0
   ---
   ```

4. **Output Confirmation**

   ```
   Signed Off: user-authentication

   ✓ Human approval recorded
   ✓ Reviewer: @alice
   ✓ Timestamp: 2024-01-15 15:00:00
   ✓ Scope: Full spec
   ✓ Frontmatter updated with reviewer and timestamp

   Spec is now fully approved and ready for implementation.
   ```

**Next Command:**

- `/afx:work plan <name>` to generate implementation tasks from approved spec
- `/afx:work next <name>` to start first task

---

## Error Handling

### Common Errors

1. **Spec Not Found**

   ```
   Error: Spec "payment-flow" not found

   Searched in: docs/specs/payment-flow/
   Available specs: user-auth, api-gateway

   Did you mean:
     /afx:spec create payment-flow
     /afx:spec list
   ```

2. **Missing Files**

   ```
   Error: Incomplete spec structure

   Missing files:
     - docs/specs/user-auth/tasks.md
     - docs/specs/user-auth/journal.md

   Run this to reinitialize:
     /afx:init feature user-auth
   ```

3. **Approval Blocked**

   ```
   Error: Cannot approve spec with Critical issues

   Fix these first:
     [COMPLETENESS] spec.md missing "Success Criteria"
     [QUALITY] FR-1 lacks acceptance criteria

   Then run:
     /afx:spec review user-auth
     /afx:spec approve user-auth
   ```

4. **Already Approved**

   ```
   Error: Spec already approved

   To modify an approved spec:
     1. Increment version in spec.md
     2. Remove "<!-- APPROVED -->" comment from spec.md
     3. Make changes
     4. Run /afx:spec approve user-auth again
   ```

---

## Integration with Other Commands

### From Other Commands → `/afx:spec`

- `/afx:init feature` → Suggest `/afx:spec show <name>` after creation
- `/afx:work status` → Suggest `/afx:spec list` when multiple specs exist
- `/afx:task audit` → Suggest `/afx:spec coverage` if gaps detected
- `/afx:check links` → Suggest `/afx:spec validate` for full validation

### From `/afx:spec` → Other Commands

- `/afx:spec show` → Suggest `/afx:work next` if tasks pending
- `/afx:spec create` → Suggest editing spec.md to define requirements
- `/afx:spec coverage` → Suggest `/afx:work plan` if tasks missing
- `/afx:spec approve` → Suggest `/afx:work plan` to generate tasks
- `/afx:spec sign-off` → Suggest `/afx:work next` to start implementation

---

## Notes

- This command consolidates spec-centric operations scattered across 6 commands
- Follows AFX patterns: YAML frontmatter, subcommand structure, agent instructions
- Does NOT duplicate functionality - delegates where appropriate (e.g., create → /afx:init)
- Provides spec discovery and navigation currently missing from AFX workflow
- Interactive `discuss` and automated `review` ensure spec quality before approval
- Two-stage approval (`approve` → `sign-off`) balances automation with human oversight
