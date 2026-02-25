# AGENTS.md

Project instructions for Codex and compatible coding agents working in this repository.

## Project Overview

AFX (AgenticFlowX) provides spec-driven workflows for AI coding agents.

This repository contains:

- Claude command specs in `.claude/commands/`
- Codex skills in `.codex/skills/`
- Framework docs in `docs/`
- Installer and prompt snippets for downstream projects

## AFX Codex Commands

Use `afx-xxx` skills for command execution:

- `afx-next`
- `afx-discover`
- `afx-work`
- `afx-dev`
- `afx-check`
- `afx-task`
- `afx-session`
- `afx-init`
- `afx-context`
- `afx-spec`
- `afx-report`
- `afx-help`

## Command Compatibility

- Claude form: `/afx:work next user-auth`
- Codex form: `afx-work next user-auth`

If a user types Claude-style slash syntax, interpret it as the equivalent `afx-xxx` Codex skill workflow.

## Source of Truth

Codex skills delegate to canonical AFX command definitions in:

- `.claude/commands/afx-*.md`

When updating behavior, keep `.codex/skills/afx-*` and `.claude/commands/afx-*.md` aligned.
