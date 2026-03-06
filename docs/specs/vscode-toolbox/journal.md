---
afx: true
type: JOURNAL
status: Living
owner: "@rix"
tags: [vscode-extension, packs, skills, toolbox, journal]
---

# Journal - VSCode AFX Toolbox

<!-- prefix: TB -->

> Quick captures and discussion history for AI-assisted development sessions.
> See [agenticflowx.md](../../agenticflowx/agenticflowx.md) for workflow.

## Captures

<!-- Quick notes during active chat - cleared when recorded -->

---

## Discussions

<!-- Recorded discussions with IDs: TB-D001, TB-D002, etc. -->
<!-- Chronological order: oldest first, newest last -->

### TB-D001 - 2026-02-28 - Spec Promotion from Research

`status:closed` `[product, planning, research]`

**Context**: Two research documents — `res-vscode-pack-management.md` (pack management UI) and `res-skills-ecosystem-index.md` (pack system architecture) — reached sufficient maturity to promote to a full AFX spec. The research covered ecosystem inventory, competitive analysis, sidebar restructure, index strategy, and all major design decisions.

**Summary**: Research findings distilled into a spec with 23 functional requirements, 6 non-functional requirements, and full acceptance criteria. The Toolbox replaces the current flat Skills view with four sections: Overview, Packs (installed + available), Upstream (provider tracking), and Skills (disk mirror). All mutations delegate to `install.sh`. Index fetched from `raw.githubusercontent.com`, cached in `.afx/.cache/lastIndex.json`.

**Decisions**:

- Pane name: **Toolbox** (replaces Skills)
- Four sections: Overview, Packs, Upstream, Skills
- Index file: `packs/index.json` (lean schema — description, category, providers for packs; featured lists for upstream)
- Cache: `.afx/.cache/lastIndex.json` (single file with timestamp for diff)
- Fetch: `raw.githubusercontent.com`, no auth, Node.js `fetch()`
- Skills section: pure disk mirror, click to open
- Upstream: shows providers with "new since last check" from index diff
- All actions delegate to `install.sh` — extension never writes files
- External skills kept pristine — never modified
- Open questions remaining: #2 (install.sh not available), #3 (.afx.local.yaml visual treatment)

**Notes**:

- **[TB-D001.N1]** **[2026-02-28]** Promoted from `res-vscode-pack-management.md` and `res-skills-ecosystem-index.md`. Design and tasks deferred until spec approval. `[product, spec]`

**Related Files**: docs/research/res-vscode-pack-management.md, docs/research/res-skills-ecosystem-index.md, docs/adr/ADR-0003-skill-management-architecture.md
**Participants**: @rix, claude

### TB-D002 - 2026-02-28 - Design Authoring (Phase 0)

`status:closed` `[design, architecture, implementation]`

**Context**: Phase 0 of vscode-toolbox tasks required writing the full design.md before implementation could begin. The existing design.md was a 34-line placeholder with only frontmatter and section headings. All design decisions had been captured in spec.md (24 FR + 6 NFR) and the TB-D001 discussion, but no technical architecture document existed.

**Summary**: Wrote comprehensive 680+ line design.md covering 13 sections. Design was informed by reading the actual vscode-afx source code (extension.ts, all 5 tree providers, commands, models, statusBar, package.json) to ensure the Toolbox integrates naturally with the existing 5-view architecture. Key pattern: single `ToolboxTreeDataProvider` with `ToolboxElement` discriminated union (12 variants), following the same factory-function style used by specsTreeProvider and libraryTreeProvider.

**Decisions**:

- Single provider pattern: one `ToolboxTreeDataProvider` with 4 collapsible section headers (not 4 separate providers)
- `ToolboxElement` discriminated union with `kind` field — 12 variants: `section-header`, `overview-stat`, `installed-pack`, `pack-provider`, `pack-item`, `disabled-pack`, `available-pack`, `upstream-provider`, `upstream-item`, `skill-folder`, `skill-file`, `setup-prompt`
- Data models: `Pack`, `ProviderDir`, `PackItem`, `AvailablePack`, `UpstreamProvider`, `CachedIndex` interfaces
- Index fetch: `fetchIndex()` with 10s timeout, `computeDiff()` returns `{newPacks, removedPacks, newUpstreamItems}`
- Pack state assembly: 5-step algorithm merging `.afx.yaml` config + `.afx/packs/` disk scan + index data
- CLI delegation: `runInstallSh()` spawns child process, 9 command mappings to `install.sh` flags
- Hover actions: 7 `contextValue` strings mapped to 8 `view/item/context` menu bindings
- File structure: new `src/toolbox/` directory with 7 files, 3 modified existing files
- No new dependencies — uses Node.js built-in `fetch()` and existing vscode APIs

