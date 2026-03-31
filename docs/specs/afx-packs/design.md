---
afx: true
type: DESIGN
status: Approved
owner: "@rix"
version: "1.0"
created_at: "2026-02-28T00:00:00.000Z"
updated_at: "2026-02-28T00:00:00.000Z"
tags: [packs, install, skills, ecosystem]
spec: spec.md
---

# AFX Pack System - Technical Design

---

## Overview

This design defines the architecture for the AFX Pack System, enabling the installation, management, and composition of skill packs across Claude Code, Codex CLI, Google Antigravity, and GitHub Copilot. It centers on `afx-cli` as the single driver for state mutations, using `.afx/` as the master storage for pristine external skills and `.afx.yaml` for project state.

### Core Principles

1. **Single Driver**: `afx-cli` handles all file operations. Extensions (VSCode) delegate to it.
2. **Pristine Storage**: External skills are downloaded once to `.afx/packs/{pack}/{provider}/` and never modified.
3. **Derived State**: Provider directories (`.claude/`, `.agents/`, `.agent/`, `.github/`) are ephemeral copies of the master state.
4. **No Registry Auth**: All metadata and public packs are fetched from public URLs (`raw.githubusercontent.com`, `codeload.github.com`).
5. **Minimal Dependencies**: Only `curl`, `tar`, and `bash` — no git, node, python, or package managers.

---

## 1. Data Models

### 1.1 Pack Manifests

Pack manifests live in the AFX repo under `packs/`. Each manifest is a self-contained YAML file defining the pack's contents, sources, and platform support.

#### `packs/afx-pack-qa.yaml`

```yaml
name: afx-pack-qa
description: QA Engineer role pack — testing, review, and quality assurance
category: role

platforms:
  claude: true
  codex: true
  antigravity: true
  copilot: partial # Only AFX-built skills — no external SKILL.md conversion

includes:
  # External skills from Antigravity (pristine — SKILL.md format → Claude + Codex + Antigravity)
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

  # External skills from OpenAI (pristine — SKILL.md + openai.yaml → Codex only)
  - repo: openai/skills
    path: skills/.curated/
    items:
      - playwright

  # Claude Code plugins (pristine — .claude-plugin/ format → Claude only)
  - repo: anthropics/claude-code
    path: plugins/
    items:
      - code-review
      - pr-review-toolkit

  # AFX-built skills (guardrails baked in, hosted in AFX repo)
  - repo: rixrix/afx
    path: skills/
    items:
      - afx-qa-methodology # QA workflow with @see tracing + two-stage verify
      - afx-spec-test-planning # Test plans linked to spec tasks
```

**What each provider gets from `afx-pack-qa`:**

| Provider        | External skills (pristine)                                        | AFX-built                                                         |
| --------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------- |
| **Claude**      | 7 Antigravity SKILL.md skills + 2 Claude plugins                  | `afx-qa-methodology` + `afx-spec-test-planning`                   |
| **Codex**       | 7 Antigravity SKILL.md skills + 1 OpenAI skill (with openai.yaml) | `afx-qa-methodology` + `afx-spec-test-planning`                   |
| **Antigravity** | 7 Antigravity SKILL.md skills                                     | `afx-qa-methodology` + `afx-spec-test-planning`                   |
| **Copilot**     | None (no conversion of external skills)                           | `afx-qa-methodology.agent.md` + `afx-spec-test-planning.agent.md` |

#### `packs/afx-pack-security.yaml`

```yaml
name: afx-pack-security
description: Security review and audit pack — OWASP, dependency scanning, code hardening
category: role

platforms:
  claude: true
  codex: true
  antigravity: true
  copilot: partial

includes:
  # External skills from Antigravity (pristine)
  - repo: anthropics/antigravity-awesome-skills
    path: skills/
    items:
      - security-review
      - dependency-vulnerability-check
      - code-hardening

  # Claude Code plugins (pristine)
  - repo: anthropics/claude-code
    path: plugins/
    items:
      - security-scanner

  # AFX-built skills (guardrails baked in)
  - repo: rixrix/afx
    path: skills/
    items:
      - afx-owasp-top-10 # OWASP top 10 checklist with @see tracing
      - afx-security-audit # Security audit workflow
```

### 1.2 Pack Index (`packs/index.json`)

Located in the AFX repo. Single aggregated metadata file for all packs and upstream providers. Fetched by vscode-afx via `raw.githubusercontent.com` — no auth required.

```jsonc
{
  "packs": {
    "afx-pack-qa": {
      "description": "QA Engineer role pack — testing, review, and quality assurance",
      "category": "role",
      "providers": ["claude", "codex", "antigravity", "copilot"],
    },
    "afx-pack-security": {
      "description": "Security review and audit pack — OWASP, dependency scanning, code hardening",
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

### 1.3 Project State (`.afx.yaml`)

Located in the user's project root. Committed to git (team-shared).

```yaml
# .afx.yaml (committed — team-shared)
packs:
  - name: afx-pack-qa
    status: enabled
    installed_ref: v1.5.3 # git ref used at install time (from --version, --branch, or default main)
    disabled_items: []

  - name: afx-pack-security
    status: disabled
    installed_ref: main
    disabled_items: []

custom_skills:
  - repo: anthropics/antigravity-awesome-skills
    path: skills/some-niche-skill
