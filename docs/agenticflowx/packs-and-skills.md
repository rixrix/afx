# AFX Packs & Skills

> **Pause. Think. Plan. Ship.**

Commands like `/afx-work next` and `/afx-spec review` are powered by **Skills** — prompt files following the **agentskills.io** standard that teach your AI coding agent how to run an AFX workflow.

Skills are grouped into **Packs** — curated bundles of related skills that you install once via `afx-cli`. AFX ships with 7 packs out of the box.

---

## The Pack System

A pack is a YAML manifest listing which skills to install and where to source them. Sources can be the AFX repo, Anthropic's skills repo, OpenAI's skills repo, or any public GitHub repo.

```yaml
# Example: afx-pack-qa.yaml (abbreviated)
name: afx-pack-qa
description: QA Engineer role pack
category: role

includes:
  - repo: rixrix/afx
    path: skills/qa/
    items:
      - afx-qa-methodology
      - afx-spec-test-planning
  - repo: anthropics/skills
    path: skills/
    items:
      - webapp-testing
  - repo: anthropics/claude-code
    path: plugins/
    items:
      - code-review
      - pr-review-toolkit
```

---

## Available Packs

| Pack                     | Category | Description                                                                               |
| :----------------------- | :------- | :---------------------------------------------------------------------------------------- |
| `afx-pack-starter`       | utility  | Verify AFX installation; multi-provider vibe check                                        |
| `afx-pack-agenticflowx`  | workflow | **Core AFX pack.** All 13 AFX slash commands (`/afx-next`, `/afx-work`, `/afx-dev`, etc.) |
| `afx-pack-dev`           | role     | Developer toolkit — clean code, TDD, Git workflows, architecture patterns, debugging      |
| `afx-pack-architect`     | role     | System design, pattern selection, ADRs, and quality attributes                            |
| `afx-pack-qa`            | role     | Testing, web-app quality review, PR review, test planning linked to spec tasks            |
| `afx-pack-security`      | role     | OWASP top-10 checklist, security audits, Claude security-guidance plugin                  |
| `afx-pack-product-owner` | role     | Product Owner workflow skills                                                             |

> By default, a fresh install adds `afx-pack-starter` and `afx-pack-agenticflowx` automatically.

---

## Installing Skills & Packs

### 1. Fresh install (includes default packs automatically)

```bash
# Remote install
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- .

# Local install
./afx-cli .
```

### 2. Install additional packs

```bash
# Short name or full name both work
./afx-cli --pack qa .
./afx-cli --pack afx-pack-qa .

# Multiple packs at once
./afx-cli --pack qa --pack security .

# Install from a specific version tag
./afx-cli --version 1.5.3 --pack qa .
```

### 3. Install a single skill (no pack)

```bash
# Install one skill from any public GitHub repo
./afx-cli --add-skill rixrix/afx:skills/dev/afx-clean-code .
```

### 4. Update all installed packs

```bash
./afx-cli --update --packs .
```

### 5. Remove a pack

```bash
./afx-cli --pack-remove qa .
```

---

## Where Skills Live

AFX uses a **two-layer** storage model:

```text
your-project/
├── .afx/                      # Canonical store (source of truth — gitignored)
│   └── skills/
│       ├── agenticflowx/      # Core workflow skills (13 total)
│       │   ├── afx-next/
│       │   ├── afx-work/
│       │   └── ...
│       ├── qa/
│       ├── dev/
│       └── ...
├── .claude/                   # Claude Code reads from here
│   └── skills/
│       ├── afx-next/          # Synced from .afx/
│       └── ...
└── .agents/                   # Codex, Copilot, Gemini read from here
    └── skills/
        ├── afx-next/          # Synced from .afx/
        └── ...
```

The `.afx/` folder is **gitignored**. Skills are re-downloaded from pack manifests on-demand; you don't commit them to your repo.

---

## Enabling and Disabling Skills

**Via CLI:**

```bash
# Disable a skill
./afx-cli --skill-disable afx-check .

# Re-enable a skill
./afx-cli --skill-enable afx-check .
```