**Notes**:

- **[TB-D002.N1]** **[2026-02-28]** Confirmed via git history that design.md had never been committed with content beyond placeholder. User initially thought it had been written in a previous session. `[clarification]`
- **[TB-D002.N2]** **[2026-02-28]** All 19 Phase 0 task items (0.1–0.6) marked complete. Cross-reference index updated with actual design section numbers. `[traceability]`

**Related Files**: docs/specs/vscode-toolbox/design.md, docs/specs/vscode-toolbox/tasks.md, vscode-afx/src/extension.ts, vscode-afx/src/providers/specsTreeProvider.ts
**Participants**: @rix, claude

### TB-D003 - 2026-02-28 - Design Sync Audit (afx-packs alignment)

`status:closed` `[design, sync, dependencies]`

**Context**: The vscode-toolbox design.md was written before thorough cross-referencing with afx-packs/design.md. Since the Toolbox depends entirely on afx-packs output (directory structure, CLI interface, index format, .afx.yaml schema), the designs must be in strict alignment.

**Summary**: Audited all 13 sections of vscode-toolbox/design.md against afx-packs/design.md. Found 8 mismatches (2 critical, 3 medium, 3 low). All fixed in a single pass.

**Issues Found & Fixed**:

1. **[CRITICAL] install.sh location** — design referenced `.afx/install.sh` but install.sh lives in AFX repo root and is fetched via `curl | bash`. Fixed: rewrote §6.1 Runner Pattern to use curl-pipe pattern matching existing `afx.installAfx` command.
2. **[CRITICAL] AfxConfig claim** — design said "Already has packs support — no changes needed" but actual `AfxConfig` interface has no `packs` field. Fixed: corrected integration table §1.3, added note about separate `afxDirReader` for pack state.
3. **[MEDIUM] Skills section dirs** — disk mirror listed `.codex/` but Codex CLI uses `.agents/` per afx-packs §2.4. Fixed: updated §4.5 tree mockup, added provider directory mapping table.
4. **[MEDIUM] CachedIndex type** — `featured: string[]` but index allows empty repos `{}` with no featured key. Fixed: changed to `featured?: string[]` in §2.1.
5. **[MEDIUM] Pack naming in CLI** — ambiguous `{name}` in command mapping. Fixed: added short name convention note, `shortPackName()` helper, documented that install.sh adds `afx-pack-` prefix internally.
6. **[LOW] custom_skills missing** — afx-packs .afx.yaml has `custom_skills:` section not mentioned. Fixed: added to data sources table §3.1.
7. **[LOW] Missing CLI commands** — added `--add-skill`, `--branch`, `--version`, `--pack-list` to command mapping §6.2.
8. **[LOW] isExternal heuristic** — documented that `afx-` prefix check is a read-time approximation of source repo check used at install time (afx-packs §3.6).

**Additional fixes**: File watchers §7.1 (removed `.codex/`), error handling table §11 (updated install.sh scenarios), dependencies table §13 (clarified remote fetch).

**Decisions**:

- CLI integration uses `curl -sL {url} | bash -s -- {args}` pattern (not local install.sh lookup)
- Pack state is read by new `afxDirReader`, NOT by existing `afxConfigParser`
- Provider directory mapping follows afx-packs §2.4: codex→`.agents/`, antigravity→`.agent/`

**Related Files**: docs/specs/vscode-toolbox/design.md, docs/specs/afx-packs/design.md
**Participants**: @rix, claude

### TB-D004 - 2026-02-28 - Full 5-Document Sync Audit

`status:closed` `[design, sync, research, spec]`

**Context**: After TB-D003 (afx-packs alignment), user requested a full cross-reference against all supporting documents: both research docs (`res-vscode-pack-management.md`, `res-skills-ecosystem-index.md`), `afx-packs/spec.md`, `vscode-toolbox/spec.md`, and `vscode-toolbox/design.md`.

**Summary**: Audited all 5 documents for alignment. Found 2 issues in the design (both caused by over-correction in TB-D003). The rest is aligned — index schemas, CLI commands, constraints tables, and core principles are consistent across all documents.

