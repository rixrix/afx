# Changelog

All notable changes to AFX will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [SUNSET] - 2026-05-03

This repository (`rixrix/afx`) is archived. AgenticFlowX is now a dedicated VSCode extension distributed from <https://agenticflowx.github.io/>; the standalone skill workflow continues at <https://github.com/agenticFlowX/afx>. README and `afx-cli` redirect to the canonical locations; older versions in this changelog refer to URLs and release artifacts that are no longer maintained.

## [2.5.1] - 2026-04-02

### Changed

- **Context Resolution (all 15 skills)**: Replaced copy-paste IDE-only inference block with environment-aware context resolution — detects CLI vs IDE, names concrete signals (`ide_opened_file`, `ide_selection`), adds CLI fallback path (explicit args → cwd/branch → conversation), and uses skill-specific examples and fallbacks
- **Tier A skills** (`afx-task`, `afx-spec`): Merged new context detection into existing resolution chains instead of duplicating; extracted trailing parameters into standalone sections
- **Tier C skills** (`afx-hello`, `afx-help`): Removed Active File Inference entirely — these are context-agnostic diagnostic/reference commands; kept trailing parameters as keyword filters
- **Suggestion list formatting** (6 skills): De-indented code-block suggestion lists to standard markdown ordered lists
- **Markdown table alignment**: Consistent column widths across all skill files
- **`afx-next` numbering fix**: Corrected duplicate step 3 → sequential steps 4-7
- **`afx-next` glob escape**: Escaped `*` in ADR glob pattern to prevent markdown emphasis

## [2.5.0] - 2026-04-02

### Added

- **`/afx-release` skill** (new): Release workflow — auto-detects semver bump type from commit log, updates `CHANGELOG.md` and `skills.json`, commits, pushes, creates tag, and publishes GitHub release. Supports explicit `patch|minor|major` override.

### Changed

- **`afx-pack-agenticflowx`**: Added `afx-release` to the pack manifest.

### Fixed

- **`afx-cli` `sed -i ''`**: Fixed cross-platform incompatibility on WSL and Git Bash — replaced macOS-only `sed -i ''` with portable `sed -i.bak` + cleanup.
- **`afx-cli` cache cleanup**: Simplified `.afx/.cache/tmp.*` cleanup from two `rm` calls to a single `rm -rf`.
- **Datetime format**: Enforced standard ISO 8601 datetime format across skill outputs.

## [2.4.0] - 2026-04-01

### Added

- **`/afx-adr` skill** (new): ADR management — create, review, list, supersede. Reads canonical template from `assets/adr-template.md`. Replaces the ADR subcommands previously in `/afx-init`.
- **`/afx-scaffold` skill** (new): Thin orchestrator for spec scaffolding — `spec <name>` delegates to `/afx-spec create`, `research <name>` uses `../afx-research/assets/research-template.md`, `adr <title>` delegates to `/afx-adr create`. Replaces `/afx-init`.
- **Skill `assets/` directories**: Templates are now co-located with their owning skill rather than installed separately. `afx-spec`, `afx-design`, `afx-task`, `afx-session`, `afx-research`, `afx-adr` each carry their canonical template in `assets/`.
- **Context Resolution section**: Added to `afx-spec`, `afx-adr`, and `afx-scaffold` skills — explicit inference table for resolving feature name, owner, and paths from branch, recent files, and active spec.
- **Error Handling section**: Added to `afx-research` — covers topic-not-found, existing artifact, ambiguous match, and finalize-without-prior-research.

### Changed

- **`afx-cli` `skill_sync()`**: Changed from cherry-picking `SKILL.md` + `references/` to recursive `cp -r` so `assets/` directories propagate automatically to `.claude/skills/` and `.agents/skills/`.
- **`/afx-spec create`**: Now owns full spec scaffolding (reads templates from own `assets/` and sibling skills). No longer delegates to `/afx-scaffold`.
- **Pack manifest** (`afx-pack-agenticflowx.yaml`): Replaced `afx-init` with `afx-scaffold` + `afx-adr`.

### Removed

- **`/afx-init` skill**: Replaced by `/afx-scaffold` (spec/research/adr scaffolding) and `/afx-adr` (ADR lifecycle).
- **`step_templates()` in `afx-cli`**: Template install step removed — templates now live in skill `assets/` and are synced via `skill_sync()`.
- **Dead config keys**: Removed `paths.sessions`, `ai_attribution`, `test_traceability`, `anchors`, `quality_gates`, `verification`, `require_see_links`, `scan_for_orphans` from `.afx.yaml.template` and all managed `.afx/.afx.yaml` files. Deep audit confirmed none are read by any skill or extension.

