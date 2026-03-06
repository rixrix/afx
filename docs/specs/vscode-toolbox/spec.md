---
afx: true
type: SPEC
status: Living
owner: "@rix"
priority: High
version: 2.0
created: "2026-02-28"
last_verified: "2026-03-01"
tags: [vscode-extension, packs, skills, toolbox]
---

# VSCode AFX Toolbox - Product Specification

**Version:** 2.0
**Date:** 2026-03-01
**Status:** Living
**Author:** Richard Sentino

## References

- **Research**: [res-vscode-pack-management.md](../../research/res-vscode-pack-management.md) — Pack management UI, sidebar restructure, upstream awareness
- **Research**: [res-skills-ecosystem-index.md](../../research/res-skills-ecosystem-index.md) — Pack system design, provider conventions, ecosystem inventory (Section 8 is source of truth)
- **ADR**: [ADR-0003](../../adr/ADR-0003-skill-management-architecture.md) — V1 rename toggle (superseded by pack system)
- **Spec**: [afx-packs/spec.md](../afx-packs/spec.md) — Pack system infrastructure this spec depends on (install.sh, manifests, index, .afx/ structure)
- **Spec**: [vscode-extension/spec.md](../vscode-extension/spec.md) — Current vscode-afx V1 sidebar tree view

---

## Problem Statement

No AI coding assistant has a good UI for managing skills and plugins across platforms. The current vscode-afx sidebar has a **Skills** view that is just a flat list of installed AFX commands per agent — a file browser with no management capabilities.

The ecosystem has grown significantly — Anthropic's official plugin directory has 8.5K+ stars, community tools offer 270+ plugins and 1,500+ skills, and VS Code Agent Skills shipped as GA in Feb 2026. Yet no tool provides a unified VS Code GUI that:

- Manages skills/plugins across Claude Code, Codex, AND Copilot
- Supports curated packs (not just individual skills)
- Has enable/disable toggle for token control
- Keeps external skills pristine while adding guardrails via AFX-built skills
- Delegates all file operations to a CLI driver (`install.sh`)
- Shows upstream availability and update status

This is an ecosystem-wide gap, not just an AFX gap.

---

## User Stories

### Primary Users

Developers using AFX with one or more AI coding assistants (Claude Code, Codex CLI, GitHub Copilot).

### Stories

**As a** developer
**I want** to see all installed packs with their status, provider coverage, and update availability
**So that** I know what's active in my project and what's out of date

**As a** developer
**I want** to browse available packs from the AFX index and install them with one click
**So that** I can add curated skill sets without leaving VSCode

**As a** developer
**I want** to enable/disable packs and individual skills via hover actions
**So that** I can control token consumption without removing packs entirely

**As a** developer
**I want** to see what's new from upstream providers (Claude plugins, Codex skills, Copilot agents)
**So that** I can discover relevant skills as the ecosystem grows

**As a** developer
**I want** the Skills section to mirror provider directories on disk
**So that** I can see exactly what each agent has access to and open any file with one click

**As a** team lead
**I want** shared packs committed via `.afx.yaml`
**So that** the team has a consistent baseline

---

## Requirements

### Functional Requirements

