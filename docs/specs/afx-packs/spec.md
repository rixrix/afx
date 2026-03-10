---
<!-- APPROVED: 2026-02-28 - Do not edit without version bump -->
afx: true
type: SPEC
status: Approved
owner: "@rix"
priority: High
version: 1.0
approved_at: "2026-02-28T04:35:00.000Z"
created: "2026-02-28T00:00:00.000Z"
last_verified: "2026-02-28T00:00:00.000Z"
tags: [packs, install, skills, ecosystem]

---

# AFX Pack System - Product Specification

## References

- **Research**: [res-skills-ecosystem-index.md](../../research/res-skills-ecosystem-index.md) — Pack system design, provider conventions, ecosystem inventory (Section 8 is source of truth)
- **Research**: [res-vscode-pack-management.md](../../research/res-vscode-pack-management.md) — Pack management UI, index strategy
- **ADR**: [ADR-0003](../../adr/ADR-0003-skill-management-architecture.md) — V1 rename toggle (superseded by pack system)
- **Counterpart**: [vscode-toolbox/spec.md](../vscode-toolbox/spec.md) — VSCode extension UI that consumes this infrastructure

---

## Problem Statement

AFX currently installs only core commands (slash commands, Codex skills, Copilot prompts) via `install.sh`. There is no way to install curated bundles of third-party skills, no pack management CLI, no index file for discovery, and no directory structure for managing skill state across providers.

The ecosystem has ~1,100 unique skills across Antigravity, OpenAI, Claude Plugins, and Agentic-Flow. AFX's value is in **composing** these — curating packs by role/domain, adding guardrails via AFX-built skills, and managing the lifecycle (install, enable, disable, remove, update) across Claude Code, Codex CLI, and GitHub Copilot.

This spec covers what needs to be built **in the AFX repo itself**: pack manifests, `install.sh` pack management commands, `packs/index.json`, AFX-built skills, `.afx/` directory structure, and `.afx.yaml` pack state tracking.

---

## User Stories

### Primary Users

Developers using AFX who want to extend their AI coding assistants with curated skill packs.

### Stories

**As a** developer
**I want** to install a curated skill pack with a single command (`install.sh --pack qa .`)
**So that** I get a vetted set of skills across all my AI assistants without picking them one by one

**As a** developer
**I want** to disable a pack without deleting it
**So that** I can reduce token consumption and re-enable it later without re-downloading

**As a** developer
**I want** to disable individual skills within an enabled pack
**So that** I have fine-grained control over which skills are active

**As a** developer
**I want** to update all installed packs to their latest versions
**So that** I get new skills and fixes without manual tracking

**As a** developer
**I want** to preview what a pack install will do before committing
**So that** I can review the changes and avoid surprises

**As a** team lead
**I want** to commit `.afx.yaml` with our team's packs so all developers get the same skill baseline
**So that** the team has consistent AI assistant capabilities

---

## Requirements

### Functional Requirements

#### Pack Manifests (`packs/`)

| ID   | Requirement                                                                                               | Priority  |
| ---- | --------------------------------------------------------------------------------------------------------- | --------- |
| FR-1 | Create `packs/` directory in AFX repo to hold pack manifest files                                         | Must Have |
| FR-2 | Each pack manifest is a YAML file: `packs/afx-pack-{name}.yaml`                                           | Must Have |
| FR-3 | Manifest schema: `name`, `description`, `category`, `platforms`, `includes[]`                             | Must Have |
| FR-4 | Each `includes` entry specifies: `repo`, `path`, `items[]` (repo URLs inline, no registry indirection)    | Must Have |
| FR-5 | `platforms` field declares provider support: `claude`, `codex`, `antigravity`, `copilot` (best-effort, no forced parity) | Must Have |
| FR-7 | Create at least one pack manifest (`afx-pack-qa`) as reference implementation                             | Must Have |

#### Pack Index (`packs/index.json`)

| ID    | Requirement                                                                                | Priority  |
| ----- | ------------------------------------------------------------------------------------------ | --------- |
| FR-8  | Create `packs/index.json` — single aggregated metadata file for all packs and upstream     | Must Have |
| FR-9  | Index schema for packs: `description`, `category`, `providers[]`                           | Must Have |
| FR-10 | Index schema for upstream: provider repos with `featured[]` item lists                     | Must Have |
| FR-11 | Index served via `raw.githubusercontent.com` — no auth, no API key                         | Must Have |
| FR-12 | Index maintained manually alongside pack manifests (updated when packs or upstream change) | Must Have |