## [2.3.0] - 2026-04-01

### Breaking Changes

- **`/afx-work` removed**: All subcommands absorbed into `/afx-task` (plan, pick, code, verify, complete, sync) and `/afx-next` (status).
- **`/afx-dev code` removed**: Moved to `/afx-task code` — daily coding is now task-driven with traceability. `/afx-dev` retains diagnostic commands (debug, refactor, review, test, optimize).
- **`/afx-update` removed**: Replaced by `/afx-hello` for environment diagnostics and installation verification.
- **`/afx-spec design` and `/afx-spec tasks` removed**: Design authoring moved to new `/afx-design` skill; task planning moved to `/afx-task plan`.
- **`@see` annotation policy**: `spec.md` and `design.md` links are now **required**; `tasks.md` links are **optional** (allowed but not enforced). Tasks are transactional history, not living truth.
- **`@see` anchor format**: `#anchor-slug` format replaced by bracket Node IDs: `[FR-1]`, `[DES-API]`, `[NFR-3]`. Multi-ID syntax supported: `@see spec.md [FR-1] [FR-2] [NFR-1]`.
- **Frontmatter field renames**: `created` → `created_at`, `last_verified` → `updated_at`, `version` now quoted as `"1.0"`.

### Added

- **`/afx-design` skill** (new): Owns `design.md` exclusively — author, validate, review, approve. Lifecycle-gated behind spec approval. Enforces `[DES-ID]` Node IDs on all headings.
- **`/afx-hello` skill** (new, agenticflowx pack): Environment diagnostics — AI provider detection, installation check, skill availability, project health snapshot.
- **`/afx-check deps`** subcommand: Build and validate cross-spec dependency graph from `depends_on` frontmatter.
- **`/afx-check coverage`** subcommand: Bidirectional spec-to-code coverage map (Spec→Code + Code→Spec orphan check).
- **`/afx-spec validate` enhanced**: Now checks frontmatter depth (version, timestamps, canonical field order), requirement ID uniqueness/sequencing (`[FR-N]`, `[NFR-N]`), and 8 required template sections. Parity with `/afx-design validate`.
- **Post-Action Checklists**: Added mandatory post-action checklists to `/afx-dev`, `/afx-init`, `/afx-research`, `/afx-session`, `/afx-spec`, `/afx-design`, and `/afx-task` skills.
- **PRD Reference doc** (`docs/agenticflowx/prd-reference.md`): Comprehensive artifact ownership and lifecycle reference.
- **Research template** (`docs/agenticflowx/templates/research-template.md`): Canonical template for research artifacts.

### Changed

- **Artifact ownership model**: Each skill now owns exactly one artifact — `/afx-spec` owns `spec.md`, `/afx-design` owns `design.md`, `/afx-task` owns `tasks.md` + source code, `/afx-session` owns `journal.md`.
- **`/afx-task` expanded**: Absorbed plan, pick, code, verify, complete, sync, brief, review from former `/afx-work` and `/afx-dev code`.
- **`/afx-dev` scoped down**: Now positioned as "advanced diagnostics" — debug, refactor, review, test, optimize. No longer owns `code` subcommand.
- **`/afx-init` simplified**: Removed `template`, `prefix`, `config` subcommands. Now only `feature` and `adr`. Uses Write tool + canonical templates instead of inline bash heredocs.
- **Pack manifest reorganized**: `afx-pack-agenticflowx.yaml` items grouped by lifecycle phase (artifact lifecycle → quality → session → setup). 15 skills (was 13).
- **All command tables and workflow examples** updated across docs, prompts, templates, and skills to reflect new command surface.
- **Multi-agent parity table**: Added `/afx-design`, `/afx-research`, `/afx-hello` rows.
- **Frontmatter standardized** across all templates, specs, and skills to canonical field order and new field names.

### Removed

- **`/afx-work` skill**: Entire SKILL.md deleted (1161 lines). Functionality distributed to `/afx-task` and `/afx-next`.
- **`/afx-update` skill**: Entire SKILL.md deleted (196 lines). Replaced by `/afx-hello`.
- **`docs/specs/afx-update/`**: Entire spec directory deleted (spec, design, tasks, journal).
- **`/afx-spec gaps`** subcommand: Replaced by `/afx-check coverage`.

## [2.2.0] - 2026-03-19

### Added

