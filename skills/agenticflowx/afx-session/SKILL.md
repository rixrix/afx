---
name: afx-session
description: Session discussion capture — smart notes, session logs, discussion recall, multi-topic summaries, and ADR promotion
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,session,notes,discussion,journal"
---

# /afx-session

Session discussion capture and recall for multi-agent workflows.

## Configuration

**Read config** using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides).

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.sessions` - Global discussion location (default: `docs/specs`)
- `prefixes` - Feature prefix mappings for discussion IDs

If neither file exists, use defaults.

## Usage

```bash
/afx-session note "content" [tags] [--ref id]    # Smart Note (New! Unifies note/capture/append)
/afx-session save [feature]                      # Save session to log
/afx-session show [feature|all]                  # Show recent discussions
/afx-session active [feature|all]                # Show only active discussions
/afx-session search "<query>"                    # Search notes
/afx-session recap [feature|all]                 # Recap contexts
/afx-session promote <id>                        # Promote to ADR
```

## Purpose

Capture important discussions with AI agents across multiple windows and topics. Unlike `/afx-work status` (task state) or `research/` (permanent decisions), this captures the **in-between** - ideas, tips, and context that matter but aren't yet formal decisions.

## Default Location

When no feature is specified, discussions go to `docs/specs/journal.md`. This is for:

- Early-stage ideation
- Cross-cutting discussions
- Ideas that don't yet belong to a feature

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx-session` action, suggest the most appropriate next command based on context:

| Context                           | Suggested Next Command                          |
| --------------------------------- | ----------------------------------------------- |
| After `capture` (more to discuss) | Continue discussion or `/afx-session record`    |
| After `capture` (ready to work)   | `/afx-work next <spec>` or `/afx-dev code`      |
| After `note` (quick note added)   | Continue working or `/afx-session show`         |
| After `record`                    | `/afx-work next <spec>` or `/afx-dev code`      |
| After `recap` (resuming work)     | `/afx-work status` then `/afx-dev code`         |
| After `show` (reviewing)          | `/afx-session recap <feature>` for full context |
| After `search` (found results)    | `/afx-session show <feature>` for full context  |
| After `promote` (ADR created)     | `/afx-dev code` to implement the decision       |

**Suggestion Format** (5 ranked options, ideal → less ideal):

```
Next (ranked):
  1. /afx-dev code                              # Ideal: Implement what was discussed
  2. /afx-work next docs/specs/{feature}        # Start next task from spec
  3. /afx-session record {feature}              # Summarize before moving on
  4. /afx-session promote UA-D001               # Elevate to ADR if significant
  5. /afx-session recap all                     # Review broader context
```

---

### 1. Parse Subcommand

Determine action from first argument:

| Subcommand | Purpose                                               |
| ---------- | ----------------------------------------------------- |
| `note`     | Smart capture (handles notes, tags, and appending)    |
| `save`     | Summarize conversation into permanent record          |
| `show`     | Display recent discussions                            |
| `active`   | Show only active discussions (tagged `status:active`) |
| `search`   | Search notes and discussions across all journals      |
| `recap`    | Generate comprehensive recap for session resumption   |
| `promote`  | Promote discussion to ADR or new feature spec         |

**Stores discussions in**: `docs/specs/journal.md` (global) or `docs/specs/{feature}/journal.md` (feature-specific).

### When to use

- **Capture**: Agent captures during discussion "Forgot to handle null case"
- **Note**: Human writes directly "look into Pulumi for IaC" (without needing agent conversation)
- **Record**: Summarize a conversation into a permanent record
- **Search**: Find past notes "What did we say about monitoring?"
- **Recap**: "What did we discuss last time?"
- **Promote**: "This discussion is now an ADR or a new Feature"

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

## 2. save

**Usage**: `/afx-session save [feature]`

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
The Agent MUST actively monitor the conversation depth. Suggest `/afx-session save` when:

1.  **key decisions** are made ("Let's use Postgres").
2.  **complex logic** is explained ("The flow requires step A then B").
3.  **session is ending** or context switching.