#### `install.sh` Pack Management

| ID     | Requirement                                                                                                             | Priority    |
| ------ | ----------------------------------------------------------------------------------------------------------------------- | ----------- |
| FR-13  | `--pack {name}` — install and enable a pack (download items, detect types, store in `.afx/`, copy to providers)         | Must Have   |
| FR-14  | `--pack {a} --pack {b}` — install multiple packs in one command                                                         | Must Have   |
| FR-15  | `--pack-disable {name}` — delete provider copies, keep master in `.afx/`, update `.afx.yaml` status                     | Must Have   |
| FR-16  | `--pack-enable {name}` — `cp -r` from `.afx/` master to provider dirs, update `.afx.yaml` status                        | Must Have   |
| FR-17  | `--pack-remove {name}` — delete both provider copies and `.afx/packs/{pack}/`, remove from `.afx.yaml`                  | Must Have   |
| FR-18  | `--pack-list` — list installed packs with status (enabled/disabled)                                                     | Must Have   |
| FR-19  | `--skill-disable {name} --pack {pack}` — disable single skill within an enabled pack                                    | Must Have   |
| FR-20  | `--skill-enable {name} --pack {pack}` — re-enable a disabled skill within a pack                                        | Must Have   |
| FR-21  | `--update --packs` — fetch latest manifests and update all enabled packs                                                | Must Have   |
| FR-22  | `--dry-run --pack {name}` — preview changes without applying                                                            | Must Have   |
| FR-23  | `--add-skill {repo}:{path}/{skill}` — one-off skill install from any repo (no pack)                                     | Should Have |
| FR-24a | `--branch {name}` — override the default branch (`main`) when downloading AFX packs and index                           | Must Have   |
| FR-24b | `--version {tag}` — install from a specific version tag (e.g., `v1.5.3` or `1.5.3`); mutually exclusive with `--branch` | Must Have   |

#### Skill Type Detection

| ID    | Requirement                                                                                        | Priority  |
| ----- | -------------------------------------------------------------------------------------------------- | --------- |
| FR-34 | Detect **Simple Skill**: `SKILL.md` at root, no `.claude-plugin/` → compatible with Claude + Codex + Antigravity | Must Have |
| FR-25 | Detect **Claude Plugin**: `.claude-plugin/plugin.json` exists → Claude only                        | Must Have |
| FR-26 | Detect **OpenAI Skill**: `SKILL.md` + `agents/openai.yaml` → Codex only                            | Must Have |
| FR-27 | External skills are never modified — downloaded pristine, stored pristine, copied pristine         | Must Have |

#### `.afx/` Directory Structure

| ID    | Requirement                                                                                                                         | Priority  |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------- | --------- |
| FR-28 | Store master copies at `.afx/packs/{pack-name}/{provider}/` grouped by provider                                                     | Must Have |
| FR-29 | Provider subdirectories follow each platform's conventions: `claude/skills/`, `claude/plugins/`, `codex/skills/`, `antigravity/skills/`, `copilot/agents/` | Must Have |
| FR-30 | External skills stored pristine in master; AFX-built guardrails skills sit alongside them                                           | Must Have |
| FR-31 | Create `.afx/.cache/` directory for cached index data                                                                               | Must Have |

#### `.afx.yaml` Pack State

| ID    | Requirement                                                                                       | Priority  |
| ----- | ------------------------------------------------------------------------------------------------- | --------- |
| FR-32 | Add `packs:` section to `.afx.yaml` with: `name`, `status` (enabled/disabled), `installed_ref`, `disabled_items[]` | Must Have |
| FR-33 | `.afx.yaml` is committed (team-shared) and includes `custom_skills:` list for one-off installs    | Must Have |

#### AFX-Built Skills (`skills/`)