**Issues Found & Fixed**:

1. **[MEDIUM] `.codex/` removed from design §4.5 but spec FR-13 lists it** — TB-D003 replaced `.codex/` with `.agents/` in the disk mirror, but the spec explicitly lists both: `.claude/, .codex/, .agents/, .agent/, .github/`. Both directories exist on disk: `.codex/` holds core AFX Codex skills (from `install.sh` core), `.agents/` holds pack-installed Codex skills (from `install.sh --pack`). Fixed: restored `.codex/` to disk mirror tree, updated provider mapping note.
2. **[MEDIUM] File watchers §7.1 missing `.codex/`** — Same root cause. Fixed: added `.codex/` back to watched directories.

**Verified (no issues)**:

- Index schemas match across all 5 docs: `{ packs: { name: { description, category, providers } }, upstream: { repo: { featured? } } }`
- CLI commands consistent: research §3, afx-packs spec appendix, toolbox spec acceptance criteria, toolbox design §6.2 — all use same flags
- Constraints tables consistent: install.sh single driver, `.afx/` master, provider dirs derived, disable=delete copies, remove=delete all
- Provider routing rules: Simple Skill → Claude+Codex+Antigravity, Claude Plugin → Claude only, OpenAI Skill → Codex only, AFX-built → all
- Research §8 correctly documents `.agents/` as Codex pack target (not `.codex/`)
- afx-packs spec FR-39 correctly specifies `.agents/skills/` for Simple Skills

**Key insight**: `.codex/` and `.agents/` are NOT the same directory. `.codex/` is used by current `install.sh` for core AFX Codex skills. `.agents/` is used by `install.sh --pack` for pack-installed Codex skills. The disk mirror must show both.

**Related Files**: docs/specs/vscode-toolbox/design.md, docs/specs/vscode-toolbox/spec.md, docs/specs/afx-packs/spec.md, docs/specs/afx-packs/design.md, docs/research/res-vscode-pack-management.md, docs/research/res-skills-ecosystem-index.md
**Participants**: @rix, claude

### TB-D005 - 2026-02-28 - Full Pane Mockup & afx-packs Output Audit

`status:closed` `[design, ui, sync]`

**Context**: Design §4 had per-section mockups but no unified view of the full AFX sidebar. User requested the complete pane showing all 5 views. Also identified that design was inventing data fields (`latest_ref`, `changelog`, `pack-update` contextValue) not backed by actual afx-packs output.

**Summary**: Added a full 5-view sidebar mockup (Project, Specs, Library, Toolbox, Help) to design §4.1 showing every element expanded with all hover actions. Stripped all invented fields — Toolbox now works strictly with what afx-packs outputs. Synced tasks.md to match.

**Changes**:

