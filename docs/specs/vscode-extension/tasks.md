---
afx: true
type: TASKS
status: Living
owner: "@rix"
version: 1.0
created: "2026-02-26"
last_verified: "2026-02-26"
tags: [vscode-extension, product]
---

# AFX VSCode Extension - Implementation Tasks

**Version:** 1.0
**Date:** 2026-02-26
**Status:** Draft
**Spec:** [spec.md](./spec.md)
**Design:** [design.md](./design.md)

---

## Task Numbering Convention

- **0.x** - Project scaffolding
- **1.x** - Config and parsers
- **2.x** - Models and feature builder
- **3.x** - Sidebar tree views
- **4.x** - File watchers
- **5.x** - Commands and filter
- **6.x** - Polish and packaging
- **7.x** - Spec and design alignment (reconcile docs with evolved architecture)

References:

- `[FR-N]` = Functional Requirement N from spec.md
- `[NFR-N]` = Non-Functional Requirement N from spec.md
- `[AC-X]` = Acceptance Criteria section X from spec.md
- `[DESIGN-X]` = Section X from design.md

---

## Phase 0: Project Scaffolding

> Ref: [NFR-1], [NFR-3], [DESIGN-File Structure]

### 0.1 Repository Setup

> File: `package.json`, `tsconfig.json`

- [x] Initialize `vscode-afx` repo with `package.json` (name, publisher, engines `^1.85.0`, activation event `workspaceContains:.afx.yaml`)
- [x] Configure `tsconfig.json` (strict mode, ES2022 target, Node module resolution)
- [ ] Add ESLint config for TypeScript
- [x] Add `.vscodeignore` and `.gitignore`

### 0.2 Extension Manifest

> File: `package.json`

- [x] Register `viewContainers.activitybar` with id `afx`, title `AFX`, icon `resources/afx.svg` [FR-3]
- [x] Register four views under `afx`: `afx.config`, `afx.context`, `afx.adrs`, `afx.features` [FR-3]
- [x] Register commands: `afx.refresh`, `afx.openConfig`, `afx.filterByStatus`, `afx.collapseAll` [DESIGN-Commands]
- [x] Add `when` clauses and view/title menu bindings for commands [DESIGN-Commands]

### 0.3 Extension Entry Point

> File: `src/extension.ts`

- [x] Create `activate()` skeleton — log activation to output channel, return disposables
- [x] Create `deactivate()` cleanup function
- [x] Create activity bar icon `resources/afx.svg` [AC-Tree View]

### 0.4 Logger Utility

> File: `src/utils/logger.ts`

- [x] Implement output channel wrapper ("AFX" output channel) with `info`, `warn`, `error` methods [DESIGN-Error Handling]

---

## Phase 1: Config and Parsers

> Ref: [FR-1], [FR-2], [FR-10], [DESIGN-Configuration Source], [DESIGN-Parsing Logic]

### 1.1 Config Parser

> File: `src/config/afxConfigParser.ts`

- [x] Read `.afx.yaml` from workspace root using `yaml` package [FR-1]
- [x] Normalize snake_case YAML keys to camelCase TypeScript fields [DESIGN-Data Model]
- [x] Validate required fields: `version`, `paths.specs`, `paths.adr`, `features` [DESIGN-Configuration Source]
- [x] Return typed `AfxConfig` object (match interface from design.md) [DESIGN-Data Model]
- [x] Handle missing `.afx.yaml` — return `undefined` (caller shows welcome view) [DESIGN-Error Handling]
- [x] Handle malformed YAML — show error notification, return `undefined` [DESIGN-Error Handling]

### 1.2 Frontmatter Parser

> File: `src/parsers/frontmatterParser.ts`

- [x] Extract YAML frontmatter using `gray-matter` package [FR-2]
- [x] Parse `afx`, `type`, `status`, `owner`, `tags`, `version` fields [FR-2]
- [x] Handle missing or malformed frontmatter — log warning, return defaults [DESIGN-Error Handling]

### 1.3 Task Parser

> File: `src/parsers/taskParser.ts`

- [x] Extract phases from `## Phase N: Name` headings [DESIGN-Parsing Logic]
- [x] Count checkboxes per phase: `- [ ]` (incomplete) and `- [x]` (complete) [FR-5]
- [x] Return `TaskStats` with total, completed, and per-phase breakdowns [DESIGN-Data Model]
- [x] Handle empty or missing `tasks.md` — return zero counts [DESIGN-Error Handling]

### 1.4 Journal Parser

> File: `src/parsers/journalParser.ts`

