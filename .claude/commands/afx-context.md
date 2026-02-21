---
afx: true
type: COMMAND
status: Living
tags: [afx, command, context, session]
---

# 🤝 Session Context protocol for seamless context transfer between AI sessions.

## Configuration

**Read `.afx.yaml`** at project root to resolve paths:

- `paths.specs` - Where `afx-context.md` and feature specs live (default: `docs/specs`)

If `.afx.yaml` doesn't exist, use defaults.

## Usage

```bash
/afx:context save [feature]       # Generate context (auto-detects all features if omitted)
/afx:context load                 # Load context from docs/specs/afx-context.md
/afx:context history [feature]    # Show spec evolution timeline
/afx:context impact <change>      # Analyze cross-feature impact
```

## Purpose

Formalize context transfer between AI agent sessions. When an agent times out, disconnects, or needs to hand off work, this command ensures the next agent can resume exactly where the previous one left off.

**Also serves as human memory refresh** — contexts are written detailed enough for a developer to recall a session from 3+ days ago, including reasoning, decisions, and research findings.

**Unique to AFX**: No other framework provides structured agent-to-agent context with context preservation.

## Agent Instructions

### Next Command Suggestion (MANDATORY)

| Context                       | Suggested Next Command                      |
| ----------------------------- | ------------------------------------------- |
| After `save` (context ready)  | Share bundle, then session ends             |
| After `load` (context loaded) | `/afx:dev code` to continue work            |
| After `history` (reviewing)   | `/afx:work next` or `/afx:dev`              |
| After `impact` (analyzing)    | Review affected files, then `/afx:dev code` |

---

## Storage

**Single file**: `docs/specs/afx-context.md`

- One centralized location — no scanning across spec folders
- `pCreate or overwrite the `afx-context.md` file using this structure, filled with data from the steps above.sume` reads this file, then asks user whether to clear it
- History preserved via one-liner archive entries in each feature's `journal.md` (historical contexts and narratives should _always_ go here, never in living documents like `design.md` or `spec.md`)

---

## Subcommands

---

## 1. save

Generate a detailed context bundle for the next agent session (or for human recall).

### Usage

s

```bash
/afx:context save                 # Auto-detect all features from git diff + session context
/afx:context save user-auth       # Single feature override
```

### Process

1. If `.afx.yaml` not found, use `docs/specs/afx-context.md` as default. If it exists and is NOT cleared, warn: "Existing context found. Overwrite?" Wait for confirmation before proceeding.
2. **Detect features**: From git diff + session context (or argument). Identify ALL features touched this session.
3. **Read session state** (per feature):
   - Current/completed tasks from tasks.md
   - Recent journal.md entries and discussions
   - Key decisions with reasoning (Reminder: ensure all reasoning and history is logged to `journal.md` and _not_ to living docs like `design.md`)
   - Blockers (any BLOCKED entries in Work Sessions)
4. **Read uncommitted files**: `git diff --stat` + `git status`
5. **Generate bundle**: Detailed markdown using the template below
6. **Persist**: Write to `docs/specs/afx-context.md` (overwrite)

### Template

**CRITICAL**: The save output must be detailed enough for a human to recall the session 3+ days later. Include reasoning, not just actions. Preserve specifics verbatim (numbers, counts, call sites). Use emojis and tables for visual scanning.

````markdown
---
afx: true
type: HANDOFF
status: Active
prepared: { YYYY-MM-DD }
branch: { branch-name }
features: [{ feature1 }, { feature2 }]
---

# 🤝 Context

📅 **Prepared**: {date}
🌿 **Branch**: `{branch}`
⏱️ **Session Duration**: ~{estimate}
🏷️ **Features**: {feature1}, {feature2}

---

## 📋 Session Overview

> High-level narrative of what happened this session — written for a human
> reading this 3 days later. What was the goal? What was accomplished?
> What changed direction and why?

{2-4 paragraph narrative covering the session arc: goals → work done →
outcomes → what's next. Include reasoning, not just actions. Mention any
manual testing results, research findings, or exploratory work.}

---

## 🔍 Feature: {feature-name}

### ✅ Completed

| #    | Task        | Detail                                    | Verified                                    |
| ---- | ----------- | ----------------------------------------- | ------------------------------------------- |
| {id} | {task name} | {what was done, with file:line specifics} | {✅ Build / ✅ User / ✅ Test / ⏳ Pending} |

### 🔄 Active Task

> **Task {id}**: {task name}
> **Progress**: {Not started / Partial — what's done, what's left}
> **Blocked by**: {Nothing / specific blocker}
> **Test users**: {credentials if relevant}

### 🚨 Critical Items

> ⚠️ These MUST be preserved verbatim — numbers, counts, specifics matter.
> Never summarize or compress these. They are the most important details
> for the next session.

- **{count} {things}** {specific action needed} (e.g., "14 active call sites need swapping from `getUserService()` → `getUserPermissionService()`")
- **{requirement}** {why it matters} (e.g., "Migration 020 must run before testing 8.2+")

### 🧠 Decisions Made

> **Note**: Verify that all historical reasoning here has been properly logged to `journal.md`. Living documents like `design.md` should only contain the final design state, without historical backstory.