```

---

## 2. Directory Structure

### 2.1 AFX Repo — New Directories

Two new top-level directories in `rixrix/afx`:

```
afx/                                    # AFX repo (rixrix/afx)
├── packs/                              # NEW — pack manifests + index
│   ├── index.json                      # Aggregated metadata for discovery
│   ├── afx-pack-qa.yaml               # QA pack manifest
│   └── afx-pack-security.yaml         # Security pack manifest
│
├── skills/                             # NEW — AFX-built skills (guardrails baked in)
│   ├── afx-qa-methodology/            # Mirrors .afx/packs/{pack}/ structure
│   │   ├── claude/
│   │   │   └── skills/
│   │   │       └── afx-qa-methodology/
│   │   │           └── SKILL.md
│   │   ├── codex/
│   │   │   └── skills/
│   │   │       └── afx-qa-methodology/
│   │   │           └── SKILL.md
│   │   ├── antigravity/
│   │   │   └── skills/
│   │   │       └── afx-qa-methodology/
│   │   │           └── SKILL.md
│   │   └── copilot/
│   │       └── agents/
│   │           └── afx-qa-methodology.agent.md
│   ├── afx-spec-test-planning/
│   │   ├── claude/
│   │   │   └── skills/
│   │   │       └── afx-spec-test-planning/
│   │   │           └── SKILL.md
│   │   ├── codex/
│   │   │   └── skills/
│   │   │       └── afx-spec-test-planning/
│   │   │           └── SKILL.md
│   │   ├── antigravity/
│   │   │   └── skills/
│   │   │       └── afx-spec-test-planning/
│   │   │           └── SKILL.md
│   │   └── copilot/
│   │       └── agents/
│   │           └── afx-spec-test-planning.agent.md
│   ├── afx-owasp-top-10/
│   │   ├── claude/
│   │   │   └── skills/
│   │   │       └── afx-owasp-top-10/
│   │   │           └── SKILL.md
│   │   ├── codex/
│   │   │   └── skills/
│   │   │       └── afx-owasp-top-10/
│   │   │           └── SKILL.md
│   │   ├── antigravity/
│   │   │   └── skills/
│   │   │       └── afx-owasp-top-10/
│   │   │           └── SKILL.md
│   │   └── copilot/
│   │       └── agents/
│   │           └── afx-owasp-top-10.agent.md
│   └── afx-security-audit/
│       ├── claude/
│       │   └── skills/
│       │       └── afx-security-audit/
│       │           └── SKILL.md
│       ├── codex/
│       │   └── skills/
│       │       └── afx-security-audit/
│       │           └── SKILL.md
│       ├── antigravity/
│       │   └── skills/
│       │       └── afx-security-audit/
│       │           └── SKILL.md
│       └── copilot/
│           └── agents/
│               └── afx-security-audit.agent.md
│
├── afx-cli                          # MODIFIED — pack management added
├── .claude/commands/                   # Existing
├── .agents/skills/                     # Existing (Codex/Copilot/Antigravity skill target)
├── .github/prompts/                    # Existing
├── templates/                          # Existing
└── docs/                               # Existing
```

### 2.2 User Project — Master Storage (`.afx/`)

The `.afx/` directory acts as the local package cache in the user's project. It is gitignored.

```
.afx/                                                          # Gitignored
├── .cache/
│   └── lastIndex.json                                         # Cached index + timestamp
│
└── packs/
    ├── afx-pack-qa/                                           # Installed pack (enabled)
    │   ├── claude/
    │   │   ├── skills/
    │   │   │   ├── test-driven-development/                  # PRISTINE from Antigravity
    │   │   │   │   ├── SKILL.md
    │   │   │   │   └── resources/
    │   │   │   ├── tdd-workflow/                             # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── playwright-skill/                         # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── e2e-testing-patterns/                     # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── unit-testing-test-generate/               # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── systematic-debugging/                     # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── performance-testing-review/               # PRISTINE from Antigravity
    │   │   │   │   └── SKILL.md
    │   │   │   ├── afx-qa-methodology/                       # AFX-BUILT
    │   │   │   │   └── SKILL.md
    │   │   │   └── afx-spec-test-planning/                   # AFX-BUILT
    │   │   │       └── SKILL.md
    │   │   └── plugins/
    │   │       ├── code-review/                              # PRISTINE from Claude Code
    │   │       │   ├── .claude-plugin/plugin.json
    │   │       │   ├── commands/review.md
    │   │       │   └── hooks/hooks.json
    │   │       └── pr-review-toolkit/                        # PRISTINE from Claude Code
    │   │           ├── .claude-plugin/plugin.json
    │   │           └── commands/
    │   ├── codex/
    │   │   └── skills/
    │   │       ├── test-driven-development/                  # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── tdd-workflow/                             # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── playwright-skill/                         # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── e2e-testing-patterns/                     # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── unit-testing-test-generate/               # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── systematic-debugging/                     # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── performance-testing-review/               # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── playwright/                               # PRISTINE from OpenAI
    │   │       │   ├── SKILL.md
    │   │       │   ├── agents/openai.yaml
    │   │       │   └── scripts/run-tests.py
    │   │       ├── afx-qa-methodology/                       # AFX-BUILT
    │   │       │   └── SKILL.md
    │   │       └── afx-spec-test-planning/                   # AFX-BUILT
    │   │           └── SKILL.md
    │   ├── antigravity/
    │   │   └── skills/
    │   │       ├── test-driven-development/                  # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── tdd-workflow/                             # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── playwright-skill/                         # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── e2e-testing-patterns/                     # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── unit-testing-test-generate/               # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── systematic-debugging/                     # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── performance-testing-review/               # PRISTINE from Antigravity
    │   │       │   └── SKILL.md
    │   │       ├── afx-qa-methodology/                       # AFX-BUILT
    │   │       │   └── SKILL.md
    │   │       └── afx-spec-test-planning/                   # AFX-BUILT
    │   │           └── SKILL.md
    │   └── copilot/
    │       └── agents/
    │           ├── afx-qa-methodology.agent.md               # AFX-BUILT (only AFX skills)
    │           └── afx-spec-test-planning.agent.md           # AFX-BUILT
    │
    └── afx-pack-security/                                     # Installed pack (disabled — master preserved)
        ├── claude/
        │   ├── skills/
        │   │   ├── security-review/                          # PRISTINE from Antigravity
        │   │   │   └── SKILL.md
        │   │   ├── dependency-vulnerability-check/           # PRISTINE from Antigravity
        │   │   │   └── SKILL.md
        │   │   ├── code-hardening/                           # PRISTINE from Antigravity
        │   │   │   └── SKILL.md
        │   │   ├── afx-owasp-top-10/                         # AFX-BUILT
        │   │   │   └── SKILL.md
        │   │   └── afx-security-audit/                       # AFX-BUILT
        │   │       └── SKILL.md
        │   └── plugins/
        │       └── security-scanner/                         # PRISTINE from Claude Code
        │           ├── .claude-plugin/plugin.json
        │           └── commands/
        ├── codex/
        │   └── skills/
        │       ├── security-review/                          # PRISTINE from Antigravity
        │       │   └── SKILL.md
        │       ├── dependency-vulnerability-check/           # PRISTINE from Antigravity
        │       │   └── SKILL.md
        │       ├── code-hardening/                           # PRISTINE from Antigravity
        │       │   └── SKILL.md
        │       ├── afx-owasp-top-10/                         # AFX-BUILT
        │       │   └── SKILL.md
        │       └── afx-security-audit/                       # AFX-BUILT
        │           └── SKILL.md
        ├── antigravity/
        │   └── skills/
        │       ├── security-review/                          # PRISTINE from Antigravity
        │       │   └── SKILL.md
        │       ├── dependency-vulnerability-check/           # PRISTINE from Antigravity
        │       │   └── SKILL.md
        │       ├── code-hardening/                           # PRISTINE from Antigravity
        │       │   └── SKILL.md
        │       ├── afx-owasp-top-10/                         # AFX-BUILT
        │       │   └── SKILL.md
        │       └── afx-security-audit/                       # AFX-BUILT
        │           └── SKILL.md
        └── copilot/
            └── agents/
                ├── afx-owasp-top-10.agent.md                # AFX-BUILT
                └── afx-security-audit.agent.md              # AFX-BUILT