| ID    | Requirement                                                                                                                          | Priority    |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| FR-1  | Rename the current **Skills** view to **Toolbox** in the vscode-afx sidebar                                                          | Must Have   |
| FR-2  | Show an **Overview** section with: active providers, installed packs, total skills, last checked timestamp                           | Must Have   |
| FR-3  | Show a **Packs** section with Installed and Available subsections                                                                    | Must Have   |
| FR-4  | Installed packs show: status (enabled/disabled), provider count, item count, installed ref                                           | Must Have   |
| FR-5  | Installed packs expand to show provider subdirectories and individual skill/plugin items                                             | Must Have   |
| FR-6  | Available packs (from index) show description with an **Install** action                                                             | Must Have   |
| FR-7  | Hover actions on installed packs: **Enable/Disable**, **Remove**                                                                     | Must Have   |
| FR-8  | Hover actions on packs with updates: **Update**                                                                                      | Must Have   |
| FR-9  | Hover action on individual skill/plugin items: **Disable** (if enabled)                                                              | Must Have   |
| FR-10 | All install/remove/enable/disable/update actions delegate to `install.sh` — the extension never writes files                         | Must Have   |
| FR-11 | Show an **Upstream** section listing tracked providers with "new since last check" items                                             | Must Have   |
| FR-12 | Upstream providers show last fetched timestamp and featured/new items from index diff                                                | Must Have   |
| FR-13 | Show a **Skills** section that mirrors provider directories on disk (`.claude/`, `.codex/`, `.agents/`, `.agent/`, `.github/`, etc.) | Must Have   |
| FR-14 | Skills section items open the file in VSCode editor on click                                                                         | Must Have   |
| FR-15 | Fetch the AFX pack index from `raw.githubusercontent.com` via Node.js `fetch()`                                                      | Must Have   |
| FR-16 | Cache fetched index at `.afx/.cache/lastIndex.json` with timestamp                                                                   | Must Have   |
| FR-17 | Diff cached `lastIndex.json` vs freshly fetched index to compute "new since last check"                                              | Must Have   |
| FR-18 | Provide a **Check** button in Overview to trigger on-demand index fetch                                                              | Must Have   |
| FR-19 | Provide a **Refresh** button in Upstream section to re-fetch index                                                                   | Must Have   |
| FR-20 | Read pack state from `.afx.yaml`                                                                                                     | Must Have   |
| FR-21 | Read installed pack contents from `.afx/packs/{pack}/{provider}/` directory structure                                                | Must Have   |
| FR-22 | Support `install.sh --dry-run` for previewing changes before install                                                                 | Should Have |
| FR-23 | Auto-check index on extension activation (configurable setting)                                                                      | Should Have |
| FR-24 | Show **Setup AFX** button when `install.sh` is not available, bootstrapping via curl                                                 | Should Have |

### Non-Functional Requirements

| ID    | Requirement                                                                   | Target                                          |
| ----- | ----------------------------------------------------------------------------- | ----------------------------------------------- |
| NFR-1 | Only activates in projects with `.afx.yaml`                                   | Same activation as existing vscode-afx          |
| NFR-2 | Works fully offline with cached `lastIndex.json`                              | Upstream shows "offline — last checked: {date}" |
| NFR-3 | Index fetch requires no authentication                                        | `raw.githubusercontent.com` serves public repos |
| NFR-4 | Tree renders in < 500ms for a project with ≤ 10 installed packs               | Consistent with existing vscode-afx performance |
| NFR-5 | Extension never writes files directly — all mutations go through `install.sh` | Single driver principle                         |
| NFR-6 | Disabled packs show collapsed in the tree with distinct visual treatment      | User can tell enabled from disabled at a glance |

---

## Acceptance Criteria

### Sidebar Restructure

- [ ] Current **Skills** view renamed to **Toolbox**
- [ ] Other 4 views (Project, Specs, Library, Help) remain unchanged
- [ ] Toolbox appears in the same position as the current Skills view

### Overview Section

- [ ] Shows active provider count (e.g., "Providers: 4 active")
- [ ] Shows installed pack count with enabled/disabled breakdown
- [ ] Shows total skill count with source breakdown (core, pack, custom, disabled) — "custom" = `custom_skills` from `.afx.yaml`
- [ ] Shows last checked timestamp with a **Check** button
- [ ] Shows update/new availability badges (e.g., "1 pack update · 3 new skills available")

### Packs — Installed

- [ ] Lists all packs from `.afx.yaml`
- [ ] Each pack shows: name, status (enabled/disabled), provider count, item count, installed ref
- [ ] Enabled packs expand to show provider → item hierarchy
- [ ] Disabled packs show collapsed with visual indicator
- [ ] Items within a pack show type: external (pristine) or afx-built
- [ ] Hover on enabled pack shows **Disable** and **Remove** buttons
- [ ] Hover on disabled pack shows **Enable** and **Remove** buttons
- [ ] Packs with available updates show **Update** button