| ID    | Requirement                                                                                  | Priority  |
| ----- | -------------------------------------------------------------------------------------------- | --------- |
| FR-35 | Create `skills/` directory in AFX repo for AFX-authored skills with guardrails baked in      | Must Have |
| FR-36 | AFX-built skills use provider-native formats: `SKILL.md` for Claude/Codex/Antigravity, `.agent.md` for Copilot | Must Have |
| FR-37 | Pack manifests reference AFX-built skills via `repo: rixrix/afx`, `path: skills/`            | Must Have |
| FR-38 | Create guardrails skills for the first pack (`afx-qa-methodology`, `afx-spec-test-planning`) | Must Have |

#### Provider Copy Management

| ID    | Requirement                                                                                                       | Priority  |
| ----- | ----------------------------------------------------------------------------------------------------------------- | --------- |
| FR-39 | Simple Skills (SKILL.md) copied to `.claude/skills/`, `.agents/skills/`, and `.agent/skills/`                       | Must Have |
| FR-40 | Claude Plugins copied to `.claude/plugins/` only                                                                  | Must Have |
| FR-41 | OpenAI Skills (with `openai.yaml`) copied to `.agents/skills/` only                                               | Must Have |
| FR-42 | AFX-built skills are pre-organized by provider directory (claude/, codex/, antigravity/, copilot/) in `rixrix/afx` repo (no routing logic needed — just copy) | Must Have |
| FR-43 | Copilot receives only AFX-built skills (no conversion of external SKILL.md to `.agent.md`)                        | Must Have |
| FR-44 | Detect name collisions in provider directories; fail install/enable if a different pack owns the destination      | Must Have |
| FR-45 | Manifest `platforms:` field gates routing — skills are only copied to providers marked `true` or `partial`        | Must Have |

### Non-Functional Requirements

| ID    | Requirement                                                                               | Target                                                     |
| ----- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| NFR-1 | Default `install.sh` (without `--pack`) continues to work unchanged                       | Zero breaking changes to existing installations            |
| NFR-2 | Pack install downloads via `codeload.github.com` tarballs and extracts specific paths     | No git dependency, no full repo clones                     |
| NFR-3 | Enable/disable is instant — `cp -r` / `rm -r` with no network or conversion               | Sub-second for packs with ≤ 20 items                       |
| NFR-4 | Pack prefix `afx-pack-*` to avoid naming conflicts with AFX core commands                 | Convention enforced in manifest naming                     |
| NFR-5 | `install.sh` requires only `curl`, `tar`, and `bash` (≥ 4.0) — no git, no node, no python | macOS, Linux, WSL (Windows Subsystem for Linux)            |
| NFR-6 | All pack operations are idempotent                                                        | Running the same command twice produces the same result    |
| NFR-7 | `.afx/` directory is gitignored by default (added to `.gitignore` on first pack install)  | Downloaded skills should not be committed to user projects |

---

## Acceptance Criteria

### Pack Manifests

- [ ] `packs/` directory exists in AFX repo
- [ ] `packs/afx-pack-qa.yaml` exists with valid schema (name, description, category, platforms, includes)
- [ ] Manifest includes entries specify `repo`, `path`, `items[]` with no registry indirection
- [ ] `platforms` field accurately reflects provider support per pack

### Pack Index

- [ ] `packs/index.json` exists with packs and upstream sections
- [ ] Each pack entry has: description, category, providers
- [ ] Upstream section lists tracked repos with featured items
- [ ] Index is fetchable via `raw.githubusercontent.com` without authentication

### install.sh — Pack Install

- [ ] `./install.sh --pack qa .` downloads items from manifested repos
- [ ] Downloaded items stored pristine in `.afx/packs/afx-pack-qa/{provider}/`
- [ ] Type detection correctly routes: Simple Skill → Claude + Codex + Antigravity, Claude Plugin → Claude only, OpenAI Skill → Codex only
- [ ] Provider copies placed in correct directories (`.claude/skills/`, `.claude/plugins/`, `.agents/skills/`, `.agent/skills/`, `.github/agents/`)
- [ ] AFX-built skills authored per provider directory (claude/, codex/, antigravity/, copilot/)
- [ ] Pack recorded in `.afx.yaml` with `status: enabled` and `installed_ref` (resolved from `--version`, `--branch`, or default `main`)
- [ ] `.afx/` added to `.gitignore` if not already present
- [ ] `--pack qa --pack security` installs both packs
- [ ] `--branch dev --pack qa .` fetches pack manifest and items from the `dev` branch instead of `main`
- [ ] `--version 1.5.3 --pack qa .` fetches from version tag `v1.5.3` (auto-prefixes `v`)
- [ ] `--version` and `--branch` are mutually exclusive — error if both provided