- **VSCode Workbench tab** (`vscode-afx 2.0.0-alpha.2`): New multi-column editor replacing the old Tasks tab. View spec, design, tasks, and sessions documents side by side with resizable columns, inline editing, and preview modes.
- **Drift detection**: Workbench footer shows document freshness based on `last_verified` frontmatter (green ≤7d, yellow ≤30d, red >30d). Analytics tab includes drift heatmap per feature.
- **Ghost task detection**: Extension scans `tasks.md` for broken `@see` references pointing to non-existent files. New KPI card in Analytics with expandable detail panel.
- **Anchor sync scroll**: Clicking a heading in one workbench column scrolls matching headings in other columns.
- **Workbench state persistence**: Column layout, view modes, and feature selection saved to `.afx/workbench.json` — survives window reloads.
- **Default kanban board**: Auto-creates `backlog.md` with Backlog/In Progress/Review/Done columns when no boards exist.
- **"Open Workbench" sidebar action**: Prominent entry in the Project tree and all sidebar view title bars to reveal the bottom panel.
- **`--verbose` and `--target` flags** for `afx-cli` install script with project-local temp files.

### Changed

- **Tab order**: Reordered to Workbench → Notes → Board → Pipeline → Documents → Analytics → Journal → Architecture → Time Machine.
- **Column toggle pills**: Redesigned with per-column accent colors (spec=pink, design=blue, tasks=amber, sessions=green) and inline status hints.
- **Default columns**: First-time view shows Spec, Design, Tasks (sessions hidden by default).
- **Skill enhancements**: Cross-cutting improvements to journaling, next-command suggestions, execution contracts, and command renames.

### Fixed

- **Stale session references**: Removed dead `session show/search` refs, fixed `work next` → `work pick` in Related Commands.
- **Bash 5.x compatibility**: Use pre-increment to avoid silent exit on Linux/WSL.
- **Install docs**: Fixed `install all docs from docs/agenticflowx/` path resolution.
- **BSD sed compatibility**: Improved cross-platform script support.

## [2.1.0] - 2026-03-15

### Added

- **VSCode Extension VSIX**: Extension artifact (`vscode-afx-2.0.0-alpha.1.vsix`) now available as a GitHub release asset. Install via one-liner curl command or VS Code UI.

### Changed

- **README**: Added INSTALL section to the news table with download + install instructions. Added macOS/WSL tested notice.

## [2.0.1] - 2026-03-15

### Fixed

- **Agent selection prompt**: Install and update now always prompt for agent selection unless `--yes` or explicit flags (`--no-claude-md`, `--no-agents-md`, `--with-gemini-md`) are provided. Previously, `--update` silently reused saved config without prompting.
- **BSD sed compatibility**: Rewrote `update_agent_config()` to use awk instead of multiline `sed` insert, fixing failures on macOS (BSD sed).
- **`.claude` directory tracking**: Added `.claude` to `.gitignore` exclusions so skill assets are properly tracked.

## [2.0.0] - 2026-03-15

### Breaking Changes

- **Script renamed**: `install.sh` → `afx-cli`
- **Skill targets**: Two targets replace the old 5-provider model:
  - `.claude/skills/` — Claude Code
  - `.agents/skills/` — Codex, Copilot, Antigravity
- **Canonical skill store**: `.afx/skills/{category}/{name}/` replaces `.afx/packs/{pack}/{provider}/skills/`
- **Removed flags**: `--commands-only`, `--no-copilot-md`, `--pack-enable`, `--pack-disable`
- **New flags**: `--skills-only`, `--with-gemini-md`, `--yes`
- **GEMINI.md**: Changed from opt-out to opt-in (`--with-gemini-md`)
- **copilot-instructions.md**: Removed — Copilot now reads AGENTS.md

### Added

- **Interactive Agent Selection**: Install and update now prompt users to select which AI agents they use (Claude Code, Codex/Copilot/Antigravity, Gemini CLI). Skills and context files are only created for selected agents.

### Changed

- **Dual skill sync**: `skill_sync()` conditionally syncs to both `.claude/skills/` and `.agents/skills/` based on user selection.
- **Documentation**: Updated all references to reflect new skill targets and agent selection model.
- **Removed `prompts/copilot.md`**: Copilot now shares AGENTS.md, separate snippet file deleted.

## [1.7.0] - 2026-03-14

### Added

