---
name: afx-hello
description: Verify AFX installation and environment — detect AI provider, confirm skill availability, and show project health snapshot
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "workflow,diagnostics,environment,onboarding"
---

# /afx-hello

Environment diagnostics and AFX installation verification. Useful for onboarding, troubleshooting, and confirming the framework is correctly configured.

## Usage

```bash
/afx-hello
```

## Execution Contract (STRICT)

### Allowed

- Read/list/search files anywhere in workspace
- Read `.afx.yaml` configuration
- Check for presence of skill files, templates, and spec directories

### Forbidden

- Create/modify/delete any files
- Run build/test/deploy/migration commands

If changes are requested, return:

```text
Out of scope for /afx-hello (read-only diagnostics mode). Use /afx-init to scaffold or /afx-spec to manage specs.
```

---

## Agent Instructions

### Diagnostics Process

When invoked, perform these checks and report results:

1. **AI Provider Detection**
   - Identify which AI agent is running (Claude Code, Copilot, Cursor, Cline, Codex, etc.)
   - Report model name if available

2. **AFX Installation Check**
   - `.afx.yaml` exists and is parseable
   - `.claude/skills/` directory exists with skill files
   - `.agents/skills/` directory exists (if multi-agent)
   - `CLAUDE.md` exists and references AFX
   - `docs/agenticflowx/` directory exists with framework docs

3. **Skill Availability**
   - List all installed AFX skills (scan skill directories)
   - Flag any expected skills that are missing

4. **Project Health Snapshot**
   - Count specs under `docs/specs/` (total, by status if parseable)
   - Check for `.afx.yaml` config completeness
   - Report any obvious issues (missing templates dir, broken paths)

### Output Format

```markdown
## AFX Environment Check

**Agent**: Claude Code (claude-opus-4-6)
**Workspace**: /path/to/project

### Installation

| Component          | Status | Path                        |
| ------------------ | ------ | --------------------------- |
| .afx.yaml          | ✓      | .afx.yaml                   |
| CLAUDE.md          | ✓      | CLAUDE.md                   |
| Skills (Claude)    | ✓      | .claude/skills/ (14 skills) |
| Skills (Agents)    | ✓      | .agents/skills/ (14 skills) |
| Templates          | ✓      | docs/agenticflowx/templates |
| Framework Docs     | ✓      | docs/agenticflowx/          |

### Project Health

| Metric        | Value |
| ------------- | ----- |
| Total Specs   | 12    |
| Draft         | 3     |
| Approved      | 7     |
| Living        | 2     |

### Quick Start

Ready to go! Try:
  /afx-next                    # What should I do now?
  /afx-spec create <name>     # Start a new feature
  /afx-discover capabilities  # Explore the project
```