### install.sh — Pack Lifecycle

- [ ] `--pack-disable qa` removes provider copies, master in `.afx/` stays, `.afx.yaml` updated to `status: disabled`
- [ ] `--pack-enable qa` copies from `.afx/` master to provider dirs, `.afx.yaml` updated to `status: enabled`
- [ ] `--pack-remove qa` deletes both `.afx/packs/afx-pack-qa/` and provider copies, removes from `.afx.yaml`
- [ ] `--pack-list` outputs installed packs with their status
- [ ] `--skill-disable tdd --pack qa` removes that skill from provider dirs, adds to `disabled_items`
- [ ] `--skill-enable tdd --pack qa` restores from master (checking collisions), removes from `disabled_items`
- [ ] `--update --packs` re-downloads and replaces items for all enabled packs
- [ ] `--dry-run --pack qa` shows what would be changed without writing any files

### install.sh — Backward Compatibility

- [ ] `./install.sh .` (no pack flags) works exactly as before — installs core AFX commands only
- [ ] `./install.sh --update .` works exactly as before
- [ ] All existing flags (`--commands-only`, `--no-claude-md`, `--force`, etc.) continue to work

### .afx.yaml State

- [ ] `packs:` section added to `.afx.yaml` on first pack install
- [ ] `custom_skills:` section added for one-off installs
- [ ] Each pack entry has: `name`, `status`, `installed_ref`, `disabled_items`

### AFX-Built Skills

- [ ] `skills/` directory exists in AFX repo
- [ ] At least two AFX-built skills exist: `afx-qa-methodology`, `afx-spec-test-planning`
- [ ] Each has valid SKILL.md with guardrails (e.g., @see tracing, two-stage verify references)
- [ ] Referenced correctly in `afx-pack-qa.yaml` manifest

### Provider Copy Routing

- [ ] Simple Skill (SKILL.md only) → `.claude/skills/` AND `.agents/skills/` AND `.agent/skills/`
- [ ] Claude Plugin (`.claude-plugin/`) → `.claude/plugins/` only
- [ ] OpenAI Skill (SKILL.md + `openai.yaml`) → `.agents/skills/` only
- [ ] AFX-built → pre-organized by provider dir, just `cp -r` each subdir into pack master
- [ ] No external skill is ever modified during any operation
- [ ] Platform gating: skills only routed to providers marked `true` or `partial` in manifest `platforms:`
- [ ] Name collision: installing a skill that exists in another pack fails with error (unless `--force`)

### One-Off Skill Install

- [ ] `--add-skill anthropics/antigravity-awesome-skills:skills/some-skill .` downloads and installs a single skill
- [ ] Skill type-detected and routed to provider dirs (no `.afx/packs/` master — direct to provider dirs)
- [ ] Tracked in `.afx.yaml` under `custom_skills:` with `repo` and `path`
- [ ] Custom skills are NOT updated by `--update --packs`

---

## Constraints (Resolved in Research)

These constraints are settled — they are not open for re-discussion.

| Constraint                                | Detail                                                                          |
| ----------------------------------------- | ------------------------------------------------------------------------------- |
| `install.sh` is the single driver         | All operations go through `install.sh` — no separate CLI tool                   |
| `.afx/packs/{pack}/{provider}/` is master | External skills pristine, AFX-built skills have guardrails baked in             |
| Provider dirs are derived copies          | `.claude/`, `.agents/`, `.agent/`, `.github/` populated from `.afx/` master     |
| Disable = delete provider copies          | Master stays in `.afx/`. Re-enable = `cp -r` from master                        |
| Remove = delete everything                | Both provider copies and `.afx/packs/{pack}/`                                   |
| `.afx.yaml` tracks state                  | Pack list with status + per-item overrides                                      |
| Pack prefix `afx-pack-*`                  | Avoids conflict with AFX core commands                                          |
| External skills are never modified        | Downloaded pristine, stored pristine, copied pristine                           |
| AFX-built skills have guardrails          | Authored by AFX team, not auto-generated or templated                           |
| Minimal runtime dependencies              | Only `curl`, `tar`, `bash` — no git, node, python, or package managers required |
| No authentication required                | `raw.githubusercontent.com` for public repos                                    |
| Use latest (`ref: main`) by default       | `--branch` or `--version` overrides; `--version` auto-prefixes `v`              |
| Best-effort cross-platform parity         | Each pack declares `platforms:` support, no forced parity                       |

