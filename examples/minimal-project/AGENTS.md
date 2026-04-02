# AGENTS.md

Project instructions for Codex and compatible coding agents.

<!-- AFX-CODEX:START - Managed by AFX. Do not edit manually. -->
<!-- AFX Version: 2.1.0 -->


## AgenticFlowX - AI Commands

This project uses **AgenticFlowX (AFX)**. Use the appropriate command format for your platform:

### Codex Skills

Use `afx-xxx` command names to run the matching AFX workflow:

- `afx-next`, `afx-discover`, `afx-design`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-scaffold`, `afx-adr`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-hello`.

### Gemini CLI Commands

Use `/afx-xxx` slash commands to run AFX workflows:

- `/afx-next`, `/afx-discover`, `/afx-design`, `/afx-dev`, `/afx-check`, `/afx-task`, `/afx-session`, `/afx-scaffold`, `/afx-adr`, `/afx-context`, `/afx-spec`, `/afx-report`, `/afx-help`, `/afx-hello`.

### GitHub Copilot Prompts

Use `afx-xxx` prompt files in `.github/agents/`:

- `afx-next`, `afx-discover`, `afx-design`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-scaffold`, `afx-adr`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-hello`.

### Timestamp Rule (ISO 8601)

All timestamps in AFX-generated documents — frontmatter (`created_at`, `updated_at`), inline metadata, journal entries, session captures — MUST use **ISO 8601 with millisecond precision**: `YYYY-MM-DDTHH:MM:SS.mmmZ` (e.g., `2025-12-17T14:30:00.000Z`). To get the current timestamp, run `date -u +"%Y-%m-%dT%H:%M:%S.000Z"` via shell. Never guess or use midnight (`T00:00:00.000Z`).

### Source of Truth

All agent platforms delegate to canonical skill definitions in:

- `skills/agenticflowx/` (canonical workflow skills)
- `.claude/skills/` (Claude Code skill target)
- `.agents/skills/` (Codex, Copilot, Antigravity skill target)
<!-- AFX-CODEX:END -->
