# AGENTS.md

Project instructions for Codex and compatible coding agents working in this repository.

## Project Overview

AFX (AgenticFlowX) provides spec-driven workflows for AI coding agents.

This repository contains:

- Claude command specs in `.claude/commands/`
- Codex skills in `.codex/skills/`
- Gemini CLI commands in `.gemini/commands/`
- GitHub Copilot prompts in `.github/prompts/`
- Framework docs in `docs/`
- Installer and prompt snippets for downstream projects

## AFX AI Commands

This project supports multiple AI agents. Use the appropriate format:

### Codex Skills

Use `afx-xxx` command names:

- `afx-next`, `afx-discover`, `afx-work`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-init`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-update`.

### Gemini CLI Commands

Use `/afx:xxx` slash commands:

- `/afx:next`, `/afx:discover`, `/afx:work`, `/afx:dev`, `/afx:check`, `/afx:task`, `/afx:session`, `/afx:init`, `/afx:context`, `/afx:spec`, `/afx:report`, `/afx:help`, `/afx:update`.

### GitHub Copilot Prompts

Use `afx-xxx` prompt files in `.github/prompts/`:

- `afx-next`, `afx-discover`, `afx-work`, `afx-dev`, `afx-check`, `afx-task`, `afx-session`, `afx-init`, `afx-context`, `afx-spec`, `afx-report`, `afx-help`, `afx-update`.

## Command Compatibility

- Claude/Gemini: `/afx:work next user-auth`
- Codex: `afx-work next user-auth`
- Copilot: `afx-work next user-auth` (via `.github/prompts/`)

## Source of Truth

Agent-specific commands and skills delegate to canonical definitions in:

- `.claude/commands/afx-*.md`
- `.gemini/commands/afx-*.md` (Gemini CLI)
- `.github/prompts/afx-*.prompt.md` (GitHub Copilot)

See [Multi-Agent Commands](docs/agenticflowx/multi-agent.md) for parity mapping.
