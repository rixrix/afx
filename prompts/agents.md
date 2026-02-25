# AFX AGENTS.md Snippet

> Copy everything below this line into your AGENTS.md file.

---

## AgenticFlowX - Codex Commands

This project uses **AgenticFlowX (AFX)** with Codex skills. Use `afx-xxx` command names in Codex to run the matching AFX workflow.

### Skill Triggers

When the user asks for one of these commands, use the matching skill:

- `afx-next` -> `.codex/skills/afx-next`
- `afx-discover` -> `.codex/skills/afx-discover`
- `afx-work` -> `.codex/skills/afx-work`
- `afx-dev` -> `.codex/skills/afx-dev`
- `afx-check` -> `.codex/skills/afx-check`
- `afx-task` -> `.codex/skills/afx-task`
- `afx-session` -> `.codex/skills/afx-session`
- `afx-init` -> `.codex/skills/afx-init`
- `afx-context` -> `.codex/skills/afx-context`
- `afx-spec` -> `.codex/skills/afx-spec`
- `afx-report` -> `.codex/skills/afx-report`
- `afx-help` -> `.codex/skills/afx-help`

### Compatibility Rule

If users type Claude-style commands (for example `/afx:work next user-auth`), interpret them as Codex `afx-work` requests and run the equivalent workflow.

### Source of Truth

Codex skills delegate to canonical AFX command definitions in `.claude/commands/afx-*.md`. Keep behavior aligned with those files.
