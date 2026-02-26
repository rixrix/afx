# AFX AGENTS.md Snippet

> Copy everything below this line into your AGENTS.md file.

---

## AgenticFlowX - AI Commands

This project uses **AgenticFlowX (AFX)**. Use the appropriate command format for your platform:

### Codex Skills

Use `afx-xxx` command names to run the matching AFX workflow:

- `afx-next`, `afx-discover`, `afx-work`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-init`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-update`.

### Gemini CLI Commands

Use `/afx:xxx` slash commands to run AFX workflows:

- `/afx:next`, `/afx:discover`, `/afx:work`, `/afx:dev`, `/afx:check`, `/afx:task`, `/afx:session`, `/afx:init`, `/afx:context`, `/afx:spec`, `/afx:report`, `/afx:help`, `/afx:update`.

### GitHub Copilot Prompts

Use `afx-xxx` prompt files in `.github/prompts/`:

- `afx-next`, `afx-discover`, `afx-work`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-init`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-update`.

### Source of Truth

Commands and skills delegate to canonical AFX command definitions in:

- `.claude/commands/afx-*.md`
- `.gemini/commands/afx-*.md` (Gemini CLI)
- `.github/prompts/afx-*.prompt.md` (GitHub Copilot)
