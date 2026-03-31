---
name: afx-session
description: Session discussion capture — smart notes, session logging, context recaps, and ADR promotion
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,session,notes,discussion,journal"
  afx-argument-hint: "note | log | recap | promote"
---

# /afx-session

Session discussion capture and recall for multi-agent workflows.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.adr` - Where global ADRs live (default: `docs/adr`)
- `paths.sessions` - Global discussion location (default: `docs/specs`)
- `library.research` - Global research library path (default: `docs/research`)
- `prefixes` - Feature prefix mappings for discussion IDs

If neither file exists, use defaults.

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace
- Create/modify markdown files only in:
  - `docs/specs/**/journal.md` (feature session logs)
  - `docs/specs/journal.md` (global session log)
  - `docs/specs/**/research/` (ADR promotion only)
  - `docs/adr/` (ADR promotion only)

### Forbidden

- Create/modify/delete source code in application directories
- Modify spec files (`spec.md`, `design.md`, `tasks.md`)
- Delete any files
- Run build/test/deploy/migration commands

If implementation is requested, respond with:

```text
Out of scope for /afx-session (session capture mode). Use /afx-dev code to implement.
```

## Post-Action Checklist (MANDATORY)

After modifying `journal.md`, you MUST:

1. **Update `updated_at`**: Set to current ISO 8601 timestamp in `journal.md` frontmatter.
2. **Append-Only Entries**: Never edit or remove existing journal entries. Only append new ones.
3. **Format Preservation**: Maintain canonical frontmatter field order. Use double quotes.
4. **Discussion IDs**: New discussions must use the next sequential ID (e.g., if last is XX-D003, use XX-D004).

---

## Usage

```bash
/afx-session note "content" [tags] [--ref id]    # Smart Note (unifies note/capture/append)
/afx-session log [feature]                       # Save session to log
/afx-session recap [feature|all]                 # AI synthesis of context for resumption
/afx-session promote <id>                        # Promote to ADR
```

> **Note:** Discussion browsing, search, and status filtering are available in the VSCode AFX extension (Journal Tab). These subcommands focus on operations that require agent reasoning or file mutation.

## Purpose

Capture important discussions with AI agents across multiple windows and topics. Unlike `/afx-next` (task state) or `research/` (permanent decisions), this captures the **in-between** - ideas, tips, and context that matter but aren't yet formal decisions.

## Default Location

When no feature is specified, discussions go to `docs/specs/journal.md`. This is for:

- Early-stage ideation
- Cross-cutting discussions
- Ideas that don't yet belong to a feature

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx-session` action, suggest the most appropriate next command based on context:

| Context                         | Suggested Next Command                     |
| ------------------------------- | ------------------------------------------ |
| After `note` (more to discuss)  | Continue discussion or `/afx-session log`  |
| After `note` (ready to work)    | `/afx-task pick <id>` or `/afx-task code`  |
| After `note` (quick note added) | Continue working or `/afx-session recap`   |
| After `log`                     | `/afx-task pick <id>` or `/afx-task code`  |
| After `recap` (resuming work)   | `/afx-next` then `/afx-task code`          |
| After `promote` (ADR created)   | `/afx-dev code` to implement the decision  |

**Suggestion Format** (top 3 context-driven, bottom 2 static):

```
Next (ranked):
  1. /afx-dev code                               # Context-driven: Implement what was discussed
  2. /afx-session log {feature}                   # Context-driven: Summarize before moving on
  3. /afx-session promote UA-D001                 # Context-driven: Elevate to ADR if significant
  ──
  4. /afx-next                                     # Re-orient after capture
  5. /afx-help                                    # See all options
```

---

### Timestamp Format (MANDATORY)

When creating or updating journal entries, captures, notes, and discussion metadata, all timestamps MUST use ISO 8601 with millisecond precision: `YYYY-MM-DDTHH:MM:SS.mmmZ` (e.g., `2025-12-17T14:30:00.000Z`). Never write short formats like `2025-12-17 14:30`.

### Frontmatter (MANDATORY)

All ADRs created via `promote` MUST include AFX frontmatter:

```yaml
---
afx: true
type: ADR
status: Proposed
owner: "@handle"
created_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
updated_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
tags: [<dynamic-feature>, <dynamic-topic>]
source: journal.md#<discussion-id>
---
```

