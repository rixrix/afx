> [!WARNING]
> **Repository sunset.** AgenticFlowX is now a VSCode extension at <https://agenticflowx.github.io/>. The standalone AFX skill workflow lives at <https://github.com/agenticFlowX/afx>. Install commands and curl URLs below reference the deprecated `rixrix/afx` URL — do not execute them; use the canonical org repo instead.

---

# AGENTS.md

Project instructions for Codex and compatible coding agents working in this repository.

## Project Overview

AFX (AgenticFlowX) provides spec-driven workflows for AI coding agents.

This repository contains:

- Standard-compliant skills in `skills/` (SKILL.md format)
- Pack manifests in `packs/` (grouping skills into installable packs)
- Framework docs in `docs/`
- Installer and prompt snippets for downstream projects

## AFX Skills

All skills use the Agent Skills standard format (SKILL.md with 4-field frontmatter). Skills are organized by category:

- `skills/dev/` — Developer skills (clean-code, tdd, debugging, git, patterns)
- `skills/qa/` — QA skills (methodology, test-planning)
- `skills/security/` — Security skills (owasp, audit)
- `skills/architect/` — Architect skills (architect, research)
- `skills/product-owner/` — Product owner skills
- `skills/starter/` — Starter skills (hello)
- `skills/agenticflowx/` — Workflow skills (next, work, dev, check, task, session, etc.)

## Provider Targets

Skills are installed to provider-specific directories by `afx-cli`:

| Provider | Target Directory  | Agents                          |
| -------- | ----------------- | ------------------------------- |
| agents   | `.agents/skills/` | Claude Code, Codex, Antigravity |
| copilot  | `.github/agents/` | GitHub Copilot                  |

## Timestamp Rule (ISO 8601)

All timestamps in AFX-generated documents — frontmatter (`created_at`, `updated_at`), inline metadata, journal entries, session captures — MUST use **ISO 8601 with millisecond precision**: `YYYY-MM-DDTHH:MM:SS.mmmZ` (e.g., `2025-12-17T14:30:00.000Z`). To get the current timestamp, run `date -u +"%Y-%m-%dT%H:%M:%S.000Z"` via shell. Never guess or use midnight (`T00:00:00.000Z`).

## Source of Truth

Canonical skill definitions live in `skills/` (standard SKILL.md format).
- `.github/prompts/afx-*.prompt.md` (GitHub Copilot)

See [Multi-Agent Commands](docs/agenticflowx/multi-agent.md) for parity mapping.