**Do NOT wait for the user.** If the user says "Okay, that makes sense, let's move on", you SHOULD interject:

> "Before we move on, should I save this decision about Postgres to the session log?

> `> /afx-session save`"

---

---

### 5. Show Mode

**Usage**: `/afx-session show [feature|all]` or `/afx-session show [feature|all] --tag <tag>`

Display recent discussions:

1. **If feature specified**: Read `docs/specs/{feature}/journal.md`
2. **If "all"**: Scan all `docs/specs/*/journal.md` files
3. **If `--tag` specified**: Filter to discussions containing that tag
4. **Output** formatted table with tags:

```markdown
## Recent Discussions

| Date       | Feature     | Topic                    | Tags                        |
| ---------- | ----------- | ------------------------ | --------------------------- |
| 2025-12-15 | user-auth   | Supplier assignment flow | supplier, email, phase-2    |
| 2025-12-14 | agenticflow | PRD-first traceability   | architecture, documentation |

Next: /afx-session recap {feature} # For full context
```

---

### 5b. Active Mode

**Usage**: `/afx-session active [feature|all]`

Show only discussions tagged with `status:active`. Use this to see what ad-hoc work is in progress across features.

#### Status Keywords

Discussions use inline status tags for tracking:

| Keyword          | Meaning                             |
| ---------------- | ----------------------------------- |
| `status:active`  | Work in progress, has pending items |
| `status:blocked` | Waiting on external dependency      |
| `status:closed`  | Completed or abandoned              |
| _(no status)_    | Treated as closed (legacy)          |

#### Discussion Format with Status

```markdown
### INF-D001 - 2025-12-22 - Warranty Claims Dev Deployment

`status:active` `[deployment, aws, user-auth]`

**Context**: First deployment of user-auth feature...

**Progress**:

- [x] RDS PostgreSQL setup _(N1)_
- [x] Local environment connected _(N2)_
- [ ] Deploy user-auth branch to Amplify
- [ ] Document Amplify configuration
```

> **Note**: Completed items show `_(N{X})_` reference linking to the note that confirmed completion.

#### Process

1. **Scan journals**: Read all `docs/specs/*/journal.md` files (or specific feature)
2. **Filter by status**: Find discussions with `status:active` tag
3. **Extract pending items**: Count unchecked `- [ ]` boxes in Progress section
4. **Format output**:

```markdown
## Active Discussions

| Feature        | ID       | Title                          | Pending |
| -------------- | -------- | ------------------------------ | ------- |
| infrastructure | INF-D001 | Warranty Claims Dev Deployment | 2 items |

### INF-D001 - Warranty Claims Dev Deployment

- [ ] Deploy user-auth branch to Amplify
- [ ] Document Amplify configuration

---

Next: /afx-session append INF-D001 "update note" # Add progress
```

#### No Active Discussions

```
No active discussions found.

To start tracking ad-hoc work:
  /afx-session record infrastructure   # Record current discussion

Or for formal tasks:
  /afx-work next docs/specs/{feature}  # Pick up next spec task
```

---

### 5c. Search Mode

**Usage**: `/afx-session search "<query>" [--tag <tag>] [--feature <feature>]`

Search notes and discussions across all journals. Returns matching captures and discussion entries.

1. **Determine scope**:
   - If `--feature` specified: Search only `docs/specs/{feature}/journal.md`
   - Otherwise: Search all `docs/specs/*/journal.md` files
2. **Search content**:
   - Match query against note text (case-insensitive)
   - If `--tag` specified: Also filter by tag
3. **Return results** grouped by feature:

```markdown
## Search Results: "Pulumi"

### infrastructure (2 matches)

**Captures:**

- **2025-12-17 15:30** - evaluate Terraform vs Pulumi `[iac, decision]`

**Discussions:**

- **INF-D002** - IaC Tool Selection (2025-12-18)
  > "...decided to use Pulumi over Terraform for better TypeScript support..."

### general (1 match)

**Captures:**

- **2025-12-17 14:00** - look into Pulumi for AFX MCP server `[mcp, tooling]`

---

Total: 3 matches across 2 features

Next: /afx-session show infrastructure # See full context
```

