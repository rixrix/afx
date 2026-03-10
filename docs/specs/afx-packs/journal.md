---
afx: true
type: JOURNAL
status: Living
owner: "@rix"
tags: [packs, install, skills, ecosystem, journal]
---

# Journal - AFX Pack System

<!-- prefix: PK -->

> Quick captures and discussion history for AI-assisted development sessions.
> See [agenticflowx.md](../../agenticflowx/agenticflowx.md) for workflow.

## Captures

<!-- Quick notes during active chat - cleared when recorded -->

---

## Discussions

<!-- Recorded discussions with IDs: PK-D001, PK-D002, etc. -->
<!-- Chronological order: oldest first, newest last -->

### PK-D001 - 2026-02-28 - Spec Promotion from Research

`status:active` `[product, planning, research]`

**Context**: The pack system design in `res-skills-ecosystem-index.md` (Section 8) and the pack management research in `res-vscode-pack-management.md` reached sufficient maturity. The AFX-side infrastructure (install.sh, pack manifests, index, skills directory) was split into its own spec as the counterpart to the vscode-toolbox UI spec.

**Summary**: Created spec covering 43 functional requirements across 7 areas: pack manifests, pack index, install.sh CLI commands, skill type detection, .afx/ directory structure, .afx.yaml state management, AFX-built skills, and provider copy routing. This is purely the AFX repo infrastructure — the UI consumer is in the vscode-toolbox spec.

**Decisions**:

- Separate spec from vscode-toolbox — this covers AFX repo changes only
- 7 requirement areas: manifests, index, install.sh, type detection, .afx/ structure, .afx.yaml state, AFX-built skills, provider routing
- Current install.sh has zero pack support — all pack commands are net new
- `packs/` and `skills/` directories don't exist yet — both need to be created
- Index schema includes version and changelog (richer than the lean research version) per user edits to toolbox spec
- Open questions: download method (sparse checkout vs tarball), offline install, one-off skill tracking
- Deferred: quality scoring, version pinning

**Notes**:

- **[PK-D001.N1]** **[2026-02-28]** Split from vscode-toolbox spec. AFX-side = install.sh + manifests + index + skills. VSCode-side = Toolbox UI. Both share the same constraints from research. `[product, spec]`
- **[PK-D001.N2]** **[2026-02-28]** User edited vscode-toolbox spec to add version + changelog to index.json schema, resolve OQ#2 (install.sh not available → "Setup AFX" button), remove .afx.local.yaml references from FR-20/AC, add right-click "Preview Changes" to interaction map. These changes reflected in this spec's index schema. `[sync]`

**Related Files**: docs/research/res-skills-ecosystem-index.md, docs/research/res-vscode-pack-management.md, docs/specs/vscode-toolbox/spec.md, install.sh
**Participants**: @rix, claude

### PK-D002 - 2026-02-28 - Phase 1 & 2 Implementation + Antigravity Core Skills

`status:completed` `[implementation, antigravity]`

**Context**: Implementing Phase 1 (Manifests & Index) and Phase 2 (AFX-Built Skills) from the approved spec. During implementation, discovered that `.agent/skills/` (Google Antigravity core skills) was missing from the AFX repo — we had `.claude/commands/`, `.codex/skills/`, `.gemini/commands/`, `.github/prompts/` but no Antigravity equivalent.

**Summary**: Created 3 pack files (2 manifests + 1 index), 16 AFX-built skill files (4 skills × 4 provider variants), 13 Antigravity core skill files (mirroring `.codex/skills/`), and updated `install.sh` to copy `.agent/skills/` as step 3/12.

**Decisions**:

- Antigravity core skills follow same pattern as Codex skills: lightweight SKILL.md wrappers pointing to `.claude/commands/` as source of truth
- No `openai.yaml` equivalent needed for Antigravity (only Codex has that)
- `install.sh` step count: 11 → 12 (added Antigravity between Codex and Gemini)
- `--commands-only` help text updated to include `.agent`
- CLAUDE.md repo structure updated with `.agent/`, `packs/`, `skills/`

**Participants**: @rix, claude

### PK-D003 - 2026-02-28 - Phase 3 & 4 Implementation (install.sh Pack Management)

`status:completed` `[implementation, install.sh, pack-management]`

**Context**: Implementing Phase 3 (Download & Detection) and Phase 4 (State Management) — the full pack management system in install.sh. This is the core CLI infrastructure that the VSCode Toolbox UI will consume.