- **Starter Pack** (`afx-pack-starter`): New utility pack with `afx-hello` skill for verifying AFX installation and multi-provider routing across Claude, Codex, Antigravity, and Copilot.
- **Provider Selection for Packs**: Pack install now always prompts users to select their AI coding tools, ensuring skills are only installed for providers the user actually uses.
- **Local Manifest Fallback**: `fetch_manifest()` prefers local pack manifests when running from the AFX repo, enabling dev/testing without pushing to GitHub first.
- **QA Pack**: Added `webapp-testing` skill from `anthropics/skills` (Playwright-based web app testing toolkit).

### Fixed

- **Bash 3.x Compatibility**: Replaced `${var^^}` uppercase syntax (bash 4+) with `case` mapping for macOS compatibility in `route_item()`.
- **Provider-Gated Routing**: `route_item()` and `pack_copy_to_providers()` now respect user's provider selection (`INSTALL_*` flags) alongside manifest platform support.

### Changed

- **Pack Manifests Updated**: Removed dead upstream references (`anthropics/antigravity-awesome-skills` repo renamed to `anthropics/skills`), fixed `security-scanner` → `security-guidance` in security pack.
- **Pack Index** (`packs/index.json`): Updated upstream registry with current repo names and featured skills from `anthropics/claude-code`, `anthropics/claude-plugins-official`, `anthropics/skills`, and `openai/skills`.
- **AFX Skills**: Added `@afx:provider-commands` integration section to existing AFX-built skills.

## [1.6.0] - 2026-03-13

### Added

- **Pack System**: Curated skill pack management for distributing bundles of AI skills across providers.
  - Pack manifests (`packs/afx-pack-qa.yaml`, `packs/afx-pack-security.yaml`) with provider-aware skill mapping.
  - Pack index (`packs/index.json`) for remote discovery and version checking.
  - New `install.sh` options: `--pack`, `--update-packs`, `--reset`, `--disable-pack`, `--enable-pack`, `--remove-pack`, `--skill-enable`, `--skill-disable`, `--branch`, `--version`.
- **New AFX-Built Skills**: `afx-qa-methodology`, `afx-security-audit`, `afx-owasp-top-10`, `afx-spec-test-planning`.
- **Antigravity Provider Support**: `.agent/skills/` directory with 15 AFX Antigravity skills.
- **Pack Spec Documentation**: Full spec, design, tasks, and journal at `docs/specs/afx-packs/`.

### Changed

- **Gemini Commands**: Converted all `.gemini/commands/*.md` to TOML format (`.toml`) for Gemini CLI compatibility.
- Updated `.claude/commands/` and `.codex/skills/` with pack-aware references.
- Updated `CLAUDE.md`, `README.md`, and spec templates with pack system documentation.
- Refactored `install.sh` with modular sections for constants, defaults, argument parsing, provider detection, and pack resolution.

## [1.5.3] - 2026-02-27

### Changed

- Renamed `.afx.yaml` config key `context:` → `library:` to align with VS Code extension Library view.
- Updated `.afx.yaml.template` with cleaner defaults (`features: []`, commented-out examples).
- Updated `docs/agenticflowx/agenticflowx.md` config example to use `library:` key.

### Added

- `install.sh` now creates `docs/research/` directory during project scaffolding.

## [1.5.2] - 2026-02-26

### Chore

- Simplified co-author trailers to plain names with unresolvable noreply emails (avoids GitHub "private" contributor artifacts from bot account emails).
  - Codex: `codex <noreply@openai.com>`
  - Copilot: `copilot <noreply@github.com>`
- Removed duplicate `[bot]` noreply lines from `GEMINI.md` and `prompts/gemini.md`.

## [1.5.1] - 2026-02-26

### Chore

- Corrected co-author bot emails for Codex and Copilot to use verified GitHub bot noreply addresses.
  - Codex: `openai-codex[bot] <215057067+openai-codex[bot]@users.noreply.github.com>`
  - Copilot: `copilot[bot] <167198135+copilot[bot]@users.noreply.github.com>`
- Updated `CLAUDE.md` Git Attribution section to list all four agent co-author trailers.
- Fixed `prompts/copilot.md` snippet with correct bot email.

## [1.5.0] - 2026-02-26

### Added

- feat(copilot): add GitHub Copilot support (6bc6910)
- feat(install): add GEMINI.md managed snippet integration (7609ee4)

## [1.4.0] - 2026-02-26

### Added

- **Gemini CLI Support**: First-class support for Gemini CLI via proxy commands in `.gemini/commands/`.
- **ADR Command Awareness**: Global ADRs are now surfaced in `/afx-next`, `/afx-context`, and `/afx-discover`.
- **Multi-Agent Documentation**: Consolidated agent parity guides into `docs/agenticflowx/multi-agent.md`.