- [x] Extract discussions matching `### PREFIX-DNNN - date - title` pattern [DESIGN-Parsing Logic]
- [x] Parse discussion status: active, blocked, closed [DESIGN-Data Model]
- [x] Handle empty or missing `journal.md` — return empty array [DESIGN-Error Handling]

### 1.5 Spec Document Parser

> File: `src/parsers/specDocumentParser.ts`

- [x] Orchestrate frontmatter + type-specific parsing (task parser for TASKS, journal parser for JOURNAL) [DESIGN-Parsing Logic]
- [x] Return unified `SpecDocument` model for any spec file type [DESIGN-Data Model]

### 1.6 Unit Tests: Parsers

> File: `src/test/parsers/`

- [ ] Config parser: valid YAML, missing fields, malformed YAML [DESIGN-Testing Strategy]
- [ ] Frontmatter parser: valid, missing, malformed frontmatter [DESIGN-Testing Strategy]
- [ ] Task parser: checkbox counting, phase extraction, empty files [DESIGN-Testing Strategy]
- [ ] Journal parser: discussion ID extraction, status parsing [DESIGN-Testing Strategy]

---

## Phase 2: Models and Feature Builder

> Ref: [FR-4], [FR-5], [FR-11], [DESIGN-Data Model], [DESIGN-Feature Status Derivation]

### 2.1 TypeScript Interfaces

> File: `src/models/afxConfig.ts`, `src/models/specDocument.ts`, `src/models/feature.ts`

- [x] Define `AfxConfig` interface (paths, features, prefixes, context, qualityGates, verification, etc.) [DESIGN-Data Model]
- [x] Define `SpecDocument`, `TaskStats`, `Phase`, `Discussion` interfaces [DESIGN-Data Model]
- [x] Define `Feature` interface with derived status type union [DESIGN-Data Model]

### 2.2 Feature Builder

> File: `src/models/feature.ts`

- [x] Scan feature directory for spec.md, design.md, tasks.md, journal.md [FR-1]
- [x] Parse each found document via `specDocumentParser` [FR-2]
- [x] Aggregate task stats and discussions into `Feature` model [FR-5]
- [x] Derive feature status from task progress (Not Started / In Progress / Complete) or frontmatter (Draft / Approved / Living / Stable) [DESIGN-Feature Status Derivation]
- [x] Compute project-level summary stats (total features, total tasks completed/total) [FR-11]

### 2.3 Unit Tests: Feature Builder

> File: `src/test/models/`

- [ ] Feature builder: aggregation from parsed documents, status derivation logic [DESIGN-Testing Strategy]

---

## Phase 3: Sidebar Tree Views

> Ref: [FR-3], [FR-4], [FR-5], [FR-7], [FR-10], [FR-11], [AC-Tree View], [AC-Navigation], [DESIGN-Split-Pane Sidebar], [DESIGN-TreeItem Rendering]

### 3.1 TreeItem Subclasses

> File: `src/providers/treeItems.ts`
> Note: Implemented as pure factory functions instead of class subclasses (per functional style constraint).

- [x] `ConfigItem` — label (key), description (value) [DESIGN-TreeItem Rendering]
- [x] `ContextCategoryItem` — collapsible root for each context key [DESIGN-Context View]
- [x] `ContextFileItem` — individual file with click-to-open [DESIGN-Context View]
- [x] `ADRItem` — ADR number + title, status icon, owner description [DESIGN-TreeItem Rendering]
- [x] `FeatureItem` — name, status icon, task count description, owner [DESIGN-TreeItem Rendering]
- [x] `DocumentItem` — file name, status badge description [DESIGN-TreeItem Rendering]
- [x] `PhaseItem` — phase name, completion count description [DESIGN-TreeItem Rendering]
- [x] `DiscussionItem` — discussion ID, title, status badge [DESIGN-TreeItem Rendering]

### 3.2 Status Icon Mapping

> File: `src/providers/treeItems.ts`

- [x] Map computed statuses to codicons: Complete → `$(check-all)`, In Progress → `$(tools)`, Not Started → `$(circle-outline)` [DESIGN-Status Icons]
- [x] Map spec statuses: Draft → `$(edit)`, Approved → `$(verified)`, Living → `$(pulse)`, Stable → `$(shield)` [DESIGN-Status Icons]
- [x] Map ADR statuses: Proposed → `$(light-bulb)`, Accepted → `$(check)`, Rejected → `$(circle-slash)`, Deprecated → `$(trash)`, Superseded → `$(history)` [DESIGN-Status Icons]

### 3.3 Config View

> File: `src/providers/configTreeProvider.ts`