### Packs — Available

- [ ] Lists packs from index that are not installed locally
- [ ] Each shows name, description, and **Install** button on hover
- [ ] Clicking an available pack expands to show description details

### Upstream

- [ ] Lists tracked upstream providers from index (e.g., anthropics/claude-plugins-official, openai/skills)
- [ ] Each provider shows last fetched timestamp
- [ ] Shows "new since last check" items computed from index diff
- [ ] **Refresh** button triggers re-fetch
- [ ] Clicking an upstream skill opens the provider page in browser
- [ ] Works offline — shows cached data with "offline" indicator

### Skills (Disk Mirror)

- [ ] Shows provider directories as-is from disk: `.claude/`, `.codex/`, `.agents/`, `.agent/`, `.gemini/`, `.github/`
- [ ] Mirrors actual folder structure — no grouping, no attribution
- [ ] Click any item to open file in VSCode editor
- [ ] Reflects live disk state (auto-refresh on file changes)

### CLI Delegation

- [ ] Install action calls `install.sh --pack {name} .`
- [ ] Remove action calls `install.sh --pack-remove {name} .`
- [ ] Disable pack calls `install.sh --pack-disable {name} .`
- [ ] Enable pack calls `install.sh --pack-enable {name} .`
- [ ] Disable skill calls `install.sh --skill-disable {name} --pack {pack} .`
- [ ] Enable skill calls `install.sh --skill-enable {name} --pack {pack} .`
- [ ] Update calls `install.sh --update --packs .`
- [ ] Dry run calls `install.sh --dry-run --pack {name} .`
- [ ] Extension shows terminal output or notification on action completion

---

## Constraints (Resolved in Research)

These constraints are settled — they are not open for re-discussion.

| Constraint                                | Detail                                                                             |
| ----------------------------------------- | ---------------------------------------------------------------------------------- |
| `install.sh` is the single driver         | vscode-afx calls it — never writes files directly                                  |
| `.afx/packs/{pack}/{provider}/` is master | External skills pristine, AFX-built skills have guardrails baked in                |
| Provider dirs are derived copies          | `.claude/`, `.agents/`, `.agent/`, `.github/` populated from `.afx/` master        |
| Disable = delete provider copies          | Master stays in `.afx/`. Re-enable = `cp -r` from master                           |
| Remove = delete everything                | Both provider copies and `.afx/packs/{pack}/`                                      |
| `.afx.yaml` tracks state                  | Pack list with status + per-item overrides                                         |
| Pack prefix `afx-pack-*`                  | Avoids conflict with AFX core commands                                             |
| External skills are never modified        | Downloaded pristine, stored pristine, copied pristine                              |
| AFX-built skills have guardrails          | Authored by AFX team, not auto-generated or templated                              |
| No authentication required                | `raw.githubusercontent.com` for public repos                                       |
| Best-effort cross-platform parity         | Each pack declares `platforms:` support, no forced parity                          |
| Use latest (`ref: main`) by default       | Extension defaults to `main`; install.sh supports `--branch`/`--version` overrides |

---

## Non-Goals (Out of Scope)

- Custom editors or forms — actions are hover buttons, not dialogs
- Creating or authoring new skills/packs from within the Toolbox
- Crawling upstream repositories at runtime — all data comes from the pre-built index
- Supporting private/authenticated pack registries
- Cross-workspace pack state synchronization
- WebView dashboards or rich visualizations
- Modifying or adapting external skills for cross-provider compatibility
- Building an install.sh replacement — the extension delegates, it doesn't replicate

---

## Open Questions

