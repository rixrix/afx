---
afx: true
type: GUIDE
status: Living
tags: [afx, codex, skills, commands, copilot]
---

# AFX Multi-Agent Commands

AFX supports multiple AI agents through platform-specific command implementations.

## Naming & Execution

| Agent                            | Command Format             | Provider Target        |
| -------------------------------- | -------------------------- | ---------------------- |
| **Claude + Codex + Antigravity** | `/afx-task pick user-auth` | `.agents/skills/afx-*` |
| **GitHub Copilot**               | `afx-task pick user-auth`  | `.github/agents/afx-*` |

## Parity Map

| Claude Slash Command | Gemini Command  | Codex Skill    | Copilot Prompt           |
| -------------------- | --------------- | -------------- | ------------------------ |
| `/afx-next`          | `/afx-next`     | `afx-next`     | `afx-next.prompt.md`     |
| `/afx-discover`      | `/afx-discover` | `afx-discover` | `afx-discover.prompt.md` |
| `/afx-spec`          | `/afx-spec`     | `afx-spec`     | `afx-spec.prompt.md`     |
| `/afx-design`        | `/afx-design`   | `afx-design`   | `afx-design.prompt.md`   |
| `/afx-task`          | `/afx-task`     | `afx-task`     | `afx-task.prompt.md`     |
| `/afx-dev`           | `/afx-dev`      | `afx-dev`      | `afx-dev.prompt.md`      |
| `/afx-check`         | `/afx-check`    | `afx-check`    | `afx-check.prompt.md`    |
| `/afx-session`       | `/afx-session`  | `afx-session`  | `afx-session.prompt.md`  |
| `/afx-init`          | `/afx-init`     | `afx-init`     | `afx-init.prompt.md`     |
| `/afx-context`       | `/afx-context`  | `afx-context`  | `afx-context.prompt.md`  |
| `/afx-report`        | `/afx-report`   | `afx-report`   | `afx-report.prompt.md`   |
| `/afx-research`      | `/afx-research` | `afx-research` | `afx-research.prompt.md` |
| `/afx-hello`         | `/afx-hello`    | `afx-hello`    | `afx-hello.prompt.md`    |
| `/afx-help`          | `/afx-help`     | `afx-help`     | `afx-help.prompt.md`     |

## Behavior Contract

All skills use a single canonical format (standard SKILL.md in `skills/`). The `afx-cli` installer transforms and copies to each provider's target directory, ensuring consistent behavior across all AI assistants.
