---
afx: true
type: SPEC
status: Living
owner: "@rix"
priority: High
version: 2.0
created: "2026-02-26"
last_verified: "2026-03-01"
tags: [vscode-extension, product]
---

# AFX VSCode Extension - Product Specification

**Version:** 2.0
**Date:** 2026-03-01
**Status:** Living
**Author:** Richard Sentino

## References

- **ADR**: [ADR-0002 - Product Direction: VSCode Extension](../../adr/ADR-0002-product-direction-vscode-extension.md)
- **Research**: [AFX Research](../../research/afx-research.md)

---

## Problem Statement

AFX specs live as raw markdown files scattered across `docs/specs/`, `docs/adr/`, and feature directories. There's no unified view of what exists, what status things are in, or what's actively being worked on. You have to open individual files to see frontmatter metadata like status, owner, or priority.

This makes it hard for anyone — PM, architect, CTO, dev, or AI orchestrator — to get a quick read on project state.

---

## User Stories

### Primary Users

Anyone working on an AFX project: developers, product managers, architects, CTOs, and AI orchestrators.

### Stories

**As a** project stakeholder
**I want** a sidebar showing all feature specs and ADRs grouped by category with their frontmatter metadata
**So that** I can see the full project landscape at a glance

**As a** developer
**I want** to filter the tree by status (Draft, In Progress, Approved)
**So that** I can focus on what's active without visual noise

**As a** product manager
**I want** to see task completion counts and in-progress work inline in the tree
**So that** I know where things stand without opening each file

**As a** user
**I want** to click any item to open it in VSCode's preview mode
**So that** I can read specs quickly and edit them with the standard editor when needed

**As a** developer
**I want** to browse, install, enable/disable, and update AFX packs from a Toolbox view
**So that** I can manage my project's skills and agent capabilities without leaving the editor

---

## Requirements

| ID    | Requirement                                                                          | Priority  |
| ----- | ------------------------------------------------------------------------------------ | --------- |
| FR-1  | Read `.afx.yaml` to discover features, ADR paths, and spec paths                     | Must Have |
| FR-2  | Parse YAML frontmatter from AFX-compliant spec documents (type, status, owner, tags) | Must Have |
| FR-3  | Split-pane sidebar with 5 views: Project, Specs, Library, Toolbox, Help              | Must Have |
| FR-4  | Show frontmatter metadata inline (status badge, owner) on each tree item             | Must Have |
| FR-5  | Show task completion counts inline for features (e.g., "5/12")                       | Must Have |
| FR-6  | Filter by composite status (Draft, In Progress, Approved, Living, Stable, Complete)  | Must Have |
| FR-7  | Click any item to open the file in VSCode preview mode                               | Must Have |
| FR-8  | Auto-refresh tree on file changes (debounced at 500ms)                               | Must Have |
| FR-9  | Read-only — no write operations, no custom editors                                   | Must Have |
| FR-10 | Discover and display non-AFX context files (PDF, CSV, etc.) from `.afx.yaml`         | Must Have |
| FR-11 | Show project summary stats in the panel header (features, tasks, ADRs)               | Must Have |
| FR-12 | Project view — session context with current folder, recent folders, config summary, `.afx/` browser | Must Have |
| FR-13 | Library view — composite of ADRs, library directories, and tags from frontmatter     | Must Have |
| FR-14 | Toolbox view — pack management with overview, installed/available packs, upstream tracking, skills disk mirror | Must Have |
| FR-15 | Help view — repository links, documentation, update commands, issue reporting        | Must Have |
| FR-16 | Copy `@see` reference command — clipboard copy of traceability link for any spec item | Must Have |
| FR-17 | Search command — unified search across features, phases, discussions, ADRs            | Must Have |
| FR-18 | Folder management — open folder picker, recent folders list, switch between projects  | Must Have |
| FR-19 | Install/Update AFX — one-click `install.sh` bootstrap and update via terminal         | Must Have |
| FR-20 | Status bar — feature/task stats display, clickable to focus Specs view                | Must Have |
| FR-21 | File decoration provider — badge decorations by feature status                        | Must Have |
| FR-22 | Markdown preview — open preview, preview to side, and edit commands on all spec files | Must Have |
| FR-23 | Config validation — inline warnings for missing directories, duplicate features, missing spec files | Must Have |
| NFR-1 | Only activates in projects with `.afx.yaml`                                          | Must Have |
| NFR-2 | Tree renders in < 500ms for a typical project (≤ 20 features)                        | Must Have |
| NFR-3 | VSCode 1.93+ compatibility                                                           | Must Have |