### Changed

- Updated `install.sh` to support Gemini CLI asset deployment.
- Updated `AGENTS.md` and `prompts/agents.md` with multi-agent instructions.
- Renamed `docs/agenticflowx/codex.md` to `docs/agenticflowx/multi-agent.md`.

## [1.3.1] - 2026-02-25

### Chore

- Standardized git commit attribution guidelines across documentation for:
  - Gemini: `gemini-code-assist <noreply@gemini.google.com>`
  - Claude: `claude <noreply@anthropic.com>`
  - Codex: `code <noreply@openai.com>`

## [1.3.0] - 2026-02-25

### Added

- New AFX framework maintenance command `/afx-update` with:
  - `check` subcommand to compare local AFX version against upstream release.
  - `apply` subcommand to execute installer update flow (`--update`) with pass-through safety flags.
- New Codex skill parity for updates:
  - `.codex/skills/afx-update/SKILL.md`
  - `.codex/skills/afx-update/agents/openai.yaml`
- New spec package for this feature at `docs/specs/afx-update/` (`spec.md`, `design.md`, `tasks.md`, `journal.md`).

### Changed

- Updated command/discovery surfaces to include `update` workflow:
  - `.claude/commands/afx-help.md`
  - `docs/agenticflowx/codex.md`
  - `README.md`
  - `CLAUDE.md`
  - `AGENTS.md`
  - `prompts/agents.md`
  - `docs/_index.md`
  - `docs/agenticflowx/agenticflowx.md`

### Fixed

- Corrected `/afx-update check` behavior when local marker is `AFX Version: Unknown` to return `Status: UNKNOWN` instead of `LOCAL AHEAD`.

## [1.2.0] - 2026-02-25

### Added

- First-class **Codex skill support** with versioned skills at `.codex/skills/afx-*` for all AFX command families.
- OpenAI skill metadata manifests at `.codex/skills/afx-*/agents/openai.yaml`.
- New `AGENTS.md` guidance for Codex and compatible coding agents.
- New Codex snippet source at `prompts/agents.md`.
- New Codex command reference at `docs/agenticflowx/codex.md`.
- `install.sh` support for Codex installation:
  - Installs/updates `.codex/skills/afx-*`.
  - Manages a bounded AFX Codex block in `AGENTS.md`.
  - Adds `--no-agents-md` option.

### Changed

- Updated documentation and framework references to position AFX as supporting both Claude Code and Codex:
  - `README.md`
  - `CLAUDE.md`
  - `docs/_index.md`
  - `docs/agenticflowx/agenticflowx.md`
- Expanded `--commands-only` behavior in `install.sh` to include both `.claude` and `.codex` command assets.
- Aligned command specs to current spec file expectations (`spec.md`, `tasks.md`, `journal.md`) instead of legacy `readme.md` references where applicable.

### Removed

- Removed obsolete `examples/minimal-project/docs/specs/example-feature/readme.md`.

## [1.1.0] - 2026-02-24

### Added

- **Global Architecture Decision Records (ADRs)** — First-class `docs/adr/` support for project-wide architectural decisions not tied to individual feature specs.
  - New `/afx-init adr <title>` subcommand generates real ADR content (not placeholder templates) with auto-increment numbering (`ADR-NNNN-kebab-slug.md`).
  - `install.sh` now creates `docs/adr/` directory in target projects.
  - `.afx.yaml.template` includes new `paths.adr` configuration field.
- **AFX Dogfooding** — AFX now manages its own development using the spec-driven workflow. Added `.afx.yaml` config and full feature spec at `docs/specs/global-adr/`.
- Created `ADR-0001-global-adr-directory.md` — the self-referential first ADR documenting the decision to adopt `docs/adr/`.
- Dedicated **Architecture Decision Records** section in `README.md` with lifecycle diagram, global vs feature-local distinction, and AI agent context.

### Changed

- Updated all documentation surfaces to reflect ADR support:
  - `docs/agenticflowx/agenticflowx.md` — Document Types table, directory structure, config, research standards, CLI tables.
  - `docs/agenticflowx/cheatsheet.md` — Phase 1 table, file layout.
  - `CLAUDE.md` — Repository structure, command descriptions.
  - `prompts/complete.md`, `prompts/workflow-commands.md`, `prompts/yaml-frontmatter.md` — CLAUDE.md snippets for target project installation.
