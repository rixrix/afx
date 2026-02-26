---
afx: true
type: GUIDE
status: Living
tags: [afx, codex, skills, commands, copilot]
---

# AFX Multi-Agent Commands

AFX supports multiple AI agents through platform-specific command implementations.

## Naming & Execution

| Agent              | Command Format             | Implementation Location           |
| ------------------ | -------------------------- | --------------------------------- |
| **Claude**         | `/afx:work next user-auth` | `.claude/commands/afx-*.md`       |
| **Gemini CLI**     | `/afx:work next user-auth` | `.gemini/commands/afx-*.md`       |
| **Codex**          | `afx-work next user-auth`  | `.codex/skills/afx-*`             |
| **GitHub Copilot** | `afx-work next user-auth`  | `.github/prompts/afx-*.prompt.md` |

## Parity Map

| Claude Slash Command | Gemini Command  | Codex Skill    | Copilot Prompt           |
| -------------------- | --------------- | -------------- | ------------------------ |
| `/afx:next`          | `/afx:next`     | `afx-next`     | `afx-next.prompt.md`     |
| `/afx:discover`      | `/afx:discover` | `afx-discover` | `afx-discover.prompt.md` |
| `/afx:work`          | `/afx:work`     | `afx-work`     | `afx-work.prompt.md`     |
| `/afx:dev`           | `/afx:dev`      | `afx-dev`      | `afx-dev.prompt.md`      |
| `/afx:check`         | `/afx:check`    | `afx-check`    | `afx-check.prompt.md`    |
| `/afx:task`          | `/afx:task`     | `afx-task`     | `afx-task.prompt.md`     |
| `/afx:session`       | `/afx:session`  | `afx-session`  | `afx-session.prompt.md`  |
| `/afx:init`          | `/afx:init`     | `afx-init`     | `afx-init.prompt.md`     |
| `/afx:context`       | `/afx:context`  | `afx-context`  | `afx-context.prompt.md`  |
| `/afx:spec`          | `/afx:spec`     | `afx-spec`     | `afx-spec.prompt.md`     |
| `/afx:report`        | `/afx:report`   | `afx-report`   | `afx-report.prompt.md`   |
| `/afx:help`          | `/afx:help`     | `afx-help`     | `afx-help.prompt.md`     |
| `/afx:update`        | `/afx:update`   | `afx-update`   | `afx-update.prompt.md`   |

## Behavior Contract

All agent-specific implementations (Codex skills, Gemini commands, Copilot prompts) delegate to the canonical command specs in `.claude/commands/afx-*.md`. This ensures consistent behavior, traceability requirements, and quality gates across all AI assistants.
