---
afx: true
type: TASKS
status: Living
owner: "@rix"
version: 1.0
created: "2026-02-28"
last_verified: "2026-02-28"
tags: [vscode-extension, packs, skills, toolbox]
---

# VSCode AFX Toolbox - Implementation Tasks

**Version:** 1.0
**Date:** 2026-02-28
**Status:** Ready for Implementation
**Spec:** [spec.md](./spec.md)
**Design:** [design.md](./design.md)

---

## Task Numbering Convention

Tasks use hierarchical numbering for cross-referencing:

- **0.x** - Phase 0: Design Authoring (write design.md — prerequisite for all implementation)
- **1.x** - Phase 1: Foundation & Sidebar Restructure
- **2.x** - Phase 2: Data Layer (index fetch, .afx.yaml reading, file watchers)
- **3.x** - Phase 3: Overview Section
- **4.x** - Phase 4: Packs Section (Installed + Available)
- **5.x** - Phase 5: Upstream Section
- **6.x** - Phase 6: Skills Disk Mirror
- **7.x** - Phase 7: CLI Delegation & Actions

References:

- `[FR-N]` = Functional Requirement N from spec.md
- `[NFR-N]` = Non-Functional Requirement N from spec.md
- `[DESIGN-X.X]` = Section X.X from design.md (pending design approval)

---

## Phase 0: Design Authoring

> Prerequisite: Write design.md before implementation begins. Design currently a placeholder.
> Ref: Spec requirements [FR-1 through FR-24], [NFR-1 through NFR-6]

### 0.1 Architectural Overview

> File: `docs/specs/vscode-toolbox/design.md` — Sections 1.1–1.4

- [x] Document component architecture: ToolboxTreeDataProvider as single provider with 4 sections
- [x] Document relationship with existing vscode-afx extension (same repo, same activation, shared config parser)
- [x] Document section hierarchy: Overview → Packs → Upstream → Skills
- [x] Document read-only + CLI delegation constraint (extension reads state, `install.sh` writes state)

### 0.2 Data Models

> File: `docs/specs/vscode-toolbox/design.md` — Section 2

- [x] Define `Pack` interface: name, status (enabled/disabled), installedRef, disabledItems, providers, items
- [x] Define `PackItem` interface: name, type (skill/plugin/agent), providerType, isExternal
- [x] Define `AvailablePack` interface: description, category, providers
- [x] Define `UpstreamProvider` interface: repo, featured, lastFetched, newItems
- [x] Define `ToolboxElement` discriminated union for tree data provider
- [x] Define `CachedIndex` interface: packs, upstream, fetchedAt timestamp

### 0.3 Data Flow Architecture

> File: `docs/specs/vscode-toolbox/design.md` — Section 3

- [x] Document data sources and flow: `.afx.yaml` → pack state, `.afx/packs/` → installed items, `index.json` → available packs
- [x] Document index fetch strategy: `raw.githubusercontent.com` via Node.js `fetch()`, no auth
- [x] Document cache strategy: `.afx/.cache/lastIndex.json` with timestamp
- [x] Document diff computation: cached vs fresh index for "new since last check"
- [x] Document offline handling: use cached data, show "offline" indicator
- [x] Document data refresh triggers: file watchers, manual check, auto-check on activation

### 0.4 CLI Integration Design

> File: `docs/specs/vscode-toolbox/design.md` — Section 6

- [x] Document `installShRunner` pattern: spawn child process, capture output, show terminal/notification
- [x] Document command mapping table: UI action → `install.sh` CLI args
- [x] Document error handling: `install.sh` not found, non-zero exit, timeout
- [x] Document dry-run preview flow

### 0.5 Tree Item Rendering

> File: `docs/specs/vscode-toolbox/design.md` — Sections 4, 5

- [x] Document TreeItem properties for each element type (Pack, Skill, Overview stat, Upstream provider)
- [x] Document icon/codicon mapping for pack states (enabled, disabled, available)
- [x] Document hover actions implementation (inline buttons via `contextValue` + menus)
- [x] Document disabled visual treatment (dimmed icon, strikethrough description)

### 0.6 File Structure

> File: `docs/specs/vscode-toolbox/design.md` — Sections 7–9

- [x] Document src/toolbox/ directory layout
- [x] Document integration with existing extension.ts activation
- [x] Document new package.json contribution points (commands, menus, settings)

---

## Phase 1: Foundation & Sidebar Restructure

> Ref: [FR-1], [NFR-1], [NFR-4]

### 1.1 Rename Skills View to Toolbox

> File: `src/toolbox/` (new), `package.json`

- [x] Rename the current **Skills** view to **Toolbox** in sidebar `[FR-1]`
- [x] Update `package.json` contribution points — view ID, title, icon
- [x] Verify other 4 views (Project, Specs, Library, Help) remain unchanged
- [x] Toolbox appears in the same position as the current Skills view