**Tag rules:** Tags are **dynamic** — derived from the feature name and discussion topic (e.g., `[auth, token-storage]`). Do not use generic placeholders.

---

### 1. Parse Subcommand

Determine action from first argument:

| Subcommand | Purpose                                             |
| ---------- | --------------------------------------------------- |
| `note`     | Smart capture (handles notes, tags, and appending)  |
| `log`      | Summarize conversation into permanent record        |
| `recap`    | Generate comprehensive recap for session resumption |
| `promote`  | Promote discussion to ADR or new feature spec       |

**Stores discussions in**: `docs/specs/journal.md` (global) or `docs/specs/{feature}/journal.md` (feature-specific).

### When to use

- **note**: Capture thoughts during discussion or write directly — "Forgot to handle null case" or "look into Pulumi for IaC"
- **log**: Summarize a conversation into a permanent record
- **recap**: "What did we discuss last time?"
- **promote**: "This discussion is now an ADR or a new Feature"

---

## Subcommands

---

## 1. note (Smart Note)

**Usage**:

```bash
/afx-session note "content"                    # Auto-tags based on context
/afx-session note "content" #idea #auth        # Explicit tags (Obsidian style)
/afx-session note --ref UA-D001 "content"      # Append to existing discussion
```

### Purpose

Unifies all "input" actions. Whether you are capturing a fleeting thought, adding a formal manual note, or appending to an existing discussion, just use `note`.

### Process

1. **Parse Arguments**:
   - Check for `#tags` in content OR `--tags` flag.
   - Check for `--ref <id>` to determine if this is an append action.
   - Detect feature context (argument or inferred).

2. **Smart Tagging (Active Inference)**:
   - **If tags present**: Use them.
   - **If no tags**: Analyze content + recent context.
     - "We need to fix the auth0 callback" -> `[auth, bug, high-priority]`
     - "Maybe we use Redis here" -> `[architecture, idea, database]`
   - **Obsidian Compatibility**: Convert output tags to `#hash-tags` in the markdown file for interoperability.

3. **Routing**:
   - **If `--ref`**: Append to `**Notes**` section of that discussion ID.
   - **Default**: Append to `## Captures` section of `journal.md`.

### Output Example

```
Captured: "Fix auth callback" [#auth #bug]
to: docs/specs/user-auth/journal.md
```

---

## 2. log

**Usage**: `/afx-session log [feature]`

Summarize the current session's captures into a permanent discussion entry.

### Process

1. **Read Conversation**: Analyze recent chat history or provided summary.
2. **Generate Discussion ID**:
   - Read `<!-- prefix: XX -->` from `journal.md`
   - Find last ID (e.g. `UA-D005`) -> New ID `UA-D006`
3. **Format Entry**: Create structured markdown entry with metadata.
4. **Append to Journal**: Write to `## Discussions` section **at the end** (chronological order - oldest first, newest last).
5. **Clear Scratchpad**: Remove items from `## Captures` if they are covered.

### Active Inference Protocol (CRITICAL)

**When to suggest saving**:
The Agent MUST actively monitor the conversation depth. Suggest `/afx-session log` when:

1.  **key decisions** are made ("Let's use Postgres").
2.  **complex logic** is explained ("The flow requires step A then B").
3.  **session is ending** or context switching.

**Do NOT wait for the user.** If the user says "Okay, that makes sense, let's move on", you SHOULD interject:

> "Before we move on, should I save this decision about Postgres to the session log?

> `> /afx-session log`"

### Proactive Capture Protocol (MANDATORY)

**Cross-cutting rule**: This protocol applies to ALL AFX skills, not just `/afx-session`. When any skill detects a high-impact context change during its operation, it MUST auto-capture to `journal.md` without waiting for the user to invoke `/afx-session`.

#### Trigger Conditions

Auto-capture (without asking) when the agent detects:

| Trigger              | Example                               | What to capture                        |
| -------------------- | ------------------------------------- | -------------------------------------- |
| Decision deferred    | "not now", "later", "future phase"    | Decision + reason + what it blocks     |
| ADR-impacting choice | "let's use Postgres instead of Mongo" | The decision + alternatives considered |
| Spec deviation       | "skip that requirement for MVP"       | Which FR/NFR is affected + why         |
| Research finding     | "turns out X doesn't support Y"       | Finding + source + impact              |
| Architecture change  | "move auth to a separate service"     | What changed + what's affected         |
| Scope cut            | "drop feature X from this release"    | What's cut + where to track it         |

