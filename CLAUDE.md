# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AFX (AgenticFlowX) is a **spec-driven development framework** for AI-assisted coding workflows. It provides bidirectional traceability between specifications and code, ensuring AI agents maintain alignment with project requirements.

This is a **documentation and tooling repository** - it contains:

- Claude Code slash commands (`.claude/commands/`)
- Codex skills (`.codex/skills/`)
- Gemini CLI commands (`.gemini/commands/`)
- GitHub Copilot prompts (`.github/prompts/`)
- Spec templates (`templates/`)
- Framework documentation (`docs/`)
- CLAUDE.md snippets for integration (`prompts/`)

## Repository Structure

```
afx/
├── .agent/skills/        # AFX Antigravity skills (afx-*)
├── .claude/commands/     # AFX slash commands (/afx:*)
├── .codex/skills/        # AFX Codex skills (afx-*)
├── .gemini/commands/     # AFX Gemini CLI commands (/afx:*)
├── .github/prompts/      # AFX GitHub Copilot prompts
├── packs/                # Pack manifests + index (afx-pack-*.yaml)
├── skills/               # AFX-built skills (guardrails baked in)
├── scripts/              # Utility scripts (sync, install support)
├── docs/
│   ├── adr/             # Global Architecture Decision Records
│   ├── agenticflowx/
│   │   ├── agenticflowx.md  # Full framework manual
│   │   ├── guide.md         # SDD methodology guide
│   │   └── cheatsheet.md    # Quick reference
│   └── specs/           # Feature specs (spec.md, design.md, tasks.md, journal.md)
├── templates/           # Spec templates (spec.md, design.md, tasks.md, adr.md, etc.)
├── prompts/             # Snippets to add to target project CLAUDE.md
├── examples/            # Example project setup
└── .afx.yaml.template   # Configuration template
```

## Development

This is a documentation-only repo with no build or test commands. Changes are verified by:

1. Testing commands in a real project (copy to `.claude/commands/`)
2. Testing Codex skills in a real project (copy to `.codex/skills/`)
3. Testing Antigravity skills in a real project (copy to `.agent/skills/`)
4. Testing Copilot prompts in a real project (copy to `.github/prompts/`)
5. Reviewing markdown rendering
6. Verifying YAML frontmatter syntax

## Key Concepts

### Spec-Driven Development (SDD)

All work originates from approved specification documents. The four-file structure per feature:

- `spec.md` - Requirements (WHAT to build)
- `design.md` - Architecture (HOW to build it)
- `tasks.md` - Implementation checklist (WHEN to build)
- `journal.md` - Session logs and discussion history

### @see Traceability

Code MUST link back to specs via JSDoc `@see` annotations:

```typescript
/**
 * @see docs/specs/{feature}/design.md#section
 * @see docs/specs/{feature}/tasks.md#2.1-task-slug
 */
```

### AFX Commands

| Command         | Purpose                                             |
| --------------- | --------------------------------------------------- |
| `/afx:next`     | Context-aware "What should I do now?"               |
| `/afx:discover` | Project discovery (scripts, tools, capabilities)    |
| `/afx:work`     | Workflow orchestration (status, next, resume, sync) |
| `/afx:dev`      | Development with @see traceability                  |
| `/afx:check`    | Quality gates (path, lint, links)                   |
| `/afx:task`     | Task verification and auditing                      |
| `/afx:session`  | Discussion capture and recall                       |
| `/afx:init`     | Feature scaffolding + ADR creation                  |
| `/afx:context`  | Agent session context                               |
| `/afx:update`   | Framework update check and apply                    |

### Standard Workflow

```
/afx:next                      # What do I do now?
/afx:discover capabilities     # Understand project setup
/afx:work status               # Check current state
/afx:work next <spec>          # Pick next task
/afx:dev code                  # Implement with @see links
/afx:check path                # Trace execution flow (BLOCKING)
/afx:task audit                # Verify against spec
/afx:session save              # Save discussion to journal
```

### Quality Gates

Gate 1 (`/afx:check path`) is **blocking** - tasks cannot be closed without path verification that traces execution from UI to DB.

### Two-Stage Verification

Tasks require both Agent verification (`[OK]`) AND Human approval (`[OK]`) before completion. The Work Sessions table in `journal.md` tracks both columns.

## Frontmatter Schema

All AFX documents use YAML frontmatter:

```yaml
---
afx: true # AFX ownership marker
type: SPEC # SPEC | DESIGN | TASKS | JOURNAL | COMMAND
status: Draft # Draft | Approved | Living
owner: "@handle"
version: 1.0
created: YYYY-MM-DDTHH:MM:SS.mmmZ # ISO 8601 with milliseconds
last_verified: YYYY-MM-DDTHH:MM:SS.mmmZ # Last review timestamp
tags: [feature, topic]
spec: spec.md # Relative link (DESIGN, TASKS only)
design: design.md # Relative link (TASKS only)
---
```

> **Rule:** YAML frontmatter is the **single source of truth** for status, version, date, owner, and cross-references. Do NOT duplicate these as `**Status:**`, `**Version:**`, `**Date:**`, or `**Author:**` lines in the markdown body.

## Git Commit Attribution

When committing to this repository, append the appropriate co-author trailer to every commit message:

```
Co-authored-by: claude <noreply@anthropic.com>
Co-authored-by: codex <noreply@openai.com>
Co-authored-by: gemini-code-assist <noreply@gemini.google.com>
Co-authored-by: gemini-code-assist[bot] <176961590+gemini-code-assist[bot]@users.noreply.github.com>
Co-authored-by: copilot <noreply@github.com>
```

Use only the line matching the agent that assisted with the commit.

## Integration

**One-line install** (from target project directory):

```bash
curl -sL https://raw.githubusercontent.com/rix/afx/main/install.sh | bash -s -- .
```

**Local install** (if AFX is cloned):

```bash
./install.sh /path/to/target/project
```

**Update existing installation**:

```bash
curl -sL https://raw.githubusercontent.com/rix/afx/main/install.sh | bash -s -- --update .
```

**Options**:

- `--update` - Update existing installation (preserves user config)
- `--commands-only` - Only install command assets (`.claude` + `.codex` + `.gemini` + `.github/prompts`)
- `--no-claude-md` - Skip CLAUDE.md snippet integration
- `--no-agents-md` - Skip AGENTS.md snippet integration
- `--no-gemini-md` - Skip GEMINI.md snippet integration
- `--no-copilot-md` - Skip copilot-instructions.md snippet integration
- `--no-docs` - Skip copying AFX documentation to docs/agenticflowx/
- `--dry-run` - Preview changes without applying
- `--force` - Overwrite all files (fresh install)