- [x] Implement `TreeDataProvider` returning flat key-value `ConfigItem` list [DESIGN-Config View]
- [x] Flatten dot-notation keys (e.g., `paths.specs`), arrays as comma-joined, booleans as `true`/`false` [DESIGN-Config View]
- [x] Filter to visible keys only (exclude `ai_attribution`, `require_see_links`, `scan_for_orphans`, `templates`) [DESIGN-Config View]
- [x] Skip optional/commented-out keys — only show keys with actual values [DESIGN-Config View]

### 3.4 Context View

> File: `src/providers/contextTreeProvider.ts`

- [x] Implement `TreeDataProvider` for context categories from `.afx.yaml` `context` block [FR-10], [DESIGN-Context View]
- [x] Root nodes: each context key (e.g., `research`, `architecture`) as collapsible category [DESIGN-Context View]
- [x] Children: glob `*.*` from each context directory [DESIGN-Context View]
- [x] Click opens file in VSCode's default editor for that file type [DESIGN-Context View]

### 3.5 ADR View

> File: `src/providers/adrTreeProvider.ts`

- [x] Implement `TreeDataProvider` returning ADR items globbed from `{paths.adr}/ADR-*.md` [DESIGN-ADR View]
- [x] Extract ADR number from filename `ADR-NNNN-*.md`, title from first `# ` heading or frontmatter [DESIGN-ADR View]
- [x] Show status badge and owner via `description` [FR-4]
- [x] Set view `description` to record count (e.g., "2 records") [DESIGN-ADR View]

### 3.6 Features View

> File: `src/providers/featuresTreeProvider.ts`

- [x] Implement `TreeDataProvider` with feature root nodes from config `features[]` [DESIGN-Features View]
- [x] Feature nodes: name + status icon + task count + owner via `description` [FR-4], [FR-5]
- [x] Document children: spec.md, design.md, tasks.md, journal.md with status badges [AC-Tree View]
- [x] Tasks node: expand to show `PhaseItem` children with per-phase completion counts [AC-Tree View]
- [x] Journal node: expand to show `DiscussionItem` children with status badges [AC-Tree View]
- [x] Set view `description` to summary stats (e.g., "3 features · 29/98") [FR-11]
- [x] Handle missing spec files — show greyed-out node with "(missing)" label [DESIGN-Error Handling]

### 3.7 Click-to-Open Navigation

- [x] Single-click opens file in VSCode preview mode (`vscode.commands.executeCommand('markdown.showPreview')` or `showTextDocument` with preview option) [FR-7], [AC-Navigation]
- [x] Clicking a phase or discussion opens the parent file scrolled to that heading [AC-Navigation]

### 3.8 Integration Tests: Tree Views

> File: `src/test/providers/`

- [ ] Full tree generation from test fixtures [DESIGN-Testing Strategy]
- [ ] Split-pane view registration and rendering [DESIGN-Testing Strategy]

---

## Phase 4: File Watchers

> Ref: [FR-8], [AC-Refresh], [DESIGN-File Watcher Patterns]

### 4.1 File Watcher Setup

> File: `src/watchers/fileWatcher.ts`

- [x] Create `FileSystemWatcher` patterns derived from `AfxConfig.paths` [DESIGN-File Watcher Patterns]
- [x] Implement shared 500ms debounce timer — reset on each event [FR-8], [AC-Refresh]
- [x] `.afx.yaml` change triggers full rebuild (all views) [DESIGN-File Watcher Patterns]
- [x] `{paths.specs}/**/*.md` changes trigger Features view refresh [DESIGN-File Watcher Patterns]
- [x] `{paths.adr}/ADR-*.md` changes trigger ADR view refresh [DESIGN-File Watcher Patterns]
- [x] `{context.*}/**/*` changes trigger Context view refresh [DESIGN-File Watcher Patterns]

### 4.2 Integration Test: Watchers

> File: `src/test/watchers/`

- [ ] File watcher trigger and tree refresh verification [DESIGN-Testing Strategy]

---

## Phase 5: Commands and Filter

> Ref: [FR-6], [DESIGN-Commands], [DESIGN-Filter]

### 5.1 Command Registration

> File: `src/commands/commands.ts`, `src/extension.ts`

- [x] `afx.refresh` — refresh all tree data providers [DESIGN-Commands]
- [x] `afx.openConfig` — open `.afx.yaml` in editor [DESIGN-Commands]
- [x] `afx.collapseAll` — collapse all feature nodes [DESIGN-Commands] (via built-in `showCollapseAll: true`)
- [x] Register all commands as disposables in `activate()` [DESIGN-Commands]