**Examples**:

```bash
# Search all journals
/afx-session search "monitoring"

# Search with tag filter
/afx-session search "AWS" --tag infrastructure

# Search specific feature
/afx-session search "email" --feature user-auth
```

**Implementation**:

```bash
# Agent executes grep across journal files
grep -ri "<query>" docs/specs/*/journal.md
grep -ri "<query>" docs/specs/journal.md
```

---

### 6. Recap Mode

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

- **2025-12-15**: Supplier assignment - Decided on hardcoded Phase 1 approach
- **2025-12-14**: Email notifications - Deferred to Phase 2

#### agenticflow (1 discussion)

- **2025-12-15**: PRD-first traceability - Validated uniqueness vs competitors

### Key Decisions Made

1. PRD links required, external links optional (agenticflow)
2. Supplier table deferred to Phase 2 (user-auth)

### Open Items

- [ ] Implement supplier email notifications
- [ ] Create supplier database table

### Resume From

Continue with: {most recent incomplete work}

Next: /afx-work status # Then continue with suggested task
```

---

### 7. Promote Mode

**Usage**:

- `/afx-session promote <discussion-id>` - Promote to ADR (e.g., `UA-D001` promotes within user-auth)
- `/afx-session promote <discussion-id> --to <new-feature>` - Promote from `_sessions` to new feature spec (e.g., `GEN-D001 --to multi-tenant`)

#### 7a. Promote to ADR (within feature)

1. **Parse prefix** from discussion ID to determine feature (e.g., `UA-D001` → user-auth)
2. **Find** discussion by ID in `docs/specs/{feature}/journal.md`
3. **Create** ADR in `docs/specs/{feature}/research/{topic-slug}.md`

#### 7b. Promote to New Feature (from \_sessions)

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
type: ADR
status: Accepted
owner: @rix
date: {original date}
tags: [{feature}, {topic}]
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
Next: /afx-work next docs/specs/{new-feature}/tasks.md   # Start implementing new feature
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

- **2025-12-17 14:30** - Remember to handle edge case X
  `[validation, edge-case]`
- **2025-12-17 14:45** - User prefers approach B over A
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

- **[XX-D002.N1]** **[2025-12-16 10:30]** Later insight after testing `[testing]`

**Related Files**: file1.ts, file2.ts
**Participants**: @rix, Claude

---

### XX-D003 - 2025-12-17 - Latest Topic

`[api, refactor]`

...

```

> **Note**: Work Sessions table lives in `tasks.md`, not `journal.md`. It is updated by `/afx-work` and `/afx-dev` commands, NOT by `/afx-session`.
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

### Tag Aggregation in Record Mode

When recording a discussion:

1. Collect all tags from captures in this session
2. Analyze discussion summary for additional tags
3. Deduplicate and sort alphabetically
4. Display aggregated tags on discussion header

---

## Multi-Window Workflow

This command supports working across multiple agent windows:

```
Window 1: Discussing feature A
  > /afx-session capture feature-a "important point"
  > Continue discussing...
  > /afx-session record feature-a

Window 2: Discussing feature B
  > /afx-session capture feature-b "different topic"
  > Continue discussing...
  > /afx-session record feature-b

Later (any window):
  > /afx-session recap all
  > See summary across both features
```

---

## Integration with Other Commands

| Command      | Relationship                                     |
| ------------ | ------------------------------------------------ |
| `/afx-work`  | Shows task state; `/afx-session` for discussions |
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

### Quick capture (agent context)

```
/afx-session capture "interesting approach for multi-tenant auth"
```

→ Saves to `docs/specs/journal.md`
→ Agent infers tags from conversation

### Quick capture (feature-specific)

```
/afx-session capture user-auth "supplier email should include claim number in subject"
```

→ Saves to `docs/specs/user-auth/journal.md`

### Search notes

```
/afx-session search "monitoring"
/afx-session search "AWS" --tag infrastructure
```

→ Searches all journal.md files
→ Returns grouped results with context

### Record session summary

```
/afx-session save                      # Save to _sessions
/afx-session save user-auth      # Save to specific feature
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
