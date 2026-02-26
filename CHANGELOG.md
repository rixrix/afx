# Changelog

All notable changes to AFX will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **ADR Command Awareness**: Global ADRs are now surfaced in `/afx:next`, `/afx:context`, and `/afx:discover`.
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

- New AFX framework maintenance command `/afx:update` with:
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

- Corrected `/afx:update check` behavior when local marker is `AFX Version: Unknown` to return `Status: UNKNOWN` instead of `LOCAL AHEAD`.

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
  - New `/afx:init adr <title>` subcommand generates real ADR content (not placeholder templates) with auto-increment numbering (`ADR-NNNN-kebab-slug.md`).
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
- `/afx:init` command now supports both `feature` and `adr` subcommands.

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
- Implemented a new core rule inside `prompts/complete.md` enforcing agents to ingest the global UI parameters from `CLAUDE.md` before composing local `/afx:init` specifications.

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
- Renamed the agent `/afx:handoff` command to `/afx:context` for better terminology alignment.
- Renamed context subcommands from `prepare/resume` to `save/load`.
- Updated data retention logic in `/afx:context load` to preserve the context file during load operations rather than immediately clearing it, protecting against accidental window closes.
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

- `/afx:next` - Context-aware guidance
- `/afx:work` - Workflow orchestration
- `/afx:dev` - Development with traceability
- `/afx:check` - Quality gates
- `/afx:task` - Task verification
- `/afx:session` - Discussion capture
- `/afx:report` - Traceability metrics
- `/afx:init` - Feature scaffolding
- `/afx:handoff` - Agent session handoff
- `/afx:help` - Command reference

## [Unreleased]

### Planned

- VSCode extension for AFX
- GitHub Actions integration
- Additional templates