---

## Non-Goals (Out of Scope)

- Private or authenticated pack registries
- Auto-generated guardrails or template-based skill injection
- Converting external SKILL.md to Copilot `.agent.md` format
- Quality scoring or ranking of ecosystem skills (future task)
- GUI — pack management UI is in the [vscode-toolbox spec](../vscode-toolbox/spec.md)
- Commit SHA pinning (packs track `installed_ref` as branch/tag, not exact commit SHAs)
- Building a separate CLI tool — everything goes through `install.sh`

---

## Open Questions

| #   | Question                                                       | Status   | Resolution                                                                                       |
| --- | -------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------ |
| 1   | Download method: sparse checkout vs tarball?                   | Resolved | **Tarball**. Use `codeload.github.com` + `tar` extraction for speed and no git history overhead. |
| 2   | How to handle offline pack install (pre-downloaded)?           | Open     | —                                                                                                |
| 3   | Should `--add-skill` (one-off, no pack) track in `.afx.yaml`? | Resolved | **Yes**. Track in `custom_skills: []` list to ensure consistent baseline across team.            |
| 4   | Quality scoring for 950 Antigravity skills?                    | Deferred | Address when building first pack manifests by manually reviewing                                 |

---

## Dependencies

- **Upstream repos** — Skills must be available at the repos referenced in pack manifests (Antigravity, OpenAI, Claude Plugins)
- **`packs/index.json`** — Must be published before vscode-toolbox can consume it
- **AFX-built skills** — At least `afx-qa-methodology` and `afx-spec-test-planning` must be authored before `afx-pack-qa` is functional

---

## Appendix

### Pack Manifest Schema

```yaml
# packs/afx-pack-qa.yaml
name: afx-pack-qa
description: QA Engineer role pack — testing, review, and quality assurance
category: role

platforms:
  claude: true
  codex: true
  antigravity: true
  copilot: partial

includes:
  # External skills (pristine)
  - repo: anthropics/antigravity-awesome-skills
    path: skills/
    items:
      - test-driven-development
      - tdd-workflow
      - playwright-skill
      - e2e-testing-patterns
      - unit-testing-test-generate
      - systematic-debugging
      - performance-testing-review

  - repo: openai/skills
    path: skills/.curated/
    items:
      - playwright

  - repo: anthropics/claude-code
    path: plugins/
    items:
      - code-review
      - pr-review-toolkit

  # AFX-built skills (guardrails baked in)
  - repo: rixrix/afx
    path: skills/
    items:
      - afx-qa-methodology
      - afx-spec-test-planning
```

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

### `.afx/` Directory Structure (Master Copy)

```
.afx/
├── .cache/
│   └── lastIndex.json                                  # cached index + timestamp
│
└── packs/
    ├── afx-pack-qa/                                    # installed pack
    │   ├── claude/
    │   │   ├── skills/
    │   │   │   ├── test-driven-development/           # PRISTINE from Antigravity
    │   │   │   │   ├── SKILL.md
    │   │   │   │   └── resources/
    │   │   │   ├── tdd-workflow/                      # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── ...                                # 5 more Antigravity skills
    │   │   │   ├── afx-qa-methodology/                # AFX-BUILT
    │   │   │   │   └── SKILL.md
    │   │   │   └── afx-spec-test-planning/            # AFX-BUILT
    │   │   │       └── SKILL.md
    │   │   └── plugins/
    │   │       ├── code-review/                       # PRISTINE from Claude Code
    │   │       │   ├── .claude-plugin/plugin.json
    │   │       │   ├── commands/review.md
    │   │       │   └── hooks/hooks.json
    │   │       └── pr-review-toolkit/                 # PRISTINE from Claude Code
    │   │           └── ...
    │   ├── codex/
    │   │   └── skills/
    │   │       ├── test-driven-development/           # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── ...                                # 6 more Antigravity skills
    │   │       ├── playwright/                        # PRISTINE from OpenAI
    │   │       │   ├── SKILL.md
    │   │       │   ├── agents/openai.yaml
    │   │       │   └── scripts/run-tests.py
    │   │       ├── afx-qa-methodology/                # AFX-BUILT
    │   │       │   └── SKILL.md
    │   │       └── afx-spec-test-planning/            # AFX-BUILT
    │   │           └── SKILL.md
    │   ├── antigravity/
    │   │   └── skills/
    │   │       ├── test-driven-development/           # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── ...                                # 6 more Antigravity skills
    │   │       ├── afx-qa-methodology/                # AFX-BUILT
    │   │       │   └── SKILL.md
    │   │       └── afx-spec-test-planning/            # AFX-BUILT
    │   │           └── SKILL.md
    │   └── copilot/
    │       └── agents/
    │           ├── afx-qa-methodology.agent.md        # AFX-BUILT (only AFX skills)
    │           └── afx-spec-test-planning.agent.md    # AFX-BUILT
    │
    └── afx-pack-security/                              # disabled pack (master preserved)
        ├── claude/
        ├── codex/
        ├── antigravity/
        └── copilot/
```