#### Capture Format

Append to `## Captures` section in the appropriate `journal.md`:

```markdown
- **{YYYY-MM-DDTHH:MM:SS.mmmZ}** - [AUTO:{skill}] {one-line summary}
  `[{auto-tags}, auto-capture]`
  **Impact**: {what this affects: ADR/spec/code/research}
  **Action**: {deferred|decided|changed|cut} → {when/what to revisit}
```

#### Rules

1. **Write to `## Captures`** — not `## Discussions` (that's for `/afx-session log`)
2. **Tag with `auto-capture`** — so entries are filterable
3. **Include source skill** — prefix: `[AUTO:afx-dev]`, `[AUTO:afx-spec]`, etc.
4. **No duplicates** — if the same decision was just captured, skip
5. **Feature routing** — if the context has an active feature, write to `docs/specs/{feature}/journal.md`. Otherwise write to `docs/specs/journal.md`
6. **Consolidation** — still suggest `/afx-session log` at natural breakpoints to consolidate captures into full discussion entries

#### Example

During `/afx-dev code`, the user says "let's skip pagination for now, we'll do it in Phase 2":

```markdown
- **2025-03-17T14:30:00.000Z** - [AUTO:afx-dev] Pagination deferred to Phase 2
  `[pagination, deferred, phase-2, auto-capture]`
  **Impact**: spec — FR-7 (pagination) remains unimplemented
  **Action**: deferred → revisit in Phase 2 planning
```

---

## 3. Recap Mode

**Usage**: `/afx-session recap [feature|all]` or `/afx-session recap [feature|all] --tag <tag>`

Generate comprehensive recap for session resumption:

1. **Gather** discussions from specified scope
2. **If `--tag` specified**: Filter to discussions containing that tag
3. **Sort** by date (most recent first)
4. **Generate** recap with tags shown:

```markdown
## Session Recap

### Last 7 Days

#### user-auth (2 discussions)

- **2025-12-15T10:30:00.000Z**: Supplier assignment - Decided on hardcoded Phase 1 approach
- **2025-12-14T16:00:00.000Z**: Email notifications - Deferred to Phase 2

#### agenticflow (1 discussion)

- **2025-12-15T09:15:00.000Z**: PRD-first traceability - Validated uniqueness vs competitors

### Key Decisions Made

1. PRD links required, external links optional (agenticflow)
2. Supplier table deferred to Phase 2 (user-auth)

### Open Items

- [ ] Implement supplier email notifications
- [ ] Create supplier database table

### Resume From

Continue with: {most recent incomplete work}

Next: /afx-next # Then continue with suggested task
```

---

## 4. Promote Mode

**Usage**:

- `/afx-session promote <discussion-id>` - Promote to ADR (e.g., `UA-D001` promotes within user-auth)
- `/afx-session promote <discussion-id> --to <new-feature>` - Promote from `_sessions` to new feature spec (e.g., `GEN-D001 --to multi-tenant`)

#### 4a. Promote to ADR (within feature)

1. **Parse prefix** from discussion ID to determine feature (e.g., `UA-D001` → user-auth)
2. **Find** discussion by ID in `docs/specs/{feature}/journal.md`
3. **Create** ADR in `docs/specs/{feature}/research/{topic-slug}.md`

#### 4b. Promote to New Feature (from \_sessions)

1. **Find** discussion by ID in `docs/specs/journal.md`
2. **Create** new feature spec structure:
   ```text
   docs/specs/{new-feature}/
   ├── spec.md         # Stub with discussion summary as starting point
   ├── design.md       # Empty template
   ├── tasks.md        # Empty template
   └── journal.md  # Move discussion here
   ```
3. **Move** the discussion from `journal.md` to new feature's journal.md
4. **Update** `journal.md` with link: `**Promoted**: [new-feature](../new-feature/journal.md)`

#### ADR Template (for promote to ADR):

```markdown
---
afx: true
type: ADR
status: Accepted
owner: "@handle"
created_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
updated_at: "YYYY-MM-DDTHH:MM:SS.mmmZ"
tags: [<dynamic-feature>, <dynamic-topic>]
source: journal.md#{discussion-id}
---

# ADR: {Topic Title}

**Promoted From**: [journal.md#UA-D001](journal.md#wc-d001---2025-12-15---topic-title)

## Context

{Context from discussion}

## Decision

{Decisions from discussion}

## Consequences

{Derived from tips/ideas}

## Related

- {Related files}
```

3. **Update** discussion entry with link: `**Promoted**: [ADR](research/{slug}.md)`
4. **Confirm** promotion

5. **Suggest next command**:

```
Next: /afx-dev code   # Implement the decision from the ADR
```

Or for new feature promotion:

```
Next: /afx-task pick docs/specs/{new-feature}/tasks.md   # Start implementing new feature
```

---

## Session Log File Structure

**Path**: `docs/specs/{feature}/journal.md`

**IMPORTANT**: Discussions are stored in **chronological order** (oldest first, newest last) for natural reading flow.

```markdown
# Session Log - {Feature Name}

<!-- prefix: XX -->

> Quick captures and discussion history for AI-assisted development sessions.
> See [agenticflowx.md](../../_templates/agenticflowx.md) for workflow.

## Captures

<!-- Quick notes during active chat - cleared when recorded -->

- **2025-12-17T14:30:00.000Z** - Remember to handle edge case X
  `[validation, edge-case]`
- **2025-12-17T14:45:00.000Z** - User prefers approach B over A
  `[architecture, decision]`

---

## Discussions

<!-- Chronological order: oldest first, newest last -->

### XX-D001 - 2025-12-14 - First Topic

`[database, migration]`

**Context**: Initial database setup discussion
...

---

### XX-D002 - 2025-12-15 - Second Topic

`[auth, jwt, multi-tenant, architecture]`

**Context**: What prompted this discussion
**Summary**: Key points in 2-3 sentences
**Decisions**:

- Decision 1
- Decision 2

**Tips/Ideas**:

- Tip 1
- Tip 2

**Notes**:

- **[XX-D002.N1]** **[2025-12-16T10:30:00.000Z]** Later insight after testing `[testing]`

**Related Files**: file1.ts, file2.ts
**Participants**: @rix, Claude

---

### XX-D003 - 2025-12-17 - Latest Topic

`[api, refactor]`

...
```

> **Note**: Work Sessions table lives in `tasks.md`, not `journal.md`. It is updated by `/afx-task` and `/afx-dev` commands, NOT by `/afx-session`.
> **Two-stage verification**: Agent marks `[x]` after checks pass, Human marks `[x]` after code review.
> See [agenticflowx.md#work-sessions](../../docs/agenticflowx/agenticflowx.md#work-sessions) for update rules.

---

## Hierarchical Reference IDs

Each discussion and note gets a globally unique ID with a feature prefix for easy verbal/written reference:

| Level      | Format                 | Example      | Purpose                                       |
| ---------- | ---------------------- | ------------ | --------------------------------------------- |
| Feature    | `{PREFIX}`             | `UA`         | Reference all discussions in a feature        |
| Discussion | `{PREFIX}-D{NNN}`      | `UA-D001`    | Reference a specific discussion               |
| Note       | `{PREFIX}-D{NNN}.N{N}` | `UA-D001.N1` | Reference a specific note within a discussion |

**Usage Examples**:

- "Check the WC discussions" → All user-auth discussions
- "See UA-D001 for context" → Specific discussion
- "Edge case documented in UA-D001.N2" → Specific note within discussion

### Feature Prefixes

| Feature               | Prefix | Example    |
| --------------------- | ------ | ---------- |
| `_sessions` (general) | `GEN`  | `GEN-D001` |
| `user-auth`           | `UA`   | `UA-D001`  |
| `users-permissions`   | `UP`   | `UP-D001`  |
| `agenticflow`         | `AFX`  | `AFX-D001` |

### Prefix Convention

- 2-4 uppercase characters
- Derived from feature folder name (first letters or abbreviation)
- Defined in each feature's `journal.md` via `<!-- prefix: XX -->` comment
- New features: derive prefix, check for conflicts, document in header

### Session Log Header with Prefix

```markdown
# Session Log - Warranty Claims

<!-- prefix: WC -->

## Discussions

### UA-D001 - 2025-12-15 - Topic Title
```

**Rules**:

- Prefixes are globally unique across all features
- The `<!-- prefix: XX -->` comment MUST appear after the title line
- IDs auto-increment within each feature (UA-D001, UA-D002, etc.)
- IDs never change once assigned
- When promoting to ADR, the full prefixed ID is preserved in frontmatter
- Markdown anchor format: `#wc-d001---2025-12-15---topic-title`

---

## Tag Auto-Generation

Tags are automatically generated to enable filtering and recall across sessions.

### Tag Sources (in priority order)

1. **Note content keywords**: auth, database, api, email, validation, migration, etc.
2. **Conversation topic**: What's being discussed in the current session
3. **Files mentioned/modified**: Infer domain from file paths (e.g., `feature-claim.ts` → `user-auth`)
4. **Existing tags**: Reuse tags already in the session-log for consistency
5. **Explicit `--tags`**: User-provided tags are merged with auto-generated ones

### Common Auto-Tags

| Category     | Tags                                        |
| ------------ | ------------------------------------------- |
| Domain       | auth, booking, listing, user-auth           |
| Technical    | database, api, migration, validation        |
| Architecture | architecture, design, refactor, performance |
| Process      | decision, bug, edge-case, phase-1, phase-2  |
| Integration  | email, notification, webhook, third-party   |

### Tag Aggregation in Log Mode

When logging a discussion:

1. Collect all tags from captures in this session
2. Analyze discussion summary for additional tags
3. Deduplicate and sort alphabetically
4. Display aggregated tags on discussion header

---

## Multi-Window Workflow

This command supports working across multiple agent windows:

```
Window 1: Discussing feature A
  > /afx-session note feature-a "important point"
  > Continue discussing...
  > /afx-session log feature-a

Window 2: Discussing feature B
  > /afx-session note feature-b "different topic"
  > Continue discussing...
  > /afx-session log feature-b

Later (any window):
  > /afx-session recap all
  > See summary across both features
```

---

## Integration with Other Commands

| Command      | Relationship                                     |
| ------------ | ------------------------------------------------ |
| `/afx-task`  | Shows task state; `/afx-session` for discussions |
| `/afx-task`  | Reads session logs for task verification         |
| `/afx-check` | Cross-references journal.md                      |
| `/afx-dev`   | Captures discussions about implementation        |

---

## Examples

### Human note (direct entry)

```
/afx-session note "look into Pulumi for IaC" --tags iac,future
```

→ Saves to `docs/specs/journal.md` with explicit tags
→ No agent context needed - just writes directly

### Human note (feature-specific)

```
/afx-session note infrastructure "evaluate CloudWatch vs Datadog" --tags monitoring,decision
```

→ Saves to `docs/specs/infrastructure/journal.md`

### Quick note (agent context)

```
/afx-session note "interesting approach for multi-tenant auth"
```

→ Saves to `docs/specs/journal.md`
→ Agent infers tags from conversation

### Quick note (feature-specific)

```
/afx-session note user-auth "supplier email should include claim number in subject"
```

→ Saves to `docs/specs/user-auth/journal.md`

### Log session summary

```
/afx-session log                       # Log to _sessions
/afx-session log user-auth             # Log to specific feature
```

### Append to existing discussion

```
/afx-session note --ref UA-D001 "edge case: supplier with no email should fail gracefully"
```

→ Parses `UA` prefix → user-auth feature
→ Auto-assigns Note ID `UA-D001.N1` (or next available)
→ Adds to UA-D001's **Notes** section: `- **[UA-D001.N1]** **[timestamp]** edge case...`
→ Output: `Appended to UA-D001: "edge case: supplier..."`

### Recap after time away

```
/afx-session recap all
```

### Promote discussion to ADR (within feature)

```
/afx-session promote UA-D001
```

→ Parses `UA` prefix → user-auth feature
→ Creates `docs/specs/user-auth/research/0002-topic.md`
→ Links back to `journal.md#UA-D001`

### Promote idea to new feature spec

```
/afx-session promote GEN-D003 --to multi-tenant-auth
```

→ Creates `docs/specs/multi-tenant-auth/` with full spec structure
→ Moves discussion GEN-D003 from `_sessions` to new feature
→ New feature gets its own prefix (e.g., `MTA`)