| Decision           | Reasoning                             | Reference                                                   |
| ------------------ | ------------------------------------- | ----------------------------------------------------------- |
| {what was decided} | {why — include trade-offs considered} | [{discussion-id}](docs/specs/{feature}/journal.md#{anchor}) |

### 💬 Discussions & Research

> Summaries of key discussions — enough to recall the reasoning without
> re-reading the full journal. Include conclusions, not just topics.
> Link to journal/research for deep dive.

**{Discussion Title}** ({feature}):
{3-5 sentence summary of what was discussed, what was concluded, and why.
Include specific numbers, findings, or outcomes.}
📄 [{link text}]({path-to-journal-or-research-doc})

### ⚠️ Watch Out

- {Specific gotcha with enough context to understand why it matters}
- {Another gotcha}

### 📎 References

| Type     | Link                                                 | Why                  |
| -------- | ---------------------------------------------------- | -------------------- |
| Tasks    | [{section}](docs/specs/{feature}/tasks.md#{anchor})  | {what to find there} |
| Design   | [{section}](docs/specs/{feature}/design.md#{anchor}) | {what to find there} |
| Journal  | [{id}](docs/specs/{feature}/journal.md#{anchor})     | {what to find there} |
| Research | [{doc}](docs/specs/{feature}/research/{file})        | {what to find there} |

---

## 🔍 Feature: {feature-name-2}

{Repeat same structure for each feature touched in session}

---

## 📁 Uncommitted Files

| Status  | File          | Changes                        |
| ------- | ------------- | ------------------------------ |
| {M/A/D} | `{file-path}` | {brief description of changes} |

> 📊 Total: {N} files ({M} modified, {A} added, {D} deleted)

---

## ➡️ Next Agent Instructions

> Prioritized, actionable steps with specifics. Not vague — include
> task IDs, file paths, and concrete actions.

| Priority | Action   | Detail                                      |
| -------- | -------- | ------------------------------------------- |
| 1        | {action} | {specific detail with task IDs, file paths} |
| 2        | {action} | {specific detail}                           |
| 3        | {action} | {specific detail}                           |

## 🚀 Commands to Start

```bash
/afx:context load           # Load this context
/afx:work resume            # Continue implementation
```
````

---

## 2. load

Load context from a previous context. Fast — reads a single file.

### Usage

```bash
/afx:context load                 # Load from docs/specs/afx-context.md
```

### Process

1. **Read** `docs/specs/afx-context.md`
2. **Check empty**: If `afx-context.md` has `status: Cleared` or is missing, inform user "No active context found" and suggest `/afx:context save`
3. **Output full content**: Display the context bundle as-is. **DO NOT compress, summarize, or omit details** — the save step already structured it for consumption
4. **Archive**: Provide a one-liner archive entry for the user to optionally paste into their `journal.md` under `## Contexts`:

   ```markdown
   ### {date} — Context Loaded

   **Saved**: {original save date}
   **Features**: {feature list}
   ```

### Output

The full context bundle content, followed by:

```markdown
---

✅ **Context loaded from** `docs/specs/afx-context.md`

Next (ranked):

1. `/afx:dev code` — Continue implementation
2. `/afx:work resume` — Pick up from task queue
3. `/afx:session recap {feature}` — Review more context
```

---

## 3. history

Show spec evolution timeline - what changed and when.

### Usage

```bash
/afx:context history user-auth
/afx:context history all               # All specs
```

### Process

1. **Read git log**: Commits touching spec files
2. **Build timeline**: Summarize commits and sort by date

### Output

```markdown
## Spec Timeline: user-auth

### 2025-12-16 - v1.3 (Current)

- Added: Phase 7 supplier assignment
- Changed: Anchor format to dot notation (#7.1-slug)
- Source: UA-D001 discussion promoted

### 2025-12-15 - v1.2

- Added: Session log Work Sessions format
- Fixed: Missing pagination spec in tasks.md

### 2025-12-14 - v1.1

- Added: Phase 6 testing requirements
- Changed: ClaimStatus enum to UPPERCASE

### 2025-12-02 - v1.0

- Initial spec created
- Phases 0-5 defined

---

### Files Changed

| Version | spec.md | design.md | tasks.md |
| ------- | ------- | --------- | -------- |
| v1.3    | -       | +section  | +phase7  |
| v1.2    | -       | -         | +session |
| v1.1    | +enum   | +diagram  | +phase6  |

Next: /afx:work next user-auth # Continue with latest spec
```

---

## 4. impact

Analyze cross-feature impact when specs change.

### Usage

```bash
/afx:context impact "Remove ClaimStatus.DRAFT"
/afx:context impact design.md#supplier-assignment
```

### Process

1. **Parse change**: Identify affected symbols/sections
2. **Search code**: Find @see references to affected sections
3. **Search specs**: Find cross-references between specs
4. **Calculate risk**: Based on number of affected files

### Output

```markdown
## Impact Analysis: Remove ClaimStatus.DRAFT

**Risk Level**: HIGH
**Affected locations**: 18

---

### Code Impact

| Package/App | Files | References    |
| ----------- | ----- | ------------- |
| apps/admin  | 8     | 12 references |
| apps/portal | 4     | 5 references  |
| packages/db | 2     | 3 references  |

**Files to update**:

- src/features/user-auth/claim-list.tsx:45
- src/features/user-auth/claim-form.tsx:89
- packages/db/src/core/services/claim.service.ts:23
- ...

---

### Spec Impact

| Spec              | Cross-References             |
| ----------------- | ---------------------------- |
| users-permissions | Links to user-auth design.md |
| agenticflow       | Example uses ClaimStatus     |

---

### Recommendation

**Breaking Change** - Requires careful migration:

1. Deprecation period: Mark DRAFT as deprecated
2. Migration script: Update existing DRAFT claims
3. Code update: Remove DRAFT from enum
4. Spec update: Remove from design.md

**Estimated effort**: 2-4 hours

Next: /afx:dev code # Start migration if approved
```

---

## Integration

| Command              | Relationship                                    |
| -------------------- | ----------------------------------------------- |
| `/afx:work status`   | Quick state; context is comprehensive           |
| `/afx:session recap` | Discussion summary; context includes work state |
| `/afx:report`        | Metrics; context is per-session context         |