### `.afx.yaml` Pack State Schema

```yaml
# .afx.yaml (committed — team-shared)
packs:
  - name: afx-pack-qa
    status: enabled
    installed_ref: v1.5.3
    disabled_items: []

  - name: afx-pack-security
    status: disabled
    installed_ref: main
    disabled_items: []

custom_skills:
  - repo: anthropics/antigravity-awesome-skills
    path: skills/some-niche-skill
```

### install.sh CLI Reference

```bash
# Core AFX install (unchanged — no packs)
./install.sh /path/to/project

# Pack management
./install.sh --pack qa /path/to/project               # install + enable
./install.sh --pack qa --pack security /path/to/project # multiple at once
./install.sh --pack-disable qa /path/to/project        # disable (rm provider copies)
./install.sh --pack-enable qa /path/to/project         # re-enable (cp -r from master)
./install.sh --pack-remove qa /path/to/project         # delete entirely
./install.sh --pack-list /path/to/project              # list packs + status

# Single skill toggle (within a pack)
./install.sh --skill-disable tdd --pack qa /path/to/project
./install.sh --skill-enable tdd --pack qa /path/to/project

# Update all enabled packs
./install.sh --update --packs /path/to/project

# Preview changes
./install.sh --dry-run --pack qa /path/to/project

# Install from a specific branch
./install.sh --branch dev --pack qa /path/to/project

# Install from a specific version
./install.sh --version 1.5.3 --pack qa /path/to/project

# One-off skill install (no pack)
./install.sh --add-skill anthropics/antigravity-awesome-skills:skills/some-skill /path/to/project
```

### Skill Type Detection Matrix

| Detection Rule                           | Type          | Target Providers              | Modification |
| ---------------------------------------- | ------------- | ----------------------------- | ------------ |
| `SKILL.md` at root, no `.claude-plugin/` | Simple Skill  | Claude + Codex + Antigravity  | None         |
| `.claude-plugin/plugin.json` exists      | Claude Plugin | Claude only                   | None         |
| `SKILL.md` + `agents/openai.yaml`        | OpenAI Skill  | Codex only                    | None         |
| From `rixrix/afx` repo                   | AFX-built     | All (pre-organized by provider dir) | N/A    |

### Glossary

| Term            | Definition                                                                                  |
| --------------- | ------------------------------------------------------------------------------------------- |
| Pack            | A curated bundle of skills/plugins grouped by role or domain (e.g., `afx-pack-qa`)          |
| Pack manifest   | YAML file in `packs/` defining a pack's contents, repo sources, and platform support        |
| Pack index      | `packs/index.json` — aggregated metadata for all packs and upstream, consumed by vscode-afx |
| Master copy     | The pristine downloaded content stored in `.afx/packs/{pack}/{provider}/`                   |
| Provider copy   | The derived copy placed in `.claude/`, `.agents/`, `.agent/`, `.github/` for auto-discovery |
| External skill  | A skill downloaded from an upstream repo — never modified by AFX                            |
| AFX-built skill | A skill authored by the AFX team with guardrails baked in                                   |
| Guardrails      | AFX methodology rules (e.g., @see tracing, two-stage verify) baked into AFX-built skills    |
| Provider        | An AI coding assistant platform: Claude Code, Codex CLI, Google Antigravity, GitHub Copilot |
