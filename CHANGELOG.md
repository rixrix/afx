# Changelog

All notable changes to AFX will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

## [1.0.4] - 2026-02-22

### Changed

- Transitioned the YAML frontmatter `@handle` dummy string from double quotes to single quotes to align with standard style preferences in generated defaults.

## [1.0.3] - 2026-02-22

### Fixed

- Fixed a bug in `install.sh` where updating `CLAUDE.md` failed with an `awk: newline in string` error due to multi-line evaluation limits. The script now employs a robust file-slicing method.

## [1.0.2] - 2026-02-22

### Fixed

- Abstracted the hardcoded repository path out of `install.sh` and corrected outdated payload endpoints in `README.md` to properly point at `rixrix/afx.git`.

## [Unreleased]

### Planned

- VSCode extension for AFX
- GitHub Actions integration
- Additional templates