```

### 2.3 User Project — Provider Directories (Derived)

`afx-cli` copies files from `.afx/packs/` to these locations based on `.afx.yaml` state. These are ephemeral — they can be rebuilt from `.afx/packs/` master at any time.

```
project/
├── .claude/
│   ├── commands/                  # Existing AFX slash commands (unchanged)
│   │   └── afx-*.md
│   ├── skills/                    # ← pack skills copied here
│   │   ├── test-driven-development/
│   │   ├── tdd-workflow/
│   │   ├── playwright-skill/
│   │   ├── e2e-testing-patterns/
│   │   ├── unit-testing-test-generate/
│   │   ├── systematic-debugging/
│   │   ├── performance-testing-review/
│   │   ├── afx-qa-methodology/
│   │   └── afx-spec-test-planning/
│   └── plugins/                   # ← pack plugins copied here
│       ├── code-review/
│       └── pr-review-toolkit/
│
├── .agents/
│   └── skills/                    # ← pack skills copied here (Codex CLI)
│       ├── test-driven-development/
│       ├── tdd-workflow/
│       ├── playwright-skill/
│       ├── e2e-testing-patterns/
│       ├── unit-testing-test-generate/
│       ├── systematic-debugging/
│       ├── performance-testing-review/
│       ├── playwright/            # OpenAI skill (Codex only)
│       ├── afx-qa-methodology/
│       └── afx-spec-test-planning/
│
├── .agent/
│   └── skills/                    # ← pack skills copied here (Google Antigravity)
│       ├── test-driven-development/
│       ├── tdd-workflow/
│       ├── playwright-skill/
│       ├── e2e-testing-patterns/
│       ├── unit-testing-test-generate/
│       ├── systematic-debugging/
│       ├── performance-testing-review/
│       ├── afx-qa-methodology/
│       └── afx-spec-test-planning/
│
├── .github/
│   ├── prompts/                   # Existing AFX Copilot prompts (unchanged)
│   │   └── afx-*.prompt.md
│   └── agents/                    # ← AFX-built agents copied here
│       ├── afx-qa-methodology.agent.md
│       └── afx-spec-test-planning.agent.md
│
├── .afx/                          # Master storage (gitignored)
├── .afx.yaml                      # Pack state (committed)
└── ...
```

### 2.4 Provider Directory Conventions

Each provider has a fixed directory layout that it scans for auto-discovery.

**Claude Code** — scans `.claude/` for components:

```
.claude/
├── commands/*.md              # Slash commands — auto-discovered by filename
├── agents/*.md                # Subagents — auto-discovered by filename
├── skills/{name}/             # Auto-activating skills — one dir per skill
│   ├── SKILL.md               #   REQUIRED
│   ├── references/            #   Loaded on demand
│   └── examples/              #   Working code samples
├── plugins/{name}/            # Full plugins — auto-discovered as a unit
│   ├── .claude-plugin/
│   │   └── plugin.json        #   REQUIRED (name, version, description)
│   ├── commands/*.md
│   ├── agents/*.md
│   ├── skills/{name}/SKILL.md
│   ├── hooks/hooks.json
│   └── [core/, utils/, ...]
└── hooks.json                 # Project-level hooks
```

**Codex CLI** — scans `.agents/skills/` for skills:

```
.agents/
└── skills/{name}/             # One dir per skill
    ├── SKILL.md               #   REQUIRED
    ├── agents/
    │   └── openai.yaml        #   Agent interface (display_name, icon, default_prompt)
    ├── scripts/*.py           #   Executable scripts
    ├── references/            #   Supporting docs
    └── assets/                #   Icons, templates
```

**Google Antigravity** — scans `.agent/skills/` for skills:

```
.agent/
└── skills/{name}/             # One dir per skill
    ├── SKILL.md               #   REQUIRED (agentskills.io standard)
    ├── references/            #   Supporting docs
    └── examples/              #   Working code samples
```

**Copilot** — scans `.github/agents/` for agent files:

```
.github/
└── agents/
    └── {name}.agent.md        # One file per agent (frontmatter + body)
```

---

## 3. afx-cli Architecture

### 3.1 Prerequisites

`afx-cli` requires only three standard POSIX-available tools:

| Tool   | Purpose                                         | Availability                      |
| :----- | :---------------------------------------------- | :-------------------------------- |
| `bash` | Script runtime (≥ 4.0)                          | macOS, Linux, WSL — pre-installed |
| `curl` | Download tarballs and raw files from GitHub     | macOS, Linux, WSL — pre-installed |
| `tar`  | Extract specific paths from downloaded tarballs | macOS, Linux, WSL — pre-installed |

**Not required**: `git`, `node`, `python`, `npm`, `pip`, or any package manager. This is intentional — the script must work on a fresh machine with no dev tooling beyond a shell.

**Platform support**: macOS, Linux, and WSL (Windows Subsystem for Linux). Native Windows (cmd/PowerShell) is not supported.

### 3.2 Current afx-cli Structure

The existing `afx-cli` (767 lines) handles core AFX installation only. No pack support exists today.

**Current flow (11 steps):**

```
1. Parse arguments (--update, --skills-only, --force, --dry-run, etc.)
2. Validate target directory
3. Determine AFX source (local clone or git clone to temp)
4. [1/11] Install Claude slash commands (.claude/commands/)
5. [2/11] Install agent skills (.agents/skills/)
7. [4/11] Install GitHub Copilot prompts (.github/prompts/)
8. [5/11] Install templates
9. [6/11] Create/update .afx.yaml
10. [7/11]-[9/11] Update CLAUDE.md, AGENTS.md, GEMINI.md
11. [11/11] Install AFX documentation
→ Print summary
```

**Current argument parser** (line 62-136):

```bash
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)      UPDATE_MODE=true; shift ;;
        --skills-only) COMMANDS_ONLY=true; shift ;;
        --no-claude-md)  NO_CLAUDE_MD=true; shift ;;
        --no-agents-md)  NO_AGENTS_MD=true; shift ;;
        --no-gemini-md)  NO_GEMINI_MD=true; shift ;;
        --with-gemini-md) WITH_GEMINI_MD=true; shift ;;
        --no-docs)       NO_DOCS=true; shift ;;
        --force)         FORCE=true; shift ;;
        --dry-run)       DRY_RUN=true; shift ;;
        -h|--help)       # print help; exit 0 ;;
        *)               TARGET_DIR="$1"; shift ;;
    esac
done
```

**Current AFX source resolution** (line 165-182): Uses `git clone --depth 1` when running remotely. This must change to `curl` + `tar` for pack operations (no git dependency).

**Existing helpers** (used by both core and pack operations):

- `install_file()` — copy single file with dry-run/update/force logic
- `install_directory()` — copy directory with rm+cp for updates

### 3.3 New Arguments

Pack management adds these flags to the argument parser:

```bash
# New variables (defaults)
PACK_NAMES=()          # Array — supports --pack qa --pack security
# PACK_DISABLE and PACK_ENABLE removed
PACK_REMOVE=""         # Single pack name
PACK_LIST=false
SKILL_DISABLE=""       # Skill name (requires --pack)
SKILL_ENABLE=""        # Skill name (requires --pack)
UPDATE_PACKS=false     # --update --packs
ADD_SKILL=""           # repo:path/skill format
BRANCH=""              # Branch name (e.g., dev, feature/packs)
VERSION=""             # Version tag (e.g., v1.5.3, 1.5.3)

# New case entries
--pack)          PACK_NAMES+=("$2"); shift 2 ;;
# --pack-disable and --pack-enable removed — use --pack-remove and re-install
--pack-remove)   PACK_REMOVE="$2"; shift 2 ;;
--pack-list)     PACK_LIST=true; shift ;;
--skill-disable) SKILL_DISABLE="$2"; shift 2 ;;
--skill-enable)  SKILL_ENABLE="$2"; shift 2 ;;
--packs)         UPDATE_PACKS=true; shift ;;
--add-skill)     ADD_SKILL="$2"; shift 2 ;;
--branch)        BRANCH="$2"; shift 2 ;;
--version)       VERSION="$2"; shift 2 ;;
```

**Validation rules:**

- `--skill-disable` and `--skill-enable` require `--pack` to be set
- `--packs` only valid with `--update`
- `--branch` and `--version` are mutually exclusive
- `--branch` and `--version` only affect AFX repo fetches, not upstream
- `--dry-run` applies to all pack operations
- Pack flags are mutually exclusive with each other (can't combine lifecycle commands in one call)

### 3.4 Download Strategy

To avoid full git clones, we use `curl` + `tar` against GitHub's codeload service.

#### Ref Resolution

The `{ref}` used for AFX repo fetches is resolved from three sources in priority order:

1. `--version {tag}` — a release version tag (e.g., `v1.5.3` or `1.5.3`). Auto-prefixes `v` if missing.
2. `--branch {name}` — a branch name (e.g., `dev`, `feature/packs`).
3. Default: `main`.

`--branch` and `--version` are mutually exclusive — the script exits with an error if both are provided.

```bash
# Resolve the git ref for AFX repo fetches
resolve_ref() {
    if [[ -n "$VERSION" && -n "$BRANCH" ]]; then
        echo "Error: --version and --branch are mutually exclusive" >&2
        exit 1
    fi
    if [[ -n "$VERSION" ]]; then
        # Auto-prefix v if missing (1.5.3 → v1.5.3)
        [[ "$VERSION" == v* ]] && echo "$VERSION" || echo "v$VERSION"
    elif [[ -n "$BRANCH" ]]; then
        echo "$BRANCH"
    else
        echo "main"
    fi
}
```

| Invocation                               | `{ref}` used |
| :--------------------------------------- | :----------- |
| `./afx-cli --pack qa .`                  | `main`       |
| `./afx-cli --branch dev --pack qa .`     | `dev`        |
| `./afx-cli --version 1.5.3 --pack qa .`  | `v1.5.3`     |
| `./afx-cli --version v1.5.3 --pack qa .` | `v1.5.3`     |

#### URL Patterns

| Purpose          | URL                                                               | Notes                                       |
| :--------------- | :---------------------------------------------------------------- | :------------------------------------------ |
| AFX repo tarball | `https://codeload.github.com/rixrix/afx/tar.gz/{ref}`             | `{ref}` resolved by `resolve_ref()`         |
| Upstream tarball | `https://codeload.github.com/{owner}/{repo}/tar.gz/main`          | Always `main` — branch/version flag ignored |
| Raw file fetch   | `https://raw.githubusercontent.com/rixrix/afx/{ref}/path/to/file` | For single files (index.json, manifests)    |

This applies to:

1. **AFX repo fetches** — pack manifests, index, AFX-built skills all come from `https://codeload.github.com/rixrix/afx/tar.gz/{ref}`
2. **Upstream repo fetches** — external skills are always fetched from `main` (`--branch` and `--version` only control the AFX repo ref, not upstream repos)

**Download function:**

```bash
# Download and extract specific paths from a GitHub repo tarball
# Usage: download_items <owner/repo> <ref> <base_path> <items...>
download_items() {
    local repo="$1"
    local ref="$2"
    local base_path="$3"
    shift 3
    local items=("$@")

    local url="https://codeload.github.com/${repo}/tar.gz/${ref}"
    local temp_dir=$(mktemp -d)

    # Build tar extraction patterns
    # Tarball root is {repo-name}-{ref}/, so strip-components=1
    local patterns=()
    local repo_name="${repo##*/}"
    for item in "${items[@]}"; do
        patterns+=("${repo_name}-${ref}/${base_path}${item}")
    done

    # Download and extract
    curl -sL "$url" | tar xz -C "$temp_dir" --strip-components=1 "${patterns[@]}" 2>/dev/null

    echo "$temp_dir"
}
```

**Extraction logic:**

1. Resolve `ref` — call `resolve_ref()` to get the effective git ref from `--version`, `--branch`, or default `main`.
2. Download tarball to temp dir via `curl -sL | tar xz`.
3. Extract specific paths defined in manifest `includes` using tar path patterns.
4. Move extracted items to `.afx/packs/{pack}/{temp_staging}`.
5. Clean up temp dir.

**Manifest fetch** (single file — use raw URL):

```bash
# Fetch a pack manifest YAML
fetch_manifest() {
    local pack_name="$1"
    local ref="$2"
    curl -sL "https://raw.githubusercontent.com/rixrix/afx/${ref}/packs/${pack_name}.yaml"
}
```

### 3.5 YAML Parsing

Pack manifests are YAML. Since we can't depend on external tools, we use `grep`/`sed`/`awk` for the simple flat structure.

**Fields to extract from manifest:**

```bash
# Parse pack manifest — extract key fields
parse_manifest() {
    local manifest="$1"

    # Simple fields (line-level grep — safe for flat YAML)
    PACK_NAME=$(grep '^name:' "$manifest" | awk '{print $2}')
    PACK_DESC=$(grep '^description:' "$manifest" | sed 's/^description: //')
    PACK_CATEGORY=$(grep '^category:' "$manifest" | awk '{print $2}')

    # platforms: — 2-space indent, key:value pairs
    #   claude: true
    #   codex: true
    #   copilot: partial
}