### 1.2 Create Toolbox Tree Data Provider

> File: `src/toolbox/toolboxTreeDataProvider.ts`

- [x] Create `ToolboxTreeDataProvider` implementing `vscode.TreeDataProvider`
- [x] Define tree item types: Overview, Packs (Installed/Available), Upstream, Skills
- [x] Register provider in `extension.ts` activation
- [x] Only activate in projects with `.afx.yaml` `[NFR-1]`
- [ ] Tree renders in < 500ms for ≤ 10 installed packs `[NFR-4]` _(to verify when pack data exists)_

### 1.3 Define TypeScript Data Models

> File: `src/toolbox/models.ts`

- [x] Define `Pack` interface: name, status, installedRef, disabledItems, providers, items
- [x] Define `PackItem` interface: name, itemType, isExternal, isDisabled, filePath
- [x] Define `AvailablePack` interface: name, description, category, providers
- [x] Define `UpstreamProvider` interface: repo, featured, lastFetched, newSinceLastCheck
- [x] Define `CachedIndex` interface: fetchedAt, packs, upstream
- [x] Define `ToolboxElement` discriminated union (12 variants)

---

## Phase 2: Data Layer

> Ref: [FR-15], [FR-16], [FR-17], [FR-20], [FR-21], [NFR-2], [NFR-3]

### 2.1 Read `.afx.yaml` Pack State

> File: `src/toolbox/afxYamlReader.ts`

- [x] Parse `.afx.yaml` and extract `packs:` section `[FR-20]`
- [x] Extract per-pack: name, status, installed_ref, disabled_items `[FR-20]`
- [x] Extract `custom_skills:` list `[FR-20]`
- [x] Handle missing `.afx.yaml` or missing `packs:` section gracefully

### 2.2 Read `.afx/` Directory Structure

> File: `src/toolbox/afxDirReader.ts`

- [x] Scan `.afx/packs/{pack}/{provider}/` to enumerate installed items `[FR-21]`
- [x] Map items to their provider and type (skill/plugin/agent)
- [x] Handle missing `.afx/` directory (no packs installed)

### 2.3 Index Fetch & Cache

> File: `src/toolbox/indexService.ts`

- [x] Fetch `packs/index.json` from `raw.githubusercontent.com` via Node.js `fetch()` `[FR-15]`
- [x] Cache fetched index at `.afx/.cache/lastIndex.json` with timestamp `[FR-16]`
- [x] No authentication required `[NFR-3]`
- [x] Handle offline gracefully — use cached data with "offline" indicator `[NFR-2]`

### 2.4 Index Diff

> File: `src/toolbox/indexService.ts`

- [x] Diff cached `lastIndex.json` vs freshly fetched index `[FR-17]`
- [x] Compute "new since last check" items per upstream provider `[FR-17]`
- [x] Compute "available packs" (in index but not in `.afx.yaml`) `[FR-17]`

### 2.5 File Watchers

> File: `src/toolbox/toolboxWatchers.ts`

- [x] Watch `.afx.yaml` for pack state changes — refresh tree on change _(existing in fileWatcher.ts)_
- [x] Watch `.afx/packs/` for item changes — refresh Packs section
- [x] Watch provider directories (`.claude/`, `.codex/`, `.agents/`, `.agent/`, `.gemini/`, `.github/`) — refresh Skills section
- [x] Debounce refresh to avoid excessive redraws (500ms)

---

## Phase 3: Overview Section

> Ref: [FR-2], [FR-18], [FR-23]

### 3.1 Overview Tree Items

> File: `src/toolbox/toolboxTreeProvider.ts` (getOverviewChildren)

- [x] Show active provider count (e.g., "Providers: 4 active") `[FR-2]`
- [x] Show installed pack count with item total `[FR-2]`
- [x] Show updates summary from index diff `[FR-2]`
- [x] Show last checked timestamp with relative formatting `[FR-2]`

### 3.2 Check Button

> File: `src/toolbox/toolboxCommands.ts`

- [x] Add **Check** inline button to trigger on-demand index fetch `[FR-18]`
- [x] Update last checked timestamp after fetch
- [x] Refresh tree after check completes
- [x] Show progress notification during fetch
- [x] Show summary notification (new packs/skills or "up to date")

### 3.3 Auto-Check on Activation

> File: `src/toolbox/toolboxCommands.ts` (autoCheckIfDue)

- [x] Auto-check index on extension activation (configurable setting) `[FR-23]`
- [x] Add `afx.toolbox.autoCheck` setting to `package.json`
- [x] Add `afx.toolbox.autoCheckInterval` setting (default 86400s)
- [x] Only fetch if elapsed time exceeds interval

---

## Phase 4: Packs Section