### 5.2 Status Filter

> File: `src/commands/commands.ts`, `src/providers/featuresTreeProvider.ts`

- [x] `afx.filterByStatus` — show quick-pick with options: All, Draft, In Progress, Approved, Living, Stable, Complete [FR-6], [DESIGN-Filter]
- [x] Persist selected filter in `ExtensionContext.workspaceState` [DESIGN-Filter]
- [x] Apply filter to Features view only — Config, Context, and ADRs unaffected [FR-6], [AC-Filtering]

---

## Phase 6: Polish and Packaging

> Ref: [NFR-2], [FR-9], [DESIGN-Error Handling], [DESIGN-Testing Strategy]

### 6.1 Error Handling and Edge Cases

- [x] Welcome view when no `.afx.yaml` found: "No .afx.yaml found" message [DESIGN-Error Handling]
- [x] Malformed `.afx.yaml` — error notification, fallback to empty views [DESIGN-Error Handling]
- [x] Feature directory doesn't exist — greyed-out node, don't crash [DESIGN-Error Handling]
- [x] Frontmatter parse failure — skip document, log warning [DESIGN-Error Handling]

### 6.2 Tooltip Content

- [x] Add `tooltip` markup for all tree items (full details on hover) [DESIGN-TreeItem Rendering]

### 6.2.1 Tree State Persistence

- [ ] Investigate and implement persistence for tree view expansion state (e.g., using `TreeView.onDidCollapseElement` / `onDidExpandElement` and `workspaceState`) [DESIGN-Open Technical Questions]

### 6.3 Performance Verification

- [ ] Verify tree renders in < 500ms for a typical project (≤ 20 features) [NFR-2]

### 6.4 Test Fixtures and Test Suite

> File: `src/test/`

- [ ] Create minimal AFX project fixture: `.afx.yaml`, two features with spec files, two ADRs [DESIGN-Testing Strategy]
- [ ] Unit tests: config parser — valid YAML, missing fields, malformed YAML
- [ ] Unit tests: frontmatter parser — valid, missing, malformed frontmatter
- [ ] Unit tests: task parser — checkbox counting, phase extraction, empty files
- [ ] Unit tests: journal parser — discussion ID extraction, status parsing
- [ ] Unit tests: feature builder — aggregation from parsed documents, status derivation logic
- [ ] Integration tests: full tree generation from test fixtures
- [ ] Integration tests: file watcher trigger and tree refresh verification

### 6.5 Packaging and Distribution

- [x] README.md for extension repository
- [ ] CHANGELOG.md
- [x] Configure bundler (esbuild or webpack) and `.vscodeignore` [DESIGN-Open Technical Questions]
- [x] VSIX packaging scripts (`vsce package`)

---

## Phase 7: Spec and Design Alignment

> The implementation evolved significantly beyond the original 4-view architecture (spec.md, design.md).
> This phase reconciles the spec artifacts with the actual 5-view, 11-provider, 17-command codebase.

### 7.1 Update spec.md — Requirements

> File: `docs/specs/vscode-extension/spec.md`

- [x] Update FR-3: Split-pane sidebar now has 5 views (Project, Specs, Library, Toolbox, Help) not 4
- [x] Add FR-12: Project view — current folder, session context, config summary, recent folders
- [x] Add FR-13: Library view — composite of ADRs, library directories, and tags
- [x] Add FR-14: Toolbox view — pack management with overview, installed/available packs, upstream, skills
- [x] Add FR-15: Help view — repository links, update commands, issue reporting
- [x] Add FR-16: Copy @see reference command — clipboard copy of traceability link
- [x] Add FR-17: Search command — cross-feature search across specs, phases, discussions, ADRs
- [x] Add FR-18: Folder management — open folder picker, recent folders, switch folder
- [x] Add FR-19: Install/Update AFX — one-click install.sh bootstrap and update
- [x] Add FR-20: Status bar — spec stats display with feature/task counts
- [x] Add FR-21: File decoration provider — badge decorations for spec status
- [x] Add FR-22: Session context — display afx-context.md with expandable sections, preview mode
- [x] Add FR-23: Config validation — inline warnings for missing dirs, duplicate features
- [x] Update acceptance criteria to match current functionality
- [x] Update non-goals list

### 7.2 Update design.md — Architecture

> File: `docs/specs/vscode-extension/design.md`