| #   | Question                                                       | Status   | Resolution                                                                                                                                                                  |
| --- | -------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Index fetch: live from GitHub or bundled?                      | Resolved | Live fetch from `raw.githubusercontent.com`, cached in `.afx/.cache/`                                                                                                       |
| 2   | How to handle `install.sh` not being available?                | Resolved | Toolbox shows "Setup AFX" button to bootstrap via curl (similar to `afx:init`)                                                                                              |
| 3   | Tree structure — mirror `.afx/` directory exactly or abstract? | Resolved | Packs section mirrors `.afx/` structure; Skills section mirrors provider dirs on disk                                                                                       |
| 4   | Where does this pane live?                                     | Resolved | Replaces current Skills view, renamed to **Toolbox**                                                                                                                        |
| 5   | Pane name?                                                     | Resolved | **Toolbox**                                                                                                                                                                 |
| 6   | How to show upstream updates?                                  | Resolved | Index diff between cached and fetched versions                                                                                                                              |
| 7   | How to detect pack updates available?                          | Open     | Index has no `latest_ref` — extension can't compare `installed_ref` vs latest. Options: always show Update button, add `latest_ref` to index, or query GitHub releases API. |

---

## Dependencies

- **vscode-afx extension** — This spec extends the existing extension (separate repo: `vscode-afx`)
- **install.sh** — Must support all pack management CLI commands (install, remove, enable, disable, update, dry-run, skill-disable, skill-enable)
- **packs/index.json** — Must be published in the AFX repo and maintained alongside pack manifests
- **Pack manifests** — At least one pack (e.g., `afx-pack-qa`) must exist for testing

---

## Appendix

### Toolbox Layout (ASCII Mock)

```
🔧 Toolbox
│
├── Overview
│   ├── Providers: 4 active
│   ├── Packs: 2 installed (1 enabled, 1 disabled)
│   ├── Skills: 34 total (13 core · 8 pack · 3 custom · 10 disabled)
│   ├── Last checked: 2h ago                            [↻ Check]
│   └── ⬆ 1 pack update · 3 new skills available
│
├── Packs                                               [+ Install]
│   │
│   ├── Installed
│   │   ├── afx-pack-qa (enabled)       3 providers · 12 items · v1.5.3
│   │   │   ├── claude/
│   │   │   │   ├── skills/
│   │   │   │   │   ├── test-driven-development  ✓ (external)
│   │   │   │   │   └── afx-qa-methodology       ✓ (afx-built)
│   │   │   │   └── plugins/
│   │   │   │       └── code-review              ✓ (external)
│   │   │   ├── codex/
│   │   │   │   └── skills/
│   │   │   │       └── playwright               ✓ (external)
│   │   │   └── copilot/
│   │   │       └── agents/
│   │   │           └── afx-qa-methodology       ✓ (afx-built)
│   │   │
│   │   └── afx-pack-security (disabled) 3 providers · 12 items
│   │       └── ▸ (collapsed — disabled)
│   │
│   └── Available                                        ← from index
│       ├── afx-pack-devops    — DevOps Automation       [Install]
│       ├── afx-pack-architect — System Design           [Install]
│       └── afx-pack-frontend  — Frontend Patterns       [Install]
│
├── Upstream                                             [↻ Refresh]
│   ├── Claude Plugins (anthropics/claude-plugins-official)
│   │   ├── Last fetched: 1d ago
│   │   ├── New since last check:
│   │   │   ├── playwright-e2e (v1.2.0)
│   │   │   └── security-scanner (v2.0.0)
│   │   └── ▸ Browse full directory...
│   │
│   ├── Codex Skills (openai/skills)
│   │   ├── Last fetched: 3d ago
│   │   └── New since last check: none
│   │
│   └── Antigravity (anthropics/antigravity-awesome-skills)
│       ├── Last fetched: 1d ago
│       └── New since last check:
│           └── code-architect (v1.0.0)
│
└── Skills                                               ← disk mirror
    ├── .claude/
    │   ├── commands/
    │   │   ├── afx-next.md
    │   │   ├── afx-work.md
    │   │   └── ...
    │   ├── skills/
    │   │   ├── test-driven-development/
    │   │   └── afx-qa-methodology/
    │   └── plugins/
    │       └── code-review/
    ├── .codex/
    │   └── skills/
    │       └── afx-next/                              ← core AFX
    ├── .agents/
    │   └── skills/
    │       ├── test-driven-development/               ← from pack
    │       ├── playwright/                            ← from pack
    │       └── afx-qa-methodology/                    ← from pack
    ├── .agent/
    │   └── skills/
    │       ├── test-driven-development/               ← from pack
    │       └── afx-qa-methodology/                    ← from pack
    ├── .gemini/
    │   └── commands/
    │       └── ...
    └── .github/
        ├── prompts/
        │   └── ...
        └── agents/                                    ← from pack
            ├── afx-qa-methodology.agent.md
            └── afx-spec-test-planning.agent.md
```