> Ref: [FR-3] through [FR-9], [FR-20], [FR-21]

### 4.1 Installed Packs List

> File: `src/toolbox/toolboxTreeProvider.ts` (pack-group children)

- [x] List all packs from `.afx.yaml` under "Installed" group `[FR-3]`
- [x] Each pack shows: name, status, provider count, item count, installed ref `[FR-4]`
- [x] Enabled packs expand to show provider → item hierarchy `[FR-5]`
- [x] Disabled packs show with visual indicator (dimmed icon) `[NFR-6]`

### 4.2 Pack Item Details

> File: `src/toolbox/toolboxTreeProvider.ts` (pack-provider, pack-item)

- [x] Provider subdirectories show as children: `claude/`, `codex/`, `antigravity/`, `copilot/`
- [x] Individual items show within each provider `[FR-5]`
- [x] Items labeled as external (pristine) or afx-built `[FR-5]`

### 4.3 Available Packs List

> File: `src/toolbox/toolboxTreeProvider.ts` (available-pack)

- [x] List packs from index that are NOT in `.afx.yaml` `[FR-6]`
- [x] Each shows name, description `[FR-6]`

### 4.4 Pack Hover Actions

> File: `src/toolbox/toolboxCommands.ts`, `package.json` menus

- [x] Enabled pack hover: **Update**, **Disable**, and **Remove** buttons (`contextValue: pack-enabled`) `[FR-7]` `[FR-8]`
- [x] Disabled pack hover: **Enable** and **Remove** buttons (`contextValue: pack-disabled`) `[FR-7]`
- [x] Available pack hover: **Install** button (`contextValue: pack-available`) `[FR-6]`
- [x] Enabled skill hover: **Disable** button (`contextValue: pack-item-enabled`) `[FR-9]`
- [x] Disabled skill hover: **Enable** button (`contextValue: pack-item-disabled`) `[FR-9]`

---

## Phase 5: Upstream Section

> Ref: [FR-11], [FR-12], [FR-19]

### 5.1 Upstream Provider List

> File: `src/toolbox/toolboxTreeProvider.ts` (upstream-provider, upstream-item)

- [x] List tracked upstream providers from index `[FR-11]`
- [x] Show last fetched timestamp per provider `[FR-12]`
- [x] Show "new since last check" items computed from index diff `[FR-12]`

### 5.2 Upstream Interactions

> File: `src/toolbox/toolboxCommands.ts`

- [x] **Refresh** button triggers re-fetch of index `[FR-19]`
- [ ] Clicking upstream skill opens provider page in browser `[FR-11]` _(future: needs URL resolution from repo name)_
- [x] Works offline — shows cached data with "offline" indicator `[NFR-2]`

---

## Phase 6: Skills Disk Mirror

> Ref: [FR-13], [FR-14]

### 6.1 Provider Directory Tree

> File: `src/toolbox/toolboxTreeProvider.ts` (skills-provider, skills-dir, skills-file)

- [x] Show provider directories as-is from disk: `.claude/`, `.codex/`, `.agents/`, `.agent/`, `.gemini/`, `.github/` `[FR-13]`
- [x] Mirror actual folder structure — no grouping, no attribution `[FR-13]`
- [x] Include `.github/agents/` subdirectory `[FR-13]`

### 6.2 Click-to-Open

> File: `src/toolbox/toolboxTreeProvider.ts`

- [x] Click any item to open file in VSCode editor `[FR-14]`
- [x] Reflect live disk state (auto-refresh via file watchers from 2.5)

---

## Phase 7: CLI Delegation & Actions

> Ref: [FR-10], [FR-22], [FR-24], [NFR-5]

### 7.1 install.sh Integration

> File: `src/toolbox/installShRunner.ts`

- [x] Implement `runInstallSh()` — curl-pipe to install.sh with args `[FR-10]`
- [x] Extension never writes files directly — all mutations via `install.sh` `[NFR-5]`
- [x] Show terminal output on action completion `[FR-10]`
- [x] Refresh tree after terminal closes (1500ms delay)

### 7.2 CLI Command Mapping

> File: `src/toolbox/toolboxCommands.ts`

- [x] Install: `--pack {name} .` `[FR-10]`
- [x] Remove: `--pack-remove {name} .` `[FR-10]`
- [x] Disable pack: `--pack-disable {name} .` `[FR-10]`
- [x] Enable pack: `--pack-enable {name} .` `[FR-10]`
- [x] Disable skill: `--pack {pack} --skill-disable {name} .` `[FR-10]`
- [x] Enable skill: `--pack {pack} --skill-enable {name} .` `[FR-10]`
- [x] Update: `--update --packs .` `[FR-10]`
- [ ] Dry run: `--dry-run --pack {name} .` `[FR-22]` _(future: needs UI trigger)_

### 7.3 Setup AFX Button

