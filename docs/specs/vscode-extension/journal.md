---
afx: true
type: JOURNAL
status: Living
owner: "@rix"
tags: [vscode-extension, journal]
---

# Journal - AFX VSCode Extension

<!-- prefix: VE -->

> Quick captures and discussion history for AI-assisted development sessions.
> See [agenticflowx.md](../../agenticflowx/agenticflowx.md) for workflow.

## Captures

<!-- Quick notes during active chat - cleared when recorded -->

---

## Discussions

<!-- Recorded discussions with IDs: VE-D001, VE-D002, etc. -->
<!-- Chronological order: oldest first, newest last -->

### VE-D001 - 2026-02-26 - Spec Promotion from Research

`status:active` `[product, planning]`

**Context**: ADR-0002 and the original afx-research.md document captured the product direction decision (VSCode extension over web app or CLI/TUI). This discussion tracks the promotion to a full AFX spec package.

**Summary**: Research findings distilled into ADR-0002 (Accepted), then promoted to a full spec with spec.md, design.md, tasks.md, and journal.md. MVP scope covers sidebar tree view, status bar, file watchers, and core commands.

**Decisions**:

- VSCode Extension is the primary product direction (per ADR-0002)
- MVP scope: tree view + status bar + file watchers + commands (7 phases)
- Tech stack: TypeScript, VSCode Extension API, yaml, gray-matter
- Activation: `workspaceContains:.afx.yaml` only
- WebView dashboard and GitHub sync deferred to post-MVP

**Notes**:

- **[VE-D001.N1]** **[2026-02-26]** Promoted from `docs/adr/afx-research.md` and `docs/adr/ADR-0002-product-direction-vscode-extension.md` `[product, adr]`

**Related Files**: docs/adr/afx-research.md, docs/adr/ADR-0002-product-direction-vscode-extension.md
**Participants**: @rix

### VE-D002 - 2026-02-26 - Full Implementation Sprint (v0.1.0)

`status:active` `[implementation, sprint]`

**Context**: First implementation session. All phases (0-5) completed in a single sprint. Typecheck clean, esbuild passes in 24ms. Targeting manual user testing before unit tests.

**Summary**: Built the entire `vscode-afx` extension from empty directory to working build. 22 source files across 7 modules: config parser, 4 parsers (frontmatter, task, journal, specDocument), 3 model interfaces, 4 tree providers (config, context, ADR, features), file watchers with 500ms debounce, 4 commands with filter persistence.

**Decisions**:

- Functional style: all tree providers implemented as factory functions returning objects (no classes)
- `afx.collapseAll` replaced with built-in `showCollapseAll: true` on TreeView — standard VSCode pattern
- `afx.openAtLine` custom command added for scroll-to-heading on phase/discussion click
- Feature documents parsed in parallel via `Promise.all` for performance
- esbuild chosen over webpack — 24ms builds, 407KB bundle
- Unit tests deferred to post-v0.1.0 — user will test manually first
- ESLint deferred — not blocking for initial build
- Tree state persistence (6.2.1) deferred — open design question

**Architecture notes**:

- Mutable config ref pattern: `state.config` updated on `.afx.yaml` change, all providers read via `getConfig()` closure
- Stats callbacks: providers call `onStats(description)` after computing children; extension.ts sets `TreeView.description`
- Discriminated unions for tree elements: each provider uses tagged `kind` field for type-safe hierarchy
- Line tracking in parsers: `Phase.line` and `Discussion.line` captured during parsing for scroll-to-heading

**Notes**:

- **[VE-D002.N1]** **[2026-02-26]** All 22 source files written, `tsc --noEmit` clean, esbuild bundle succeeds `[implementation]`
- **[VE-D002.N2]** **[2026-02-26]** Design gap confirmed: `contextTreeProvider.ts` missing from design.md file structure. Added in implementation. `[design-gap]`
- **[VE-D002.N3]** **[2026-02-26]** Bug fix: `viewContainers` → `viewsContainers` (missing "s") in package.json. Views were falling back to Explorer. Also fixed SVG icon from stroke to fill format. `[bugfix]`

**Related Files**: vscode-afx/src/extension.ts, vscode-afx/package.json, docs/specs/vscode-extension/tasks.md
**Participants**: @rix, claude

---

## Work Sessions

<!-- Task execution log - updated by /afx:work next, /afx:dev code -->

| Date       | Task               | Action              | Files Modified | Agent  | Human |
| ---------- | ------------------ | ------------------- | -------------- | ------ | ----- |
| 2026-02-26 | 0.1–0.4 Scaffolding | Implemented         | 7 files        | [OK]   |       |
| 2026-02-26 | 1.1–1.5 Parsers    | Implemented         | 5 files        | [OK]   |       |
| 2026-02-26 | 2.1–2.2 Models     | Implemented         | 3 files        | [OK]   |       |
| 2026-02-26 | 3.1–3.7 Tree Views | Implemented         | 5 files        | [OK]   |       |
| 2026-02-26 | 4.1 File Watchers  | Implemented         | 1 file         | [OK]   |       |
| 2026-02-26 | 5.1–5.2 Commands   | Implemented         | 1 file         | [OK]   |       |
| 2026-02-26 | 6.1–6.2, 6.5 Polish | Implemented        | in providers   | [OK]   |       |

---