- `/afx-init` command now supports both `feature` and `adr` subcommands.

## [1.0.8] - 2026-02-22

### Fixed

- Updated `install.sh` to dynamically fetch the latest release version directly from `CHANGELOG.md` to prevent outdated version displays during updates.
- Corrected the chronological order in `CHANGELOG.md` by moving `v1.0.0` to the bottom of the list.

## [1.0.7] - 2026-02-22

### Added

- Added a new **How to create your first specs** (Bootstrapping) step-by-step tutorial to `README.md`. It teaches users how to scaffold an entire feature from scratch by having Claude act as a PM. This uses a simple plain HTML SaaS Landing Page example.

### Removed

- Removed the separate `prompts/bootstrap.md` file since the prompt is now fully embedded directly into `README.md` for easier access without jumping between files.

## [1.0.6] - 2026-02-22

### Added

- Inserted a definitive **Global vs Local Context** section in `README.md` and `docs/agenticflowx/agenticflowx.md` to explicitly define how `CLAUDE.md` houses system-wide design tokens (Global Brain), whereas `docs/specs/*/design.md` defines specific component layouts (Feature Brain). Added Mermaid diagrams to visually map this relationship.
- Added a dedicated **User Interface & UX** section to both `templates/design.md` files so new feature scaffolding properly captures visual requirements.
- Implemented a new core rule inside `prompts/complete.md` enforcing agents to ingest the global UI parameters from `CLAUDE.md` before composing local `/afx-init` specifications.

## [1.0.5] - 2026-02-22

### Fixed

- Resolved mangled markdown strings in `.claude/commands/afx-context.md` caused by previous bad line replacements during the `prepare`-to-`save` rename.
- Replaced the deprecated `type: HANDOFF` and `prepared:` keys from the output context template with `type: CONTEXT` and `saved:`.

## [1.0.4] - 2026-02-22

### Changed

- Transitioned the YAML frontmatter `@handle` dummy string from double quotes to single quotes to align with standard style preferences in generated defaults.

## [1.0.3] - 2026-02-22

### Fixed

- Fixed a bug in `install.sh` where updating `CLAUDE.md` failed with an `awk: newline in string` error due to multi-line evaluation limits. The script now employs a robust file-slicing method.

## [1.0.2] - 2026-02-22

### Fixed

- Abstracted the hardcoded repository path out of `install.sh` and corrected outdated payload endpoints in `README.md` to properly point at `rixrix/afx.git`.

## [1.0.1] - 2026-02-22

### Added

- Industry-standard template for Architectural Decision Records (`templates/adr.md`).
- Concrete example ADR in `examples/minimal-project`.

### Changed

- Comprehensively updated `README.md` to be less verbose, and highlight the `research/` directory.
- Renamed the agent `/afx-handoff` command to `/afx-context` for better terminology alignment.
- Renamed context subcommands from `prepare/resume` to `save/load`.
- Updated data retention logic in `/afx-context load` to preserve the context file during load operations rather than immediately clearing it, protecting against accidental window closes.
- Unified and scrubbed legacy `(formerly X)` historical command references from living documentation.

### Removed

- Deleted the obsolete `templates/readme.md` file.
- Stripped all `changelog` sections out of individual `.claude/commands/*.md` documents in favor of this single root CHANGELOG.md.
- Removed Obsidian-specific Dataview queries from the `yaml-frontmatter.md` prompt to remain tool-agnostic.

### Fixed

- Re-formatted broken markdown codeblocks and syntax wrappers inside `prompts/yaml-frontmatter.md`.
- Corrected linguistic overlaps in documentation (e.g., "Context to another developer") generated during the handoff terminology rename.

## [1.0.0] - 2025-02-01

### Added

- Initial open source release
- 10 AFX slash commands for Claude Code
- Complete documentation (manual, guide, cheatsheet)
- 5 spec templates (spec, design, tasks, journal, readme)
- CLAUDE.md integration snippets
- Example project structure
- Configuration template (.afx.yaml.template)

### Commands Included

- `/afx-next` - Context-aware guidance
- `/afx-work` - Workflow orchestration
- `/afx-dev` - Development with traceability
- `/afx-check` - Quality gates
- `/afx-task` - Task verification
- `/afx-session` - Discussion capture
- `/afx-report` - Traceability metrics
- `/afx-init` - Feature scaffolding
- `/afx-handoff` - Agent session handoff
- `/afx-help` - Command reference

## [Unreleased]

### Planned

- VSCode extension for AFX
- GitHub Actions integration
- Additional templates