### Interaction Map

| Element                    | Hover Action                       | Click Action                    |
| -------------------------- | ---------------------------------- | ------------------------------- |
| Pack (installed, enabled)  | Show `Disable` `Remove` buttons    | Expand/collapse                 |
| Pack (installed, disabled) | Show `Enable` `Remove` buttons     | Expand/collapse                 |
| Pack (installed)           | Right-click: `Preview Changes`     | —                               |
| Pack (available)           | Show `Install` button              | Expand to show description      |
| Pack with update           | Show `Update` button               | Expand pack details             |
| Skill/plugin item          | Show `Disable` button (if enabled) | Open file                       |
| Upstream provider          | Show `Refresh` button              | Expand to show new items        |
| Upstream skill             | —                                  | Open in browser (provider page) |
| Skills disk entry          | —                                  | Open file in editor             |

### Index Schema (`packs/index.json`)

```jsonc
{
  "packs": {
    "afx-pack-qa": {
      "description": "QA Engineer role pack",
      "category": "role",
      "providers": ["claude", "codex", "antigravity", "copilot"],
    },
    "afx-pack-security": {
      "description": "Security review and audit pack",
      "category": "role",
      "providers": ["claude", "codex", "antigravity", "copilot"],
    },
  },
  "upstream": {
    "anthropics/claude-plugins-official": {
      "featured": ["playwright-e2e", "security-scanner", "code-architect"],
    },
    "openai/skills": {},
    "anthropics/antigravity-awesome-skills": {
      "featured": ["code-architect"],
    },
  },
}
```

### Data Sources Summary

| Source                          | Type   | What it provides                                                              |
| ------------------------------- | ------ | ----------------------------------------------------------------------------- |
| `.afx.yaml`                     | Local  | Installed packs, status, installed_ref, per-item disabled list, custom_skills |
| `.afx/packs/{pack}/{provider}/` | Local  | Actual items on disk — grouped by provider                                    |
| `.afx/.cache/lastIndex.json`    | Local  | Cached last fetched index + timestamp for diff                                |
| `packs/index.json` (remote)     | Remote | Pack metadata, upstream featured items (no auth required)                     |

### Glossary

| Term            | Definition                                                                                                                                                                 |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Pack            | A curated bundle of skills/plugins grouped by role or domain (e.g., `afx-pack-qa`)                                                                                         |
| Skill           | A SKILL.md-based capability file auto-discovered by Claude Code or Codex CLI                                                                                               |
| Plugin          | A Claude Code plugin with `.claude-plugin/plugin.json` manifest, commands, agents, hooks                                                                                   |
| Provider        | An AI coding assistant platform: Claude Code, Codex CLI, Google Antigravity, GitHub Copilot, Gemini CLI (packs support first four only; Gemini has core AFX commands only) |
| Master copy     | The pristine downloaded content stored in `.afx/packs/{pack}/{provider}/`                                                                                                  |
| Provider copy   | The derived copy placed in `.claude/`, `.agents/`, `.agent/`, `.github/` for auto-discovery                                                                                |
| External skill  | A skill downloaded from an upstream repo — never modified by AFX                                                                                                           |
| AFX-built skill | A skill authored by the AFX team with guardrails baked in                                                                                                                  |
| Upstream        | External provider repositories tracked for new skill availability                                                                                                          |
| Index           | `packs/index.json` — the single aggregated metadata file fetched by the extension                                                                                          |
| Guardrails      | AFX methodology rules (e.g., @see tracing, two-stage verify) baked into AFX-built skills                                                                                   |
