# AFX GEMINI.md Snippet

> Copy everything below this line into your GEMINI.md file.

---

## AgenticFlowX (AFX) - Spec-Driven Development

This project uses **AgenticFlowX (AFX)** for spec-driven development with bidirectional traceability between specifications and code.

### Core Principle

All work originates from approved specification documents. Every feature uses a four-file structure:

- `spec.md` - Requirements (WHAT to build)
- `design.md` - Architecture (HOW to build it)
- `tasks.md` - Implementation checklist (WHEN to build)
- `journal.md` - Session logs and discussion history

### @see Traceability

Code MUST link back to specs via `@see` annotations. Links to `spec.md` and `design.md` are **required**; links to `tasks.md` are **optional**.

```
/** @see docs/specs/{feature}/spec.md [FR-1] */
/** @see docs/specs/{feature}/design.md [DES-SECTION] */
```

### Gemini CLI Commands

Use `/afx-xxx` slash commands (skills installed to project):

| Command         | Purpose                                          |
| --------------- | ------------------------------------------------ |
| `/afx-next`     | Context-aware "What should I do now?"            |
| `/afx-discover` | Project discovery (scripts, tools, capabilities) |
| `/afx-design`   | Spec authoring and design workflow               |
| `/afx-dev`      | Development with @see traceability               |
| `/afx-check`    | Quality gates (path, lint, links)                |
| `/afx-task`     | Task verification and auditing                   |
| `/afx-session`  | Discussion capture and recall                    |
| `/afx-init`     | Feature scaffolding + ADR creation               |
| `/afx-context`  | Agent session context                            |
| `/afx-spec`     | Spec querying/viewing                            |
| `/afx-report`   | Reporting (health, orphans, coverage)            |
| `/afx-help`     | Command reference                                |
| `/afx-hello`    | Installation verification and health check       |

### Source of Truth

Canonical skill definitions live in `skills/agenticflowx/` (standard SKILL.md format).

### Gemini-Specific Tool Guidance

When executing AFX commands, leverage Gemini's specialized tools:

- **`codebase_investigator`** — High-level architectural analysis, dependency mapping, context for `/afx-next` and `/afx-discover`
- **`grep_search`** — Precise context scanning within specs, journals, and task files
- **`read_file`** — Reading specification documents and command definitions
- **`run_shell_command`** — Git/GitHub CLI operations for state verification and syncing

### Quality Gates

Gate 1 (`/afx-check path`) is **blocking** — tasks cannot be closed without path verification that traces execution from UI to DB.

Tasks require both Agent verification (`[x]`) AND Human approval (`[x]`) before completion.

### Git Commit Attribution

When committing, append the following co-author trailers:

```
Co-authored-by: gemini-code-assist <noreply@gemini.google.com>
Co-authored-by: gemini-code-assist[bot] <176961590+gemini-code-assist[bot]@users.noreply.github.com>
```
