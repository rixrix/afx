# GEMINI.md - Project Context

## Project Overview

**AFX (AgenticFlowX)** is a spec-driven development framework designed to keep AI coding agents (like Claude Code and Codex) on track. It prevents context loss, scope creep, and orphaned code by maintaining bidirectional traceability between specifications and implementation.

- **Main Technologies:** Bash (Installer/Init), Markdown (Specifications, Commands, Documentation), JSDoc/Annotations (`@see` links).
- **Architecture:** A decentralized four-file structure for every feature (`spec.md`, `design.md`, `tasks.md`, `journal.md`), global Architecture Decision Records (ADRs), and a set of custom slash commands for AI agents.
- **Key Files:**
  - `afx-cli`: The primary installer and updater for the framework.
  - `skills/`: Standard-compliant skills (SKILL.md format with 4-field frontmatter).
  - `packs/`: Pack manifests grouping skills into installable packs.
  - `skills.json`: Pack catalog and version info.
  - `templates/`: Base templates for features and ADRs.
  - `.afx.yaml.template`: Configuration schema for projects using AFX.

## Building and Running

Since AFX is primarily a framework of documentation and instructions, there is no "build" step in the traditional sense.

- **Installation/Update:**
  ```bash
  ./afx-cli /path/to/target-project      # Install to a project
  ./afx-cli --update /path/to/target-project  # Update an existing installation
  ```
- **Development/Testing:**
  - To test changes to skills, install them to a test project via `./afx-cli` and verify they are discovered correctly.
- **Validation:**
  - AFX commands are self-validating through `/afx-check` subcommands (e.g., `/afx-check links`, `/afx-check lint`).

## Development Conventions

- **Spec-Driven Development (SDD):** Always write or update the specification (`spec.md` and `design.md`) before implementation.
- **Bidirectional Traceability:**
  - Every function or significant code block MUST include an `@see` annotation linking back to the relevant section in the specification or task.
  - Example: `/** @see docs/specs/auth/design.md#2.1-token-generation */`
- **Quality Gates:** Implementation is not complete until both `[Agent OK]` and `[Human OK]` markers are present in `tasks.md` and `/afx-check path` has verified the execution flow.
- **State vs. Event Separation:**
  - `spec.md` and `design.md` reflect the **current factual state**.
  - `journal.md` and `tasks.md` record **events and history**.
- **Skill Structure:** All skills follow the Agent Skills standard (SKILL.md with `name`, `description`, `license`, `metadata` frontmatter).

## Gemini-Specific Guidance

- **Skill Discovery:** Skills are installed to provider target directories. Gemini is not a current provider target — Gemini users should read skills directly from `skills/`.
- **Specialized Tools:**
  - Use `codebase_investigator` for high-level architectural analysis or mapping complex dependencies during `/afx-next` or `/afx-discover`.
  - Use `grep_search` and `read_file` for precise context scanning within specs and journals.
  - Follow the "Smart Init Protocol" in `/afx-init` by leveraging these tools for pre-scaffold analysis.

## Git Commit Attribution

When committing to this repository, append the following co-author trailer to every commit message:

```
Co-authored-by: gemini-code-assist <noreply@gemini.google.com>
Co-authored-by: gemini-code-assist[bot] <176961590+gemini-code-assist[bot]@users.noreply.github.com>
```