> File: `src/extension.ts` (existing offerInstall/installAfx)

- [x] Show **Setup AFX** button when `.afx.yaml` not available `[FR-24]` _(existing functionality)_
- [x] Bootstrap via curl `[FR-24]` _(existing functionality)_

---

## Implementation Flow

```
Phase 0: Design Authoring (write design.md)
    ↓
Phase 1: Foundation & Sidebar Restructure
    ↓
Phase 2: Data Layer (index, .afx.yaml, file watchers)
    ↓ (parallel)
    ├── Phase 3: Overview Section
    ├── Phase 4: Packs Section
    ├── Phase 5: Upstream Section
    └── Phase 6: Skills Disk Mirror
    ↓
Phase 7: CLI Delegation & Actions
```

---

## Cross-Reference Index

| Task | Spec Requirements          | Design Section                                   |
| ---- | -------------------------- | ------------------------------------------------ |
| 0.1  | FR-1–FR-24, NFR-1–NFR-6    | 1. Architecture (1.1–1.4)                        |
| 0.2  | —                          | 2. Data Models (2.1–2.2)                         |
| 0.3  | FR-15, FR-16, FR-17, NFR-2 | 3. Data Flow (3.1–3.5)                           |
| 0.4  | FR-10, FR-22, NFR-5        | 6. CLI Integration (6.1–6.3)                     |
| 0.5  | FR-4, FR-5, FR-7, NFR-6    | 4. Tree View Structure, 5. Hover Actions         |
| 0.6  | —                          | 7. File Watchers, 8. Settings, 9. File Structure |
| 1.1  | FR-1                       | 1.3 Integration, 9.3 package.json                |
| 1.2  | NFR-1, NFR-4               | 1.1 System Context, 12. Performance              |
| 1.3  | —                          | 2.1 Core Interfaces, 2.2 Tree Element            |
| 2.1  | FR-20                      | 3.4 Pack State Assembly                          |
| 2.2  | FR-21                      | 3.4 Pack State Assembly                          |
| 2.3  | FR-15, NFR-2, NFR-3        | 3.2 Index Fetch Strategy                         |
| 2.4  | FR-17                      | 3.3 Index Diff Computation                       |
| 2.5  | —                          | 7. File Watchers                                 |
| 3.1  | FR-2                       | 4.2 Overview Section                             |
| 3.2  | FR-18                      | 4.2 Overview Section (Check button)              |
| 3.3  | FR-23                      | 8.2 Auto-Check Logic                             |
| 4.1  | FR-3, FR-4, FR-5, NFR-6    | 4.3 Packs Section (Installed)                    |
| 4.2  | FR-5                       | 4.3 Packs Section (Provider hierarchy)           |
| 4.3  | FR-6                       | 4.3 Packs Section (Available)                    |
| 4.4  | FR-6, FR-7, FR-8, FR-9     | 5. Hover Actions (5.1–5.3)                       |
| 5.1  | FR-11, FR-12               | 4.4 Upstream Section                             |
| 5.2  | FR-11, FR-19, NFR-2        | 4.4 Upstream, 3.5 Offline Handling               |
| 6.1  | FR-13                      | 4.5 Skills Section (Disk Mirror)                 |
| 6.2  | FR-14                      | 4.5 Skills Section (click-to-open)               |
| 7.1  | FR-10, NFR-5               | 6.1 Runner Pattern                               |
| 7.2  | FR-10, FR-22               | 6.2 Command Mapping                              |
| 7.3  | FR-24                      | 6.3 Setup AFX Button                             |

---

## Notes

- **Phase 0 COMPLETE** — design.md written with 13 sections covering architecture, data models, data flow, tree views, hover actions, CLI integration, file watchers, settings, file structure, decisions, error handling, performance, and dependencies
- **Design includes full AFX sidebar mockup** — all 5 views (Project, Specs, Library, Toolbox, Help) with every element expanded and all hover actions shown (design.md §4.1)
- **Update action is unconditional** — the afx-packs index has no version info ([spec open question #7](./spec.md#open-questions)), so Update always appears on enabled packs. No `pack-update` contextValue — only `pack-enabled` and `pack-disabled`
- **All Toolbox data sourced from afx-packs output** — `.afx.yaml`, `.afx/packs/`, `.afx/.cache/lastIndex.json`, `packs/index.json`. No invented fields
- Phase 1 and 2 are sequential — foundation must exist before data layer
- Phases 3–6 can be worked in parallel once the data layer is ready
- Phase 7 (CLI delegation) connects to Phase 4 actions — can be built alongside Phase 4
- This spec depends on the [afx-packs](../afx-packs/spec.md) infrastructure — `install.sh` pack commands must exist before Phase 7 is testable
- The Toolbox replaces the current **Skills** view in `vscode-afx` — same repo, same extension, additive change