1. **Full pane mockup** — design §4.1 now shows complete AFX sidebar (~150 lines) with all 5 views, every tree node expanded, hover actions on every actionable row
2. **Removed `pack-update` contextValue** — index has no version info (open question #7), so Update action is unconditional on `pack-enabled`
3. **Removed `pack-meta` tree element** — no version metadata rows (installed/latest/changelog don't exist in index)
4. **Reverted `Pack` interface** — removed `latestRef`, `updateAvailable`, `changelog` fields
5. **Reverted `CachedIndex`** — removed `latest_ref`, `changelog` from index schema
6. **Overview "Updates" row** — changed from "1 pack update" to "2 new packs, 3 new upstream skills" (only index diff data)
7. **Upstream refresh** — moved `[↻ Refresh]` to each provider row (not section header)
8. **tasks.md synced** — updated hover action tasks, overview badge text, icon mapping note, added notes about unconditional Update and afx-packs data sourcing

**Decisions**:

- All Toolbox data must trace to actual afx-packs output — no aspirational fields
- Update action always visible on enabled packs (unconditional) until index gains version info
- Full sidebar mockup is the single source of truth for UI layout

**Related Files**: docs/specs/vscode-toolbox/design.md, docs/specs/vscode-toolbox/tasks.md
**Participants**: @rix, claude

---

## Work Sessions

<!-- Task execution log - updated by /afx:work next, /afx:dev code -->

| Date | Task | Action | Files Modified | Agent | Human |
| ---- | ---- | ------ | -------------- | ----- | ----- |
| 2026-02-28 | 0.1 Architectural Overview | Wrote design.md §1 (Architecture) | design.md | [OK] | [ ] |
| 2026-02-28 | 0.2 Data Models | Wrote design.md §2 (Data Models) | design.md | [OK] | [ ] |
| 2026-02-28 | 0.3 Data Flow Architecture | Wrote design.md §3 (Data Flow) | design.md | [OK] | [ ] |
| 2026-02-28 | 0.4 CLI Integration Design | Wrote design.md §6 (CLI Integration) | design.md | [OK] | [ ] |
| 2026-02-28 | 0.5 Tree Item Rendering | Wrote design.md §4–5 (Tree View, Hover Actions) | design.md | [OK] | [ ] |
| 2026-02-28 | 0.6 File Structure | Wrote design.md §7–9 (Watchers, Settings, Files) | design.md | [OK] | [ ] |
| 2026-02-28 | — Design Sync Audit | Fixed 8 mismatches vs afx-packs/design.md (TB-D003) | design.md, journal.md | [OK] | [ ] |
| 2026-02-28 | — Full 5-Doc Sync | Restored .codex/ to design §4.5 and §7.1 (TB-D004) | design.md, journal.md | [OK] | [ ] |
| 2026-02-28 | — Full Pane Mockup | Added full 5-view sidebar mockup to design §4.1, removed pack-update contextValue, synced tasks.md (TB-D005) | design.md, tasks.md, journal.md | [OK] | [ ] |
| 2026-02-28 | 1.1 Rename Skills → Toolbox | Renamed view ID, title, welcome content, added 9 commands + 9 menu bindings | package.json | [OK] | [ ] |
| 2026-02-28 | 1.2 Create ToolboxTreeDataProvider | Single provider with 4 sections, getTreeItem for all 12 element kinds, Skills disk mirror working | toolboxTreeProvider.ts, extension.ts, commands.ts | [OK] | [ ] |
| 2026-02-28 | 1.3 Define TypeScript Data Models | Pack, PackItem, AvailablePack, UpstreamProvider, CachedIndex, ToolboxElement union | models.ts | [OK] | [ ] |
| 2026-02-28 | 2.1 Read .afx.yaml Pack State | Parse packs: and custom_skills: sections with validation | afxYamlReader.ts | [OK] | [ ] |
| 2026-02-28 | 2.2 Read .afx/ Directory Structure | Scan .afx/packs/{pack}/{provider}/ with type detection (skills/plugins/agents), copilot .agent.md support | afxDirReader.ts | [OK] | [ ] |
| 2026-02-28 | 2.3 Index Fetch & Cache | Fetch from raw.githubusercontent.com, cache at .afx/.cache/lastIndex.json, offline fallback | indexService.ts | [OK] | [ ] |
| 2026-02-28 | 2.4 Index Diff | computeDiff (new packs + new upstream items), computeAvailablePacks (index minus installed) | indexService.ts | [OK] | [ ] |
| 2026-02-28 | 2.5 File Watchers | Watch .afx/packs/** and 6 provider dirs, 500ms debounce, wired into extension.ts | toolboxWatchers.ts, extension.ts | [OK] | [ ] |
| 2026-02-28 | — Wire Data Layer | Replaced TODO placeholders in tree provider: getPacks, getIndex, getAvailable, getUpstream with caching; live Overview stats | toolboxTreeProvider.ts | [OK] | [ ] |
| 2026-02-28 | 3.2 Check Button | afx.toolbox.checkIndex command with progress notification, summary message, tree refresh | toolboxCommands.ts | [OK] | [ ] |
| 2026-02-28 | 3.3 Auto-Check on Activation | autoCheckIfDue with configurable interval (86400s default), 2 new settings in package.json | toolboxCommands.ts, extension.ts, package.json | [OK] | [ ] |
| 2026-02-28 | 7.1 install.sh Integration | runInstallSh via curl-pipe, terminal output, post-close refresh | installShRunner.ts | [OK] | [ ] |
| 2026-02-28 | 7.2 CLI Command Mapping | 7 pack/skill commands: install, remove, enable, disable, update, skill-disable, skill-enable | toolboxCommands.ts | [OK] | [ ] |
| 2026-02-28 | Phases 3–7 Bulk | All phases marked complete: Overview, Packs, Upstream, Skills (Phase 1), CLI delegation. Skills disk mirror from Phase 1 already done. | tasks.md, journal.md | [OK] | [ ] |

---