# Parse includes[] — state machine for repo/path/items blocks
# Outputs one line per include: "repo path item1 item2 ..."
for_each_include() {
    local manifest="$1"
    local in_includes=false
    local current_repo="" current_path=""
    local items=()

    while IFS= read -r line; do
        # Detect sections
        if [[ "$line" == "includes:" ]]; then
            in_includes=true; continue
        fi
        # Exit includes on next top-level key
        if $in_includes && [[ "$line" =~ ^[a-z] ]]; then
            # Flush last block
            [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
            break
        fi

        if $in_includes; then
            if [[ "$line" =~ ^\ \ -\ repo:\ (.+) ]]; then
                # Flush previous block
                [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
                current_repo="${BASH_REMATCH[1]}"
                current_path="" ; items=()
            elif [[ "$line" =~ ^\ \ \ \ path:\ (.+) ]]; then
                current_path="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^\ \ \ \ \ \ -\ (.+) ]]; then
                items+=("${BASH_REMATCH[1]}")
            fi
        fi
    done < "$manifest"

    # Flush final block
    [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
}
```

#### Manifest YAML Subset Rules

To keep bash parsing tractable, manifests MUST follow these strict formatting rules:

| Rule                           | Constraint                                                    |
| :----------------------------- | :------------------------------------------------------------ |
| Top-level keys                 | No indent, `key: value` or `key:` (for maps/arrays)           |
| `platforms:` entries           | 2-space indent, `key: value`                                  |
| `includes:` entries            | `- repo:` at 2-space indent                                   |
| Include fields                 | `path:` and `items:` at 4-space indent                        |
| Item entries                   | `- name` at 6-space indent                                    |
| No comments inline with values | `# comments` only on their own line or after value with space |
| No multi-line strings          | All values on a single line                                   |
| No anchors/aliases             | No `&` or `*` YAML references                                 |

Manifests that violate these rules will fail to parse. This is intentional — the format is designed for bash, not for general YAML flexibility.

### 3.6 Type Detection & Routing

After download, `afx-cli` inspects each item to determine where it belongs.

| Signature                                | Type          | Target Providers                                       | Modification |
| :--------------------------------------- | :------------ | :----------------------------------------------------- | :----------- |
| `SKILL.md` at root, no `.claude-plugin/` | Simple Skill  | `.claude/skills/`, `.agents/skills/`, `.agent/skills/` | None         |
| `.claude-plugin/plugin.json` exists      | Claude Plugin | `.claude/plugins/`                                     | None         |
| `SKILL.md` + `agents/openai.yaml`        | OpenAI Skill  | `.agents/skills/` only                                 | None         |
| From `rixrix/afx` repo                   | AFX Skill     | All (transformed per provider from canonical SKILL.md) | N/A          |

**Detection function:**

```bash
# Detect skill type and return target providers
# Usage: detect_type <item_dir> <source_repo>
detect_type() {
    local item_dir="$1"
    local source_repo="$2"

    if [[ "$source_repo" == "rixrix/afx" ]]; then
        echo "afx"         # All providers — canonical SKILL.md, transformed per provider
    elif [[ -d "$item_dir/.claude-plugin" ]]; then
        echo "plugin"      # Claude only
    elif [[ -f "$item_dir/agents/openai.yaml" ]]; then
        echo "openai"      # Codex only
    elif [[ -f "$item_dir/SKILL.md" ]]; then
        echo "skill"       # Claude + Codex
    else
        echo "unknown"
    fi
}
```

**Routing logic by type:**

```bash
route_item() {
    local item_dir="$1"
    local item_name="$2"
    local type="$3"
    local pack_dir="$4"      # .afx/packs/afx-pack-{name}
    local platforms="$5"     # Manifest platforms string (e.g., "claude:true codex:true copilot:partial")

    case "$type" in
        skill)
            # Simple Skill → Claude + Codex + Antigravity (gated by manifest platforms)
            platform_enabled "$platforms" "claude" && \
                cp -r "$item_dir" "$pack_dir/claude/skills/$item_name"
            platform_enabled "$platforms" "codex" && \
                cp -r "$item_dir" "$pack_dir/codex/skills/$item_name"
            platform_enabled "$platforms" "antigravity" && \
                cp -r "$item_dir" "$pack_dir/antigravity/skills/$item_name"
            ;;
        plugin)
            # Claude Plugin → Claude only
            platform_enabled "$platforms" "claude" && \
                cp -r "$item_dir" "$pack_dir/claude/plugins/$item_name"
            ;;
        openai)
            # OpenAI Skill → Codex only
            platform_enabled "$platforms" "codex" && \
                cp -r "$item_dir" "$pack_dir/codex/skills/$item_name"
            ;;
        afx)
            # AFX-built → canonical SKILL.md, transformed per provider
            local canonical="$item_dir/SKILL.md"
            for provider in claude codex antigravity; do
                platform_enabled "$platforms" "$provider" && \
                    transform_for_provider "$canonical" \
                        "$pack_dir/$provider/skills/$item_name/SKILL.md" "$provider"
            done
            platform_enabled "$platforms" "copilot" && \
                generate_copilot_agent "$canonical" \
                    "$pack_dir/copilot/agents/${item_name}.agent.md" "$item_name"
            ;;
    esac
}

# Check if a platform is enabled in the manifest (true or partial = enabled, false/missing = disabled)
platform_enabled() {
    local platforms="$1"
    local provider="$2"
    # Extract value for provider from platforms string
    local val=$(echo "$platforms" | grep -oP "${provider}:\K\w+")
    [[ "$val" == "true" || "$val" == "partial" ]]
}
```

**Platform gating:** The manifest's `platforms:` map gates which provider directories receive items. A platform value of `true` or `partial` enables routing; `false` or missing disables it. This prevents installing skills for providers the pack author didn't intend to support (e.g., a pack with `codex: false` won't copy SKILL.md files to `.agents/skills/` even if the file format is compatible).

### 3.7 AFX-Built Skills

AFX-built skills are hosted in the `rixrix/afx` repo under `skills/`. Each skill ships as a **single canonical SKILL.md** using Claude command syntax. At install time, `afx-cli` transforms this file per provider — eliminating 4× file duplication in the source repo.

```
skills/afx-qa-methodology/
└── SKILL.md                           # Single canonical file (Claude format)
```

The canonical file uses HTML comment markers to delineate provider-specific command references:

```markdown
### AFX Integration

<!-- @afx:provider-commands -->

- Use `/afx-check path` to verify execution flow from UI to DB
- Use `/afx-task verify` to verify test coverage against spec
<!-- @afx:/provider-commands -->
- Follow the spec → design → tasks → code traceability chain
```

**Transform rules per provider:**

| Provider    | Action                                                         |
| ----------- | -------------------------------------------------------------- |
| Claude      | Strip markers, keep content as-is (canonical format)           |
| Codex       | Strip markers, sed `/afx-cmd sub` → `afx-cmd-sub`              |
| Antigravity | Remove markers AND content between them (generic lines remain) |
| Copilot     | Auto-generate condensed `agent.md` from SKILL.md structure     |

**Sed patterns used:**

```bash
# Claude — strip markers only
sed -e '/<!-- @afx:provider-commands -->/d' \
    -e '/<!-- @afx:\/provider-commands -->/d'

# Codex — strip markers + convert command syntax to kebab-case
sed -e '/<!-- @afx:provider-commands -->/d' \
    -e '/<!-- @afx:\/provider-commands -->/d' \
    -e 's|`/afx-\([a-z]*\) \([a-z]*\)`|`afx-\1-\2`|g'

# Antigravity — remove entire marked block (markers + content between)
sed '/<!-- @afx:provider-commands -->/,/<!-- @afx:\/provider-commands -->/d'
```

**Copilot generation** extracts the title, description, and instruction items from the canonical SKILL.md and produces a condensed `agent.md` with YAML frontmatter.

`afx-cli` routing for AFX-built skills (type `afx`):

```
skills/{name}/SKILL.md  → transform → .afx/packs/{pack}/claude/skills/{name}/SKILL.md
skills/{name}/SKILL.md  → transform → .afx/packs/{pack}/codex/skills/{name}/SKILL.md
skills/{name}/SKILL.md  → transform → .afx/packs/{pack}/antigravity/skills/{name}/SKILL.md
skills/{name}/SKILL.md  → generate  → .afx/packs/{pack}/copilot/agents/{name}.agent.md
```

The only differentiator from external skills is the **guardrails baked in** — AFX-built skills include `@see` traceability, two-stage verification, and spec-driven patterns.

### 3.8 Name Collision Detection

Before copying items to provider directories, `afx-cli` checks for name collisions.

```bash
# Check if a skill/plugin already exists in a provider dir from a DIFFERENT pack
# Usage: check_collision <item_name> <provider_dir> <current_pack>
check_collision() {
    local item_name="$1"
    local provider_dir="$2"
    local current_pack="$3"

    if [[ -d "$provider_dir/$item_name" ]]; then
        # Check all installed packs to see who owns this item
        for pack_dir in "$TARGET_DIR/.afx/packs"/afx-pack-*/; do
            local pack_name=$(basename "$pack_dir")
            if [[ "$pack_name" != "$current_pack" ]]; then
                # Check if this other pack has this item in its master
                if [[ -d "$pack_dir"/*/"skills/$item_name" ]] || \
                   [[ -d "$pack_dir"/*/"plugins/$item_name" ]]; then
                    echo -e "${RED}Error: '$item_name' already installed by pack '$pack_name'${NC}"
                    echo "Use --force to overwrite."
                    return 1
                fi
            fi
        done
    fi
    return 0
}
```

### 3.9 State Transitions

#### Install + Enable (`--pack {name}` [--branch {ref} | --version {tag}])

```bash
pack_install() {
    local pack_name="afx-pack-$1"
    local ref=$(resolve_ref)
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    # 1. Ensure .afx/ and .gitignore
    mkdir -p "$TARGET_DIR/.afx/.cache"
    ensure_gitignore ".afx/"

    # 2. Fetch manifest
    local manifest=$(fetch_manifest "$pack_name" "$ref")

    # 3. For each includes entry, download items
    for_each_include "$manifest" | while read repo path items; do
        local item_ref="main"
        if [[ "$repo" == "rixrix/afx" ]]; then
            item_ref="$ref"    # Use --branch for AFX repo only
        fi

        local temp=$(download_items "$repo" "$item_ref" "$path" $items)

        # 4. Detect type and route to .afx/packs/{pack}/{provider}/
        local platforms=$(parse_platforms "$manifest")
        for item_dir in "$temp"/*/; do
            local item_name=$(basename "$item_dir")
            local type=$(detect_type "$item_dir" "$repo")
            route_item "$item_dir" "$item_name" "$type" "$pack_dir" "$platforms"
        done

        rm -rf "$temp"
    done

    # 5. Copy from master to provider dirs
    pack_copy_to_providers "$pack_name"

    # 6. Update .afx.yaml (store ref for staleness checks / sync)
    afx_yaml_set_pack "$pack_name" "enabled" "$ref"

    echo -e "${GREEN}Pack '$1' installed and enabled (ref: $ref).${NC}"
}
```

#### ~~Enable (`--pack-enable`)~~ / ~~Disable (`--pack-disable`)~~ — Removed

These flags have been removed. To re-enable a pack, re-install with `--pack {name}`. To disable, use `--pack-remove {name}`.

#### Remove (`--pack-remove {name}`)

```bash
pack_remove() {
    local pack_name="afx-pack-$1"
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    # 1. Remove provider copies
    pack_remove_from_providers "$pack_name"

    # 2. Delete master
    rm -rf "$pack_dir"

    # 3. Remove from .afx.yaml
    afx_yaml_remove_pack "$pack_name"

    echo -e "${YELLOW}Pack '$1' removed entirely.${NC}"
}
```

#### Update Packs (`--update --packs`)

```bash
pack_update_all() {
    local ref=$(resolve_ref)

    # Fetch latest index
    curl -sL "https://raw.githubusercontent.com/rixrix/afx/${ref}/packs/index.json" \
        > "$TARGET_DIR/.afx/.cache/lastIndex.json"

    # For each enabled pack in .afx.yaml
    for pack_name in $(afx_yaml_enabled_packs); do
        echo -e "${BLUE}Updating $pack_name...${NC}"

        # Re-download to temp
        # Replace .afx/packs/{pack}/
        # Re-copy to providers
        pack_remove_from_providers "$pack_name"
        rm -rf "$TARGET_DIR/.afx/packs/$pack_name"

        # Re-install (reuses pack_install logic)
        local short_name="${pack_name#afx-pack-}"
        pack_install "$short_name"
    done
}
```

#### Skill Toggle (`--skill-disable / --skill-enable`)

```bash
skill_disable() {
    local skill_name="$1"
    local pack_name="afx-pack-$2"

    # Remove this specific skill from provider dirs
    rm -rf "$TARGET_DIR/.claude/skills/$skill_name"
    rm -rf "$TARGET_DIR/.claude/plugins/$skill_name"
    rm -rf "$TARGET_DIR/.agents/skills/$skill_name"
    rm -rf "$TARGET_DIR/.agent/skills/$skill_name"
    rm -f  "$TARGET_DIR/.github/agents/${skill_name}.agent.md"

    # Add to disabled_items in .afx.yaml
    afx_yaml_disable_item "$pack_name" "$skill_name"

    echo -e "${YELLOW}Skill '$skill_name' disabled in pack '${pack_name}'.${NC}"
}

skill_enable() {
    local skill_name="$1"
    local pack_name="afx-pack-$2"
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    # Check for collisions before restoring
    check_collision "$skill_name" "$TARGET_DIR/.claude/skills" "$pack_name" || exit 1

    # Copy from master for this specific skill
    for provider in claude codex antigravity copilot; do
        if [[ -d "$pack_dir/$provider/skills/$skill_name" ]]; then
            local target=$(provider_target_dir "$provider" "skills")
            cp -r "$pack_dir/$provider/skills/$skill_name" "$target/$skill_name"
        fi
        if [[ -d "$pack_dir/$provider/plugins/$skill_name" ]]; then
            local target=$(provider_target_dir "$provider" "plugins")
            cp -r "$pack_dir/$provider/plugins/$skill_name" "$target/$skill_name"
        fi
        if [[ -f "$pack_dir/$provider/agents/${skill_name}.agent.md" ]]; then
            cp "$pack_dir/$provider/agents/${skill_name}.agent.md" \
               "$TARGET_DIR/.github/agents/${skill_name}.agent.md"
        fi
    done

    # Remove from disabled_items in .afx.yaml
    afx_yaml_enable_item "$pack_name" "$skill_name"

    echo -e "${GREEN}Skill '$skill_name' re-enabled in pack '${pack_name}'.${NC}"
}
```

#### Pack List (`--pack-list`)

```bash
pack_list() {
    echo -e "${BLUE}Installed packs:${NC}"
    echo ""

    # Read from .afx.yaml
    for entry in $(afx_yaml_all_packs); do
        local name=$(echo "$entry" | cut -d: -f1)
        local status=$(echo "$entry" | cut -d: -f2)
        local disabled_count=$(echo "$entry" | cut -d: -f3)

        if [[ "$status" == "enabled" ]]; then
            echo -e "  ${GREEN}●${NC} $name (enabled)"
        else
            echo -e "  ${YELLOW}○${NC} $name (disabled)"
        fi

        if [[ "$disabled_count" -gt 0 ]]; then
            echo "    $disabled_count items disabled"
        fi
    done
}
```

#### Dry Run

All pack operations respect the existing `$DRY_RUN` flag. When `DRY_RUN=true`:

- Downloads still happen (to show what would be fetched)
- No files are written to `.afx/`, provider dirs, or `.afx.yaml`
- Output shows `(would create)`, `(would update)`, `(would delete)` annotations
- Uses the existing `INSTALLED[]`, `UPDATED[]`, `SKIPPED[]` tracking arrays

#### Add Skill (`--add-skill {repo}:{path}/{skill}`)

One-off skill install outside any pack. The skill is downloaded, type-detected, routed to provider dirs, and tracked in `.afx.yaml` under `custom_skills:`.

```bash
add_skill() {
    local spec="$1"   # e.g., "anthropics/antigravity-awesome-skills:skills/some-niche-skill"
    local repo="${spec%%:*}"
    local full_path="${spec#*:}"
    local skill_name=$(basename "$full_path")
    local base_path=$(dirname "$full_path")

    # 1. Download the single skill
    local temp=$(download_items "$repo" "main" "$base_path" "$skill_name")

    # 2. Detect type and copy to provider dirs directly (no .afx/packs/ master)
    local item_dir="$temp/$skill_name"
    local type=$(detect_type "$item_dir" "$repo")

    case "$type" in
        skill)
            cp -r "$item_dir" "$TARGET_DIR/.claude/skills/$skill_name"
            cp -r "$item_dir" "$TARGET_DIR/.agents/skills/$skill_name"
            cp -r "$item_dir" "$TARGET_DIR/.agent/skills/$skill_name"
            ;;
        plugin)
            cp -r "$item_dir" "$TARGET_DIR/.claude/plugins/$skill_name"
            ;;
        openai)
            cp -r "$item_dir" "$TARGET_DIR/.agents/skills/$skill_name"
            ;;
    esac

    rm -rf "$temp"

    # 3. Track in .afx.yaml
    afx_yaml_add_custom_skill "$repo" "$full_path"

    echo -e "${GREEN}Skill '$skill_name' installed from $repo.${NC}"
}
```

**Custom skills during `--update --packs`:** Custom skills are NOT updated by `--update --packs`. They are one-off installs — the user can re-run `--add-skill` to refresh them manually. The `custom_skills:` list in `.afx.yaml` serves as a team-shared record of what was installed, not as an update target.

### 3.10 Helper Functions

```bash
# Copy all items from .afx/packs/{pack}/{provider}/ to provider dirs
pack_copy_to_providers() {
    local pack_name="$1"
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"
    local disabled_items=$(afx_yaml_disabled_items "$pack_name")

    # Claude skills
    if [[ -d "$pack_dir/claude/skills" ]]; then
        for skill in "$pack_dir"/claude/skills/*/; do
            local name=$(basename "$skill")
            [[ " $disabled_items " =~ " $name " ]] && continue
            check_collision "$name" "$TARGET_DIR/.claude/skills" "$pack_name" || continue
            cp -r "$skill" "$TARGET_DIR/.claude/skills/$name"
        done
    fi

    # Claude plugins
    if [[ -d "$pack_dir/claude/plugins" ]]; then
        for plugin in "$pack_dir"/claude/plugins/*/; do
            local name=$(basename "$plugin")
            [[ " $disabled_items " =~ " $name " ]] && continue
            check_collision "$name" "$TARGET_DIR/.claude/plugins" "$pack_name" || continue
            cp -r "$plugin" "$TARGET_DIR/.claude/plugins/$name"
        done
    fi

    # Codex skills
    if [[ -d "$pack_dir/codex/skills" ]]; then
        for skill in "$pack_dir"/codex/skills/*/; do
            local name=$(basename "$skill")
            [[ " $disabled_items " =~ " $name " ]] && continue
            cp -r "$skill" "$TARGET_DIR/.agents/skills/$name"
        done
    fi

    # Antigravity skills
    if [[ -d "$pack_dir/antigravity/skills" ]]; then
        for skill in "$pack_dir"/antigravity/skills/*/; do
            local name=$(basename "$skill")
            [[ " $disabled_items " =~ " $name " ]] && continue
            cp -r "$skill" "$TARGET_DIR/.agent/skills/$name"
        done
    fi

    # Copilot agents
    if [[ -d "$pack_dir/copilot/agents" ]]; then
        for agent in "$pack_dir"/copilot/agents/*.agent.md; do
            local name=$(basename "$agent" .agent.md)
            [[ " $disabled_items " =~ " $name " ]] && continue
            cp "$agent" "$TARGET_DIR/.github/agents/$(basename "$agent")"
        done
    fi
}

# Remove all items belonging to a pack from provider dirs
pack_remove_from_providers() {
    local pack_name="$1"
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    # Walk the master and remove matching items from provider dirs
    for skill in "$pack_dir"/claude/skills/*/; do
        [[ -d "$skill" ]] && rm -rf "$TARGET_DIR/.claude/skills/$(basename "$skill")"
    done
    for plugin in "$pack_dir"/claude/plugins/*/; do
        [[ -d "$plugin" ]] && rm -rf "$TARGET_DIR/.claude/plugins/$(basename "$plugin")"
    done
    for skill in "$pack_dir"/codex/skills/*/; do
        [[ -d "$skill" ]] && rm -rf "$TARGET_DIR/.agents/skills/$(basename "$skill")"
    done
    for skill in "$pack_dir"/antigravity/skills/*/; do
        [[ -d "$skill" ]] && rm -rf "$TARGET_DIR/.agent/skills/$(basename "$skill")"
    done
    for agent in "$pack_dir"/copilot/agents/*.agent.md; do
        [[ -f "$agent" ]] && rm -f "$TARGET_DIR/.github/agents/$(basename "$agent")"
    done
}

# Map provider name to target directory
provider_target_dir() {
    local provider="$1"
    local subdir="$2"    # "skills" or "plugins"

    case "$provider" in
        claude)       echo "$TARGET_DIR/.claude/$subdir" ;;
        codex)        echo "$TARGET_DIR/.agents/$subdir" ;;
        antigravity)  echo "$TARGET_DIR/.agent/$subdir" ;;
        copilot)      echo "$TARGET_DIR/.github/agents" ;;
    esac
}

# Ensure .afx/ is in .gitignore
ensure_gitignore() {
    local pattern="$1"
    local gitignore="$TARGET_DIR/.gitignore"

    if [[ -f "$gitignore" ]]; then
        grep -qF "$pattern" "$gitignore" || echo "$pattern" >> "$gitignore"
    else
        echo "$pattern" > "$gitignore"
    fi
}
```

### 3.11 .afx.yaml Read/Write

Since we can't use a YAML library in bash, `.afx.yaml` operations use `grep`/`sed`/`awk`.

```bash
# Read all enabled pack names from .afx.yaml
afx_yaml_enabled_packs() {
    # Parse packs section, find entries with status: enabled
    awk '/^packs:/,/^[^ ]/' "$TARGET_DIR/.afx.yaml" | \
        grep -B1 'status: enabled' | \
        grep 'name:' | \
        awk '{print $3}'
}

# Set pack status in .afx.yaml (add if missing, update if exists)
afx_yaml_set_pack() {
    local pack_name="$1"
    local status="$2"
    local ref="${3:-}"   # optional — written on install, preserved on enable/disable
    # Implementation: check if pack exists in file, update or append
    # If ref is non-empty, set installed_ref: $ref
}

# Remove pack entry from .afx.yaml
afx_yaml_remove_pack() {
    local pack_name="$1"
    # Implementation: remove the multi-line block for this pack
}

# Get disabled_items for a pack
afx_yaml_disabled_items() {
    local pack_name="$1"
    # Implementation: parse disabled_items array for this pack
}

# Add item to disabled_items
afx_yaml_disable_item() {
    local pack_name="$1"
    local item_name="$2"
    # Implementation: append to disabled_items array
}

# Remove item from disabled_items
afx_yaml_enable_item() {
    local pack_name="$1"
    local item_name="$2"
    # Implementation: remove from disabled_items array
}
```

### 3.12 Remote Execution (curl pipe)

The existing remote install pattern must work for pack operations too:

```bash
# Core install (existing — unchanged)
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- .

# Pack install (new)
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- --pack qa .

# Pack install from branch (new)
curl -sL https://raw.githubusercontent.com/rixrix/afx/dev/afx-cli | bash -s -- --branch dev --pack qa .

# Pack install from version (new)
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- --version 1.5.3 --pack qa .

# Update packs (new)
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- --update --packs .
```

**Key change**: The current remote mode uses `git clone --depth 1` to get AFX source (line 173). Pack mode replaces this with `curl` + `tar` from codeload, removing the git dependency entirely. The current `git clone` path remains as a fallback for core-only installs but the preferred path becomes tarball-based.

### 3.13 Main Dispatch Logic

After argument parsing, the script dispatches to the appropriate handler:

```bash
# Pack operations take priority — if any pack flag is set, skip core install
if [[ ${#PACK_NAMES[@]} -gt 0 ]]; then
    for name in "${PACK_NAMES[@]}"; do
        pack_install "$name"
    done
    exit 0
fi

# --pack-disable and --pack-enable removed — use --pack-remove and re-install

if [[ -n "$PACK_REMOVE" ]]; then
    pack_remove "$PACK_REMOVE"
    exit 0
fi

if [[ "$PACK_LIST" == "true" ]]; then
    pack_list
    exit 0
fi

if [[ -n "$SKILL_DISABLE" ]]; then
    skill_disable "$SKILL_DISABLE" "${PACK_NAMES[0]}"
    exit 0
fi

if [[ -n "$SKILL_ENABLE" ]]; then
    skill_enable "$SKILL_ENABLE" "${PACK_NAMES[0]}"
    exit 0
fi

if [[ "$UPDATE_MODE" == "true" && "$UPDATE_PACKS" == "true" ]]; then
    pack_update_all
    exit 0
fi

# ... existing core install flow (unchanged) ...
```

---

## 4. AFX-Built Skills — Content

### 4.1 `afx-qa-methodology`

**Purpose**: QA workflow skill with AFX guardrails (SDD traceability, two-stage verification) baked in.

**`skills/afx-qa-methodology/claude/skills/afx-qa-methodology/SKILL.md`**:

```markdown
# AFX QA Methodology

A structured quality assurance workflow that integrates with AFX spec-driven development.

## Activation

This skill activates when the user asks about:

- Testing strategy or methodology
- Quality assurance workflows
- Test coverage analysis
- Bug triaging or classification

## Instructions

### Test Strategy

1. **Read the spec first** — always check `docs/specs/{feature}/spec.md` for acceptance criteria
2. **Link tests to requirements** — every test file must include `@see` annotations:
```

@see docs/specs/{feature}/spec.md#FR-{n}
@see docs/specs/{feature}/tasks.md#2.1-task-slug

```
3. **Two-stage verification** — mark tasks `[x]` in agent column, leave human column for reviewer
4. **Coverage mapping** — identify untested requirements and flag gaps

### Bug Triage

- Link bugs to spec requirements where possible
- Classify by severity: Critical (data loss), Major (broken workflow), Minor (cosmetic)
- Include reproduction steps tied to acceptance criteria

### AFX Integration

- Use `/afx-check path` to verify execution flow from UI to DB
- Use `/afx-task verify` to verify test coverage against spec
- Follow the spec → design → tasks → code traceability chain
```

**`skills/afx-qa-methodology/codex/skills/afx-qa-methodology/SKILL.md`**:

```markdown
# AFX QA Methodology

A structured quality assurance workflow that integrates with AFX spec-driven development.

## Activation

This skill activates when the user asks about:

- Testing strategy or methodology
- Quality assurance workflows
- Test coverage analysis
- Bug triaging or classification

## Instructions

### Test Strategy

1. **Read the spec first** — always check `docs/specs/{feature}/spec.md` for acceptance criteria
2. **Link tests to requirements** — every test file must include `@see` annotations:
```

@see docs/specs/{feature}/spec.md#FR-{n}
@see docs/specs/{feature}/tasks.md#2.1-task-slug

```
3. **Two-stage verification** — mark tasks `[x]` in agent column, leave human column for reviewer
4. **Coverage mapping** — identify untested requirements and flag gaps

### Bug Triage

- Link bugs to spec requirements where possible
- Classify by severity: Critical (data loss), Major (broken workflow), Minor (cosmetic)
- Include reproduction steps tied to acceptance criteria

### AFX Integration

- Use `afx-check-path` to verify execution flow from UI to DB
- Use `afx-task-audit` to verify test coverage against spec
- Follow the spec → design → tasks → code traceability chain
```

**`skills/afx-qa-methodology/antigravity/skills/afx-qa-methodology/SKILL.md`**:

```markdown
# AFX QA Methodology

A structured quality assurance workflow that integrates with AFX spec-driven development.

## Activation

This skill activates when the user asks about:

- Testing strategy or methodology
- Quality assurance workflows
- Test coverage analysis
- Bug triaging or classification

## Instructions

### Test Strategy

1. **Read the spec first** — always check `docs/specs/{feature}/spec.md` for acceptance criteria
2. **Link tests to requirements** — every test file must include `@see` annotations:
```

@see docs/specs/{feature}/spec.md#FR-{n}
@see docs/specs/{feature}/tasks.md#2.1-task-slug

```
3. **Two-stage verification** — mark tasks `[x]` in agent column, leave human column for reviewer
4. **Coverage mapping** — identify untested requirements and flag gaps

### Bug Triage

- Link bugs to spec requirements where possible
- Classify by severity: Critical (data loss), Major (broken workflow), Minor (cosmetic)
- Include reproduction steps tied to acceptance criteria

### AFX Integration

- Follow the spec → design → tasks → code traceability chain
- Use @see annotations to link implementations back to specs
```

**`skills/afx-qa-methodology/copilot/agents/afx-qa-methodology.agent.md`**:

```markdown
---
name: afx-qa-methodology
description: QA workflow with AFX spec-driven traceability
---

# AFX QA Methodology

Quality assurance workflow integrated with spec-driven development.

When assisting with testing or QA:

1. Check `docs/specs/{feature}/spec.md` for acceptance criteria
2. Link test files to specs with `@see` annotations
3. Map test coverage to functional requirements (FR-{n})
4. Flag untested requirements as gaps
5. Follow two-stage verification: agent marks [x], human reviews separately
```

### 4.2 `afx-spec-test-planning`

**Purpose**: Test planning skill that links test plans to spec tasks and requirements.

**`skills/afx-spec-test-planning/claude/skills/afx-spec-test-planning/SKILL.md`**:

````markdown
# AFX Spec Test Planning

Plan tests by deriving them directly from spec requirements and acceptance criteria.

## Activation

This skill activates when the user asks about:

- Test planning or test plan creation
- Deriving tests from specifications
- Mapping tests to requirements

## Instructions

### Derive Tests from Spec

1. Read `docs/specs/{feature}/spec.md`
2. For each FR-{n} and NFR-{n}, derive one or more test cases
3. For each acceptance criteria item, derive at least one assertion
4. Document the mapping:

   | Requirement | Test Case              | Type        | Status  |
   | ----------- | ---------------------- | ----------- | ------- |
   | FR-1        | test_user_login        | Integration | Pending |
   | NFR-1       | test_login_latency_p95 | Performance | Pending |

### Test File Structure

Every test file must include traceability:

```typescript
/**
 * @see docs/specs/{feature}/spec.md#FR-1
 * @see docs/specs/{feature}/tasks.md#3.1-write-login-tests
 */
describe('User Login', () => { ... });
```
````

### Gap Detection

After planning, check for:

- Requirements without test cases
- Test cases without requirement links
- Acceptance criteria without assertions

````

**`skills/afx-spec-test-planning/codex/skills/afx-spec-test-planning/SKILL.md`**:

```markdown
# AFX Spec Test Planning

Plan tests by deriving them directly from spec requirements and acceptance criteria.

## Activation

This skill activates when the user asks about:
- Test planning or test plan creation
- Deriving tests from specifications
- Mapping tests to requirements

## Instructions

### Derive Tests from Spec

1. Read `docs/specs/{feature}/spec.md`
2. For each FR-{n} and NFR-{n}, derive one or more test cases
3. For each acceptance criteria item, derive at least one assertion
4. Document the mapping:

   | Requirement | Test Case | Type | Status |
   |-------------|-----------|------|--------|
   | FR-1        | test_user_login | Integration | Pending |
   | NFR-1       | test_login_latency_p95 | Performance | Pending |

### Test File Structure

Every test file must include traceability:

```typescript
/**
 * @see docs/specs/{feature}/spec.md#FR-1
 * @see docs/specs/{feature}/tasks.md#3.1-write-login-tests
 */
describe('User Login', () => { ... });
````

### Gap Detection

After planning, check for:

- Requirements without test cases
- Test cases without requirement links
- Acceptance criteria without assertions

````

**`skills/afx-spec-test-planning/antigravity/skills/afx-spec-test-planning/SKILL.md`**:

```markdown
# AFX Spec Test Planning

Plan tests by deriving them directly from spec requirements and acceptance criteria.

## Activation

This skill activates when the user asks about:
- Test planning or test plan creation
- Deriving tests from specifications
- Mapping tests to requirements

## Instructions

### Derive Tests from Spec

1. Read `docs/specs/{feature}/spec.md`
2. For each FR-{n} and NFR-{n}, derive one or more test cases
3. For each acceptance criteria item, derive at least one assertion
4. Document the mapping:

   | Requirement | Test Case | Type | Status |
   |-------------|-----------|------|--------|
   | FR-1        | test_user_login | Integration | Pending |
   | NFR-1       | test_login_latency_p95 | Performance | Pending |

### Test File Structure

Every test file must include traceability:

```typescript
/**
 * @see docs/specs/{feature}/spec.md#FR-1
 * @see docs/specs/{feature}/tasks.md#3.1-write-login-tests
 */
describe('User Login', () => { ... });
```

### Gap Detection

After planning, check for:

- Requirements without test cases
- Test cases without requirement links
- Acceptance criteria without assertions
```

**`skills/afx-spec-test-planning/copilot/agents/afx-spec-test-planning.agent.md`**:

```markdown
---
name: afx-spec-test-planning
description: Test planning linked to spec requirements and acceptance criteria
---

# AFX Spec Test Planning

Derive test plans from spec requirements.

When planning tests:

1. Read the feature spec at `docs/specs/{feature}/spec.md`
2. Map each FR-{n} and NFR-{n} to test cases
3. Ensure each acceptance criteria has at least one test assertion
4. Add `@see` annotations linking tests to spec sections
5. Flag requirements without test coverage
````

---

## 5. Backward Compatibility

### 5.1 Core Install Unchanged

When no pack flags are provided, `afx-cli` behaves exactly as before:

```bash
# These work identically to today — zero changes
./afx-cli /path/to/project
./afx-cli --update .
./afx-cli --skills-only .
./afx-cli --no-claude-md --no-docs .
./afx-cli --force .
./afx-cli --dry-run .
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- .
curl -sL https://raw.githubusercontent.com/rixrix/afx/main/afx-cli | bash -s -- --update .
```

### 5.2 Existing Flags Preserved

All current flags continue to work:

| Flag               | Behavior                               | Pack interaction                |
| :----------------- | :------------------------------------- | :------------------------------ |
| `--update`         | Update core AFX commands               | Can combine with `--packs`      |
| `--skills-only`    | Only install command assets            | Ignored when pack flags present |
| `--no-claude-md`   | Skip CLAUDE.md snippet                 | N/A for pack ops                |
| `--no-agents-md`   | Skip AGENTS.md snippet                 | N/A for pack ops                |
| `--no-gemini-md`   | Skip GEMINI.md snippet                 | N/A for pack ops                |
| `--with-gemini-md` | Opt-in to Gemini CLI setup (GEMINI.md) | N/A for pack ops                |
| `--no-docs`        | Skip docs copy                         | N/A for pack ops                |
| `--force`          | Overwrite all files                    | Also forces pack overwrites     |
| `--dry-run`        | Preview without changes                | Works for all pack ops          |

### 5.3 Help Text Update

The `--help` output must be updated to include pack commands:

```
AFX Installer v{VERSION}

Usage: ./afx-cli [OPTIONS] <target-project-path>

Core Options:
  --update          Update existing AFX installation
  --skills-only   Only install/update command assets
  --no-claude-md    Skip CLAUDE.md snippet integration
  --no-agents-md    Skip AGENTS.md snippet integration
  --no-gemini-md    Skip GEMINI.md snippet integration
  --with-gemini-md  Opt-in to Gemini CLI setup (GEMINI.md)
  --no-docs         Skip copying AFX documentation
  --force           Overwrite all files (fresh install)
  --dry-run         Preview changes without applying
  --branch NAME     Use a specific branch (default: main)
  --version TAG     Use a specific version tag (e.g., 1.5.3 or v1.5.3)

Pack Management:
  --pack NAME                     Install and enable a pack
  # --pack-disable and --pack-enable removed
  --pack-remove NAME              Remove a pack entirely
  --pack-list                     List installed packs
  --skill-disable NAME --pack P   Disable a skill within a pack
  --skill-enable NAME --pack P    Re-enable a skill within a pack
  --update --packs                Update all enabled packs
  --add-skill REPO:PATH/SKILL    Install a single skill (no pack)

Examples:
  # Core install
  ./afx-cli .

  # Install QA pack
  ./afx-cli --pack qa .

  # Install from dev branch
  ./afx-cli --branch dev --pack qa .

  # Install from version
  ./afx-cli --version 1.5.3 --pack qa .

  # Multiple packs
  ./afx-cli --pack qa --pack security .

  # Manage packs
  # --pack-disable and --pack-enable removed — use --pack-remove and re-install
  ./afx-cli --pack-remove qa .
  ./afx-cli --pack-list .

  # Update all packs
  ./afx-cli --update --packs .
```

---

## 6. Security & Safety

- **No Overwrites**: If a user has a manually installed skill with the same name as a pack skill, `afx-cli` aborts with an error unless `--force` is used. Name collision detection (Section 3.8) prevents one pack from overwriting another pack's items.
- **Pristine Source**: We do not modify external code. We only place it. Downloaded files are byte-identical to the source repository.
- **Gitignore**: `.afx/` is added to `.gitignore` on first pack install to prevent committing external code to the user's repo.
- **No Auth**: All fetches use public URLs. No credentials, tokens, or API keys are stored or transmitted.
- **Temp Cleanup**: All temp directories created during download are cleaned up via `trap` handlers, even on failure.
- **Idempotent**: Running the same pack install twice produces the same result. Existing items are overwritten with identical content.

---

## 7. Implementation Plan

### Phase 1: Manifests & Index

1. Create `packs/` directory in AFX repo.
2. Author `packs/afx-pack-qa.yaml` (full manifest as shown in Section 1.1).
3. Author `packs/afx-pack-security.yaml` (full manifest as shown in Section 1.1).
4. Create `packs/index.json` (full index as shown in Section 1.2).

### Phase 2: AFX-Built Skills

1. Create `skills/` directory in AFX repo.
2. Author `skills/afx-qa-methodology/SKILL.md` (single canonical, with `@afx:provider-commands` markers).
3. Author `skills/afx-spec-test-planning/SKILL.md` (single canonical).
4. Author `skills/afx-owasp-top-10/SKILL.md` (single canonical, with `@afx:provider-commands` markers).
5. Author `skills/afx-security-audit/SKILL.md` (single canonical, with `@afx:provider-commands` markers).

### Phase 3: afx-cli — Download & Detection

1. Add new argument parsing (Section 3.3).
2. Implement `download_items()` — curl + tar extraction.
3. Implement `fetch_manifest()` — raw URL fetch.
4. Implement `detect_type()` — skill type detection.
5. Implement `route_item()` — type-based routing to `.afx/`.
6. Implement `check_collision()` — name collision detection.
7. Implement `ensure_gitignore()` — auto-add `.afx/` to `.gitignore`.

### Phase 4: afx-cli — State Management

1. Implement YAML read/write helpers for `.afx.yaml` (Section 3.11).
2. Implement `pack_install()` — full install + enable flow.
3. Implement `pack_enable()` / `pack_disable()` / `pack_remove()`.
4. Implement `skill_disable()` / `skill_enable()`.
5. Implement `pack_list()`.
6. Implement `pack_update_all()`.
7. Implement `pack_copy_to_providers()` / `pack_remove_from_providers()`.
8. Add main dispatch logic (Section 3.13).
9. Update `--help` output (Section 5.3).
10. Replace `git clone` fallback with `curl` + `tar` for remote execution.
