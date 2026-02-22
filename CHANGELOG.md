# Changelog

All notable changes to AFX will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
