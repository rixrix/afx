# AFX AGENTS.md Snippet

> Copy everything below this line into your AGENTS.md file.

---

## AgenticFlowX - AI Commands

This project uses **AgenticFlowX (AFX)**. Use the appropriate command format for your platform:

### Codex Skills

Use `afx-xxx` command names to run the matching AFX workflow:

- `afx-next`, `afx-discover`, `afx-design`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-init`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-hello`.

### Gemini CLI Commands

Use `/afx-xxx` slash commands to run AFX workflows:

- `/afx-next`, `/afx-discover`, `/afx-design`, `/afx-dev`, `/afx-check`, `/afx-task`, `/afx-session`, `/afx-init`, `/afx-context`, `/afx-spec`, `/afx-report`, `/afx-help`, `/afx-hello`.

### GitHub Copilot Prompts

Use `afx-xxx` prompt files in `.github/agents/`:

- `afx-next`, `afx-discover`, `afx-design`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-init`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-hello`.

### Source of Truth

All agent platforms delegate to canonical skill definitions in:

- `skills/agenticflowx/` (canonical workflow skills)
- `.claude/skills/` (Claude Code skill target)
- `.agents/skills/` (Codex, Copilot, Antigravity skill target)
