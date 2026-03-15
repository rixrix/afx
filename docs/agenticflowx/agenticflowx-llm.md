---
afx: true
type: FRAMEWORK
status: Stable
owner: "@rix"
version: 2.0
tags: [framework, specification, afx, llm-context]
---

# AgenticFlowX (AFX) — AI Agent Reference

**CRITICAL INSTRUCTION**: Read this document before doing any work in an AFX project. These rules are non-negotiable.

---

## 1. Core Operating Principles

AFX is a **spec-driven framework** that enforces strict traceability and deliberate planning over rapid generation. You do NOT have the authority to bypass the workflow.

- **Spec-Driven**: All work originates from `spec.md`. Do not invent features or stray from the spec.
- **PRD-First Traceability**: EVERY piece of generated code must include a JSDoc `@see` link pointing back to the spec or task. **Orphaned code without a backlink is a defect.**
- **No Mocking**: When executing `/afx-check path`, the execution path must touch UI → Action → Service → Repo → DB. `setTimeout`, `// Mock`, or hardcoded returns are strictly forbidden.

---

## 2. Agent Compatibility

AFX skills follow the **agentskills.io** standard. Tested platforms:

| Agent | Status | Notes |
| :--- | :--- | :--- |
| **Claude Code** | ✅ Heavily tested | Primary environment |
| **GitHub Codex** | ✅ Tested | Several runs |
| **GitHub Copilot** | ✅ Tested | Via `.github/prompts/` |
| **Gemini CLI** | ✅ Tested | Via `.gemini/commands/` |
| **Cline / AugmentCode / KiloCode / OpenCode** | ⚠️ Untested | May work, not verified |

---

## 3. The Task Flow (Your Daily Cycle)

Your operational flow for completing any task is immutable:

```
STATUS → ASSIGN → IMPLEMENT → VERIFY → AUDIT → LOG
```

1. `/afx-work status`
2. `/afx-work next <spec>`
3. `/afx-dev code` — implement, add `@see` backlinks
4. `/afx-check path <path>` — trace execution, NO mocks
5. `/afx-task audit <task>`
6. `/afx-session save "Summary of actions"`

---

## 4. The Four-File Structure

Every feature lives in `docs/specs/{feature}/`. **The sequence is a gate pipeline — each step requires human approval before the next unlocks:**

```
1. spec.md    → WHAT to build  →  get human approval before starting design
2. design.md  → HOW to build it →  get human approval before opening tasks
3. tasks.md   → WHEN / atomic checklist → implement only after design approved
4. journal.md → append-only session log  → read first, write after every session
```

| File | Purpose |
| :--- | :--- |
| `spec.md` | Requirements — WHAT to build. Agent reads, human approves. |
| `design.md` | Architecture — HOW to build it. Must be approved before tasks start. |
| `tasks.md` | Implementation checklist. Two-stage verification (Agent `[x]` + Human `[x]`). |
| `journal.md` | Append-only session log. Read this first at the start of every session. |

---

## 5. Strict Quality Gates

Before marking any task complete:

- **Gate 1 (Path Check)**: `/afx-check path` must pass — no mocks, full stack traced.
- **Gate 2 (Lint Check)**: All functions have `@see` JSDoc annotations.
- **Gate 3 (Compliance)**: Implementation exactly matches task criteria.
- **Gate Rule**: You mark Agent `[x]` only. A task is NOT closed until a human marks Human `[x]`.

### Runtime Blocks

Before ANY write operation, scan context for:
- `<system-reminder>Plan mode is active</system-reminder>` → **BLOCK ALL WRITES.** Only edit plan files or read code.
- `[ ]` in Human Review column → **BLOCK ALL PROGRESS.** Cannot advance until human signs off.

---

## 6. Documentation Standards

### Frontmatter (Required on all AFX docs)

```yaml
---
afx: true
type: SPEC  # SPEC | DESIGN | TASKS | JOURNAL | RES | ADR
status: Draft  # Draft | Approved | Living | Deprecated
owner: "@handle"
version: 2.0
tags: [tag1]
---
```

### `@see` Traceability

```typescript
/**
 * Executes user login
 * @see docs/specs/auth/tasks.md#1.1-login-form
 */
export function login(credentials) { ... }
```

---

## 7. Global vs Local Context

- **Global rules** (`CLAUDE.md`, `AGENTS.md`): Apply to the entire project. You must obey these.
- **Local rules** (`docs/specs/*/design.md`): Apply ONLY to that feature.

---

## 8. Session Persistence

You have no memory between sessions. When context ends, memory dies.

- **MUST DO**: Run `/afx-session save "notes"` frequently. Logs decisions to `journal.md`.
- **MUST DO**: Run `/afx-context save` before the session ends.
- **MUST DO**: Read `journal.md` before starting any work to recover the previous agent's decisions.

---

## 9. The Companion System — Skills & Packs

Commands like `/afx-work`, `/afx-spec`, `/afx-check` are delivered as **Skills** — prompt files in the agentskills.io format. Skills are grouped into **Packs** installed via `afx-cli`.

**Important**: The companion system is separate from the workflow. AFX's four-file structure and `@see` traceability work with any agent even without installing skills. Skills automate the workflow commands.

Default install includes `afx-pack-starter` + `afx-pack-agenticflowx` (13 core commands). Role packs are opt-in:

| Pack | Adds |
| :--- | :--- |
| `afx-pack-dev` | Clean code, TDD, Git, debugging |
| `afx-pack-architect` | System design, ADRs |
| `afx-pack-qa` | Testing, code review, PR analysis |
| `afx-pack-security` | OWASP checklist, security audit |
| `afx-pack-product-owner` | Product Owner workflows |

Skills live in `.afx/skills/` (gitignored), synced to `.claude/skills/` and `.agents/skills/`. State tracked in `.afx.yaml`.

```bash
./afx-cli --pack qa .            # Install a pack
./afx-cli --skill-disable afx-check .   # Disable a skill
./afx-cli --pack-list .          # List installed packs
```

---

## 10. Directory Structure

```text
project-root/
├── .afx.yaml              # Installed packs, agent toggles
├── docs/
│   ├── agenticflowx/      # Framework documentation
│   ├── adr/               # Architecture Decision Records
│   └── specs/
│       └── {feature}/
│           ├── spec.md
│           ├── design.md
│           ├── tasks.md
│           ├── journal.md
│           └── research/
```