**Summary**: Added ~1100 lines to install.sh (767 → 1865 lines), implementing 30+ functions covering: argument parsing (14 new flags), manifest fetch via raw.githubusercontent.com, tarball download via codeload.github.com, skill type detection (5 types), item routing to `.afx/packs/{pack}/{provider}/`, name collision detection, gitignore management, bash-only YAML read/write for `.afx.yaml`, pack lifecycle (install/enable/disable/remove), individual skill enable/disable, pack list, bulk update, one-off skill install, and dry-run mode. All verified with `bash -n` — no syntax errors.

**Decisions**:

- Bash-only YAML parsing (grep/sed/awk) — no external dependencies required
- codeload.github.com tarballs for downloads — avoids git dependency
- `.afx/packs/{pack}/{provider}/` as master storage, provider dirs are derived copies
- Dry-run mode threads through all operations via `$DRY_RUN` flag
- Pack operations dispatch before core install logic and `exit 0` — mutually exclusive paths
- Preserved existing `git clone` fallback for remote execution (task 4.10 deferred item)
- `resolve_ref()` handles --version (auto-prefix v), --branch, default main with mutual exclusion

**Notes**:

- **[PK-D003.N1]** **[2026-02-28]** One task item deferred: "Replace git clone fallback with curl + tar for remote execution" (task 4.10, last checkbox). The existing git clone path works and was not touched. `[deferred]`

**Participants**: @rix, claude

### PK-D004 - 2026-02-28 - Canonical SKILL.md Refactor (4× dedup)

`status:completed` `[refactor, skills, install.sh]`

**Context**: User observed that Claude, Codex, Antigravity, and Copilot skill variants were 95% identical — only provider-specific command syntax differed. The 4× file duplication made maintenance harder.

**Summary**: Flattened each skill from 4 provider subdirectories to 1 canonical `SKILL.md` (16 files → 4). Added `transform_for_provider()` and `generate_copilot_agent()` to install.sh with full documentation of sed patterns. Canonical files use `<!-- @afx:provider-commands -->` HTML comment markers to delineate provider-specific command lines. Updated design.md Section 3.7 with transform rules table and sed pattern reference.

**Decisions**:

- Claude format is canonical (uses `/afx:cmd sub` syntax)
- Codex: sed converts `/afx:cmd sub` → `afx-cmd-sub` (kebab-case)
- Antigravity: sed removes entire marked block (generic traceability lines remain)
- Copilot: auto-generated condensed `agent.md` from SKILL.md structure (extracts title, description, instruction items)
- Skills without `/afx:` commands (e.g., afx-spec-test-planning) have no markers — identical across Claude/Codex/Antigravity

**Participants**: @rix, claude

### PK-D005 - 2026-02-28 - Full Test Suite + Bug Fixes

`status:completed` `[testing, bugs, install.sh]`

**Context**: Comprehensive testing of install.sh in `tmp/` covering all scenarios: fresh install, update, commands-only, transform functions, pack management, dry-run, help, and argument parsing.

**Summary**: Ran 8 test suites with 27 transform assertions (all passing). Found and fixed 3 bugs:

1. **Dispatch bug**: `--skill-disable NAME --pack PACK` was triggering `pack_install` because `--pack` was treated as an install target. Fixed by gating pack install on absence of `SKILL_DISABLE`/`SKILL_ENABLE`.
2. **resolve_ref exit propagation**: `local ref=$(resolve_ref)` masked the exit code because `local` always returns 0 (bash gotcha). Fixed by separating declaration from assignment: `local ref; ref=$(resolve_ref) || exit 1`.
3. **generate_copilot_agent description extraction**: `sed` range `/^# /,/^$/` captured heading-to-blank but description is AFTER the blank. Fixed with `awk 'NR>1 && /^[^#]/ && !/^$/ { print; exit }'`.

**Notes**:

- **[PK-D005.N1]** **[2026-02-28]** Pack install fails on network (expected — manifests not pushed to GitHub yet). Tested with simulated `.afx/` structure for enable/disable/remove/list. `[expected]`
- **[PK-D005.N2]** **[2026-02-28]** `.codex/skills/` is for AFX command wrappers only. Pack skills go to `.agents/skills/` (Codex/OpenAI runtime convention). Test fixture initially used wrong dir. `[clarification]`

**Participants**: @rix, claude

---

## Approval: Spec Approved (2026-02-28 04:35 UTC)

Spec approved and frozen. Further changes require version bump.

Approved by: Gemini Code Assist (automated validation)
Review score: 100% compliant

Validation Summary:

- Structure: All required sections present
- Frontmatter: Valid
- Quality: 0 Critical issues

Next step: Create design PRD.

---