- [x] Update Overview to describe 5-view architecture
- [x] Update component diagram: 5 views, 11 providers, composite pattern
- [x] Replace 4-view sidebar section with 5-view layout:
  - Project: current folder + session context + config + .afx/ browser + recents
  - Specs: features with spec docs, phases, discussions, sections (was "Features")
  - Library: composite of ADRs + library dirs + tags (was "Context" + "ADRs")
  - Toolbox: overview + packs + upstream + skills (was "Skills")
  - Help: static links (repo, docs, updates, issues)
- [x] Update file structure diagram to match actual src/ layout (36 files)
- [x] Update commands table: 32 commands (was 4)
- [x] Update data model interfaces: add `ConfigElement`, `Section`, `SpecsStatsData`
- [x] Document composite provider pattern (libraryTreeProvider delegates to 3 sub-providers)
- [x] Document folder management system (current/recent/switch with `globalState`)
- [x] Document status bar integration (`SpecsStatsData`)
- [x] Document file decoration provider
- [x] Update sidebar mockups to match current 5-view layout
- [x] Update file watcher patterns to include library dirs, .afx/packs/, provider dirs
- [x] Mark open technical questions as resolved (esbuild chosen, collapse via built-in API)

### 7.3 Update tasks.md — Cross-Reference Index

> File: `docs/specs/vscode-extension/tasks.md`

- [x] Update cross-reference index with new FR/NFR numbers from 7.1
- [x] Add rows for Phase 7 tasks
- [x] Remove stale task references (1.6, 2.3, 3.8, 4.2 consolidated into 6.4)
- [x] Update notes section

---

## Implementation Flow

```
Phase 0: Project Scaffolding
    ↓
Phase 1: Config and Parsers
    ↓
Phase 2: Models and Feature Builder
    ↓
Phase 3: Sidebar Tree Views
    ↓
Phase 4: File Watchers
    ↓
Phase 5: Commands and Filter
    ↓
Phase 6: Polish and Packaging
    ↓
Phase 7: Spec and Design Alignment
```

---

## Cross-Reference Index

| Task  | Spec Requirement         | Design Section                        |
| ----- | ------------------------ | ------------------------------------- |
| 0.1   | NFR-1, NFR-3             | File Structure                        |
| 0.2   | FR-3                     | Split-Pane Sidebar, Commands          |
| 0.3   | —                        | File Structure                        |
| 0.4   | —                        | Error Handling                        |
| 1.1   | FR-1                     | Configuration Source, Data Model      |
| 1.2   | FR-2                     | Parsing Logic                         |
| 1.3   | FR-5                     | Parsing Logic, Data Model             |
| 1.4   | —                        | Parsing Logic, Data Model             |
| 1.5   | FR-2                     | Parsing Logic, Data Model             |
| 2.1   | —                        | Data Model                            |
| 2.2   | FR-4, FR-5, FR-11        | Feature Status Derivation, Data Model |
| 3.1–2 | FR-4                     | TreeItem Rendering, Status Icons      |
| 3.3   | FR-1                     | Config View                           |
| 3.4   | FR-10                    | Context View                          |
| 3.5   | FR-4                     | ADR View                              |
| 3.6   | FR-3, FR-4, FR-5, FR-11  | Features View                         |
| 3.7   | FR-7                     | Navigation (AC)                       |
| 4.1   | FR-8                     | File Watcher Patterns                 |
| 5.1   | —                        | Commands                              |
| 5.2   | FR-6                     | Filter                                |
| 6.1   | FR-9                     | Error Handling                        |
| 6.2   | —                        | TreeItem Rendering                    |
| 6.3   | NFR-2                    | —                                     |
| 6.4   | —                        | Testing Strategy                      |
| 6.5   | —                        | Open Technical Questions              |
| 7.1   | FR-3, FR-12–FR-23        | —                                     |
| 7.2   | —                        | All sections                          |
| 7.3   | —                        | —                                     |

---

## Notes

- Tasks are marked complete (`[x]`) as implementation progresses
- Read-only constraint [FR-9] applies globally: no write operations at any phase
- All parsers must degrade gracefully — never crash, always log and continue
- TreeItem subclasses implemented as pure factory functions per functional style constraint
- `afx.collapseAll` implemented via built-in `showCollapseAll: true` on TreeView (standard VSCode pattern)
- The implementation evolved significantly beyond the original 4-view spec during VE-D002 sprint:
  - 4 views → 5 views (Config+Context merged into Project and Library)
  - 4 commands → 17 commands (folder mgmt, search, copy @see, install, etc.)
  - Added: status bar, file decorations, tags, session context, config validation
- Phase 7 captures the work needed to align spec/design docs with current codebase
- Unit/integration tests (originally 1.6, 2.3, 3.8, 4.2) consolidated into Phase 6.4