**Manual toggle** (rename the folder — the agent won't see it):

```bash
mv .claude/skills/afx-check .claude/skills/afx-check.disabled
mv .claude/skills/afx-check.disabled .claude/skills/afx-check
```

**List installed packs and skills:**

```bash
./afx-cli --pack-list .
# Installed packs:
#   ● afx-pack-agenticflowx (ref: main)
#     afx-next
#     afx-work
#     ...
```

---

## The .afx.yaml Config

All installed packs and skills are tracked in `.afx.yaml` at your project root.

```yaml
# .afx.yaml
version: main

agents:
  claude: true
  agents: true
  gemini: false

packs:
  - name: afx-pack-agenticflowx
    installed_ref: main
    installed_at: 2025-10-24T14:00:00Z
  - name: afx-pack-qa
    installed_ref: main
    installed_at: 2025-10-24T14:05:00Z

skills:
  - name: afx-clean-code
    source: afx-pack-dev        # which pack installed this skill
    category: dev
    providers: { agents: true, copilot: false }
  - name: afx-tdd
    source: afx-pack-dev
    category: dev
    providers: { agents: true, copilot: false }
```

The `source` field links each skill back to its pack — used by `--pack-remove` to cleanly uninstall only that pack's skills.

---

## The agentskills.io Standard

AFX skills follow the **agentskills.io** open format — an Anthropic-maintained standard adopted by 26+ platforms (Claude Code, Codex, GitHub Copilot, Cursor, Gemini CLI, Roo Code, Antigravity, and more).

Core idea: *"Write once, use everywhere."* A skill is a folder with a `SKILL.md` file. No build step, no runtime.

### SKILL.md Format

```yaml
---
name: afx-clean-code         # Required. Lowercase + hyphens. Must match folder name.
description: >               # Required. Describes WHAT it does AND WHEN to activate.
  Review code for Clean Code principles — naming conventions, function design,
  error handling, and code smells. Use this when asked to review for readability,
  reduce complexity, or identify code smells.
license: MIT                 # Recommended
metadata:                    # Optional key-value pairs (AFX uses afx-* prefix)
  afx-owner: "@rix"
  afx-status: Living
---

# Instructions (full Markdown body)
...
```

> **Strict validation**: Unknown frontmatter fields are rejected by standard tooling. AFX stores its own metadata in the `metadata.afx-*` bag to remain compliant.

### Skill Directory Structure

```text
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── references/       # Optional: detailed docs (subcommand instructions, etc.)
├── scripts/          # Optional: executable code
└── assets/           # Optional: templates, images
```

### Progressive Disclosure (3-Tier Loading)

Agents only load what they need, protecting the context window:

| Tier  | What loads                           | When               | ~Tokens             |
| :---- | :----------------------------------- | :----------------- | :------------------ |
| **1** | Name + description only              | Session start      | ~50–100/skill       |
| **2** | Full `SKILL.md` body                 | Skill is activated | < 5,000 recommended |
| **3** | `references/`, `scripts/`, `assets/` | On-demand          | varies              |

For large AFX skills like `/afx-work` (1,100+ lines), `SKILL.md` holds a routing table and each subcommand's full instructions live in `references/`.

### Discovery Paths

| Scope         | Path                                                  |
| :------------ | :---------------------------------------------------- |
| Project-level | `.agents/skills/` (cross-client), `.<client>/skills/` |
| User-level    | `~/.agents/skills/`                                   |

AFX installs at project level — each project can have its own skill set.

---

## The Broader Skills Ecosystem

AFX packs can pull skills from anywhere. `afx-pack-qa` for example bundles from four sources at once:

- **AFX-built skills** (`rixrix/afx`) — QA methodology with `@see` tracing
- **Anthropic official skills** (`anthropics/skills`) — `webapp-testing` via Playwright
- **Claude Code plugins** (`anthropics/claude-code`) — `code-review`, `pr-review-toolkit`
- **OpenAI Codex skills** (`openai/skills`) — `playwright`

The broader ecosystem (as of early 2026):

| Source                                    |                    Count | Notable Skills                            |
| :---------------------------------------- | -----------------------: | :---------------------------------------- |
| OpenAI Codex (`openai/skills`)            |                       34 | Playwright, security threat-model, CI fix |
| Claude Code (`anthropics/skills`)         |                       16 | Document tools, webapp-testing, design    |
| Claude Code Plugins (official)            | 29 internal + 13 partner | code-review, security-guidance, LSP tools |
| GitHub Copilot (`github/awesome-copilot`) | 170+ agents, 185+ skills | Architecture, TDD, ADR generation         |
| SkillsMP (aggregator)                     |         270,000+ indexed | Community, all platforms                  |
| Smithery.ai (aggregator)                  |           100,000+ tools | MCP + skills                              |

---

## What Makes AFX Skills Different

The 270K+ skills in the ecosystem are general-purpose. AFX skills understand your project's spec structure and enforce traceability:

| Capability                             | Generic Ecosystem | AFX Skills                                               |
| :------------------------------------- | :---------------- | :------------------------------------------------------- |
| `@see` traceability enforcement        | None              | Core requirement of all `/afx-dev` tasks                 |
| Reads your `spec.md` / `tasks.md`      | No                | Yes — `/afx-work`, `/afx-next` read active feature state |
| Two-stage (Agent + Human) verification | No                | Yes — `/afx-check` enforces this gate                    |
| Session capture across agents          | No                | Yes — `/afx-session` writes to `journal.md`              |
| Path verification (UI to DB)           | No                | Yes — `/afx-check path` traces the entire call stack     |
| Standard-compliant SKILL.md format     | Varies            | Yes — `metadata.afx-*` bag preserves compliance          |