---

## Acceptance Criteria

### Tree View

- [ ] Custom viewContainer in the activity bar with AFX icon
- [ ] Five separate views (split panes): Project, Specs, Library, Toolbox, Help
- [ ] Each pane is independently collapsible, resizable, and reorderable
- [ ] Specs pane: expandable features with spec.md, design.md, tasks.md, journal.md children
- [ ] Each item shows frontmatter metadata inline: status badge, owner
- [ ] Features show task completion count (e.g., "5/12")
- [ ] Active/in-progress items are visually distinct
- [ ] Specs pane header shows summary stats via `description` (e.g., "3 features · 29/98")

### Project View

- [ ] Current folder display with reveal-in-explorer and open-in-terminal actions
- [ ] Recent folders list with switch and remove actions
- [ ] Config summary: expandable `.afx.yaml` showing entries and inline validation warnings
- [ ] `.afx/` directory browser for local AFX configuration files

### Library View

- [ ] ADRs section: lists all Architecture Decision Records with frontmatter metadata
- [ ] Library directories: browsable tree of directories declared in `.afx.yaml` `library:`
- [ ] Tags section: aggregated tags from all spec frontmatter, grouped by tag

### Toolbox View

- [ ] Overview section: pack count and status summary
- [ ] Installed packs: list with enable/disable/update/remove actions per pack
- [ ] Available packs: fetched from upstream index with one-click install
- [ ] Upstream tracking: refresh upstream provider to check for new packs
- [ ] Skills disk mirror: browse, rename, and delete skill files on disk

### Help View

- [ ] Repository links (GitHub README, releases)
- [ ] Documentation links
- [ ] Update commands (check for updates, update AFX)
- [ ] Issue reporting link

### Status Bar and Decorations

- [ ] Status bar item showing feature/task stats (e.g., "AFX: 3 features · 29/98")
- [ ] Status bar click focuses the Specs view
- [ ] File decoration provider adds badges by feature status

### Config Validation

- [ ] Warns when configured `paths.specs` directory is missing
- [ ] Warns when configured `paths.adr` directory is missing
- [ ] Warns on duplicate feature names
- [ ] Warns when a feature directory is missing
- [ ] Warns when a feature is missing `spec.md`

### Filtering

- [ ] Filter by status (Draft, In Progress, Approved, etc.)
- [ ] Filter persists within the session

### Navigation

- [ ] Single-click opens file in VSCode preview mode
- [ ] Clicking a phase or discussion opens the parent file scrolled to that heading
- [ ] Double-click opens in edit mode (standard VSCode behavior)
- [ ] Preview command opens markdown preview
- [ ] Preview to Side command opens markdown preview in a split pane
- [ ] Edit command opens file in text editor
- [ ] Reveal in Explorer command shows file in the VSCode file explorer
- [ ] Open in Terminal command opens terminal at folder path
- [ ] Copy `@see` Reference command copies traceability link to clipboard
- [ ] Search command provides unified search across features, phases, discussions, and ADRs
- [ ] Open Folder command launches folder picker to load a new AFX project
- [ ] Switch Folder command switches between recent folders

### Refresh

- [ ] Tree refreshes when any spec or config file changes on disk
- [ ] Debounced at 500ms
- [ ] Toolbox watchers refresh packs and skills on disk changes

### Install and Update

- [ ] Install AFX command runs `install.sh` in a terminal for the workspace folder
- [ ] Update AFX command runs `install.sh --update` using version from `.afx.yaml`
- [ ] Welcome content in views shows Install AFX and Open Folder buttons when no config loaded
- [ ] File watcher detects `.afx.yaml` creation after install and auto-loads the project

---

## Non-Goals (Out of Scope)

- Custom editors or forms — editing is VSCode's native markdown editor
- Write operations — this is a read-only viewer
- AI agent execution
- WebView dashboards, charts, or visualizations
- GitHub integration
- Real-time collaboration

---

## Open Questions

| #   | Question                                         | Status   | Resolution                                                       |
| --- | ------------------------------------------------ | -------- | ---------------------------------------------------------------- |
| 1   | Separate repo or subdirectory in this repo?      | Resolved | Separate repo: `vscode-afx` (follows `vscode-{name}` convention) |
| 2   | Marketplace publish or VSIX distribution for v1? | Open     | Currently VSIX only; marketplace publish TBD                     |

---

## Appendix

See [design.md](./design.md) for architecture, mockups, and technical details.
