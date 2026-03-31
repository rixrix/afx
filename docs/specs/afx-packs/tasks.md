---
afx: true
type: TASKS
status: Living
owner: "@rix"
version: "1.0"
created_at: "2026-02-28T00:00:00.000Z"
updated_at: "2026-02-28T00:00:00.000Z"
tags: [packs, install, skills, ecosystem]
spec: spec.md
design: design.md
---

# AFX Pack System - Implementation Tasks

---

## Task Numbering Convention

Tasks use hierarchical numbering for cross-referencing:

- **1.x** - Phase 1: Manifests & Index (static files in AFX repo)
- **2.x** - Phase 2: AFX-Built Skills (guardrails skills in AFX repo)
- **3.x** - Phase 3: afx-cli — Download & Detection (new functions)
- **4.x** - Phase 4: afx-cli — State Management (lifecycle commands)

References:

- `[FR-N]` = Functional Requirement N from spec.md
- `[DESIGN-X.X]` = Section X.X from design.md

---

## Phase 1: Manifests & Index

> Ref: [DESIGN-1.1], [DESIGN-1.2], [FR-1] through [FR-12]

### 1.1 Create Pack Directory & QA Manifest

> File: `packs/afx-pack-qa.yaml`

- [x] Create `packs/` directory in AFX repo root `[FR-1]`
- [x] Author `packs/afx-pack-qa.yaml` with full manifest schema `[FR-2] [FR-3]`
- [x] Define `platforms:` field — `claude: true`, `codex: true`, `antigravity: true`, `copilot: partial` `[FR-5]`
- [x] Add `includes[]` entries for Antigravity skills (7 items) `[FR-4]`
- [x] Add `includes[]` entry for OpenAI skills (playwright) `[FR-4]`
- [x] Add `includes[]` entry for Claude Code plugins (code-review, pr-review-toolkit) `[FR-4]`
- [x] Add `includes[]` entry for AFX-built skills (afx-qa-methodology, afx-spec-test-planning) `[FR-4] [FR-37]`
- [x] Verify manifest matches design Section 1.1 QA manifest schema `[FR-7]`

### 1.2 Create Security Pack Manifest

> File: `packs/afx-pack-security.yaml`

- [x] Author `packs/afx-pack-security.yaml` with full manifest schema `[FR-2] [FR-3]`
- [x] Define `platforms:` — `claude: true`, `codex: true`, `antigravity: true`, `copilot: partial` `[FR-5]`
- [x] Add `includes[]` for Antigravity security skills (3 items) `[FR-4]`
- [x] Add `includes[]` for Claude Code security-scanner plugin `[FR-4]`
- [x] Add `includes[]` for AFX-built skills (afx-owasp-top-10, afx-security-audit) `[FR-4] [FR-37]`

### 1.3 Create Pack Index

> File: `packs/index.json`

- [x] Create `packs/index.json` with `packs` and `upstream` sections `[FR-8]`
- [x] Add pack entries: description, category, providers array `[FR-9]`
- [x] Add upstream entries: provider repos with `featured[]` lists `[FR-10]`
- [ ] Verify index is fetchable via `raw.githubusercontent.com` (push and test URL) `[FR-11]`
- [x] Document manual update process (updated alongside manifest changes) `[FR-12]`

---

## Phase 2: AFX-Built Skills

> Ref: [DESIGN-4.1], [DESIGN-4.2], [FR-35] through [FR-38]

### 2.1 Create Skills Directory Structure

> Directory: `skills/`

- [x] Create `skills/` directory in AFX repo root `[FR-35]`
- [x] Establish provider subdirectory convention per skill: `{skill}/claude/skills/{skill}/`, `{skill}/codex/skills/{skill}/`, `{skill}/antigravity/skills/{skill}/`, `{skill}/copilot/agents/` `[FR-36]`

### 2.2 Author `afx-qa-methodology`

> Directory: `skills/afx-qa-methodology/`

- [x] Create Claude variant: `claude/skills/afx-qa-methodology/SKILL.md` `[FR-36]`
- [x] Create Codex variant: `codex/skills/afx-qa-methodology/SKILL.md` `[FR-36]`
- [x] Create Antigravity variant: `antigravity/skills/afx-qa-methodology/SKILL.md` `[FR-36]`
- [x] Create Copilot variant: `copilot/agents/afx-qa-methodology.agent.md` `[FR-36]`
- [x] Include guardrails: @see tracing, two-stage verification, spec-driven test strategy `[FR-38]`
- [x] Verify content matches design Section 4.1 `[DESIGN-4.1]`

### 2.3 Author `afx-spec-test-planning`

> Directory: `skills/afx-spec-test-planning/`

- [x] Create Claude variant: `claude/skills/afx-spec-test-planning/SKILL.md` `[FR-36]`
- [x] Create Codex variant: `codex/skills/afx-spec-test-planning/SKILL.md` `[FR-36]`
- [x] Create Antigravity variant: `antigravity/skills/afx-spec-test-planning/SKILL.md` `[FR-36]`
- [x] Create Copilot variant: `copilot/agents/afx-spec-test-planning.agent.md` `[FR-36]`
- [x] Include guardrails: requirement-to-test mapping, gap detection, @see annotations `[FR-38]`
- [x] Verify content matches design Section 4.2 `[DESIGN-4.2]`

### 2.4 Author `afx-owasp-top-10`

> Directory: `skills/afx-owasp-top-10/`

- [x] Create Claude variant: `claude/skills/afx-owasp-top-10/SKILL.md` `[FR-36]`
- [x] Create Codex variant: `codex/skills/afx-owasp-top-10/SKILL.md` `[FR-36]`
- [x] Create Antigravity variant: `antigravity/skills/afx-owasp-top-10/SKILL.md` `[FR-36]`
- [x] Create Copilot variant: `copilot/agents/afx-owasp-top-10.agent.md` `[FR-36]`
- [x] Include guardrails: OWASP top 10 checklist with @see tracing `[FR-38]`

### 2.5 Author `afx-security-audit`

> Directory: `skills/afx-security-audit/`

- [x] Create Claude variant: `claude/skills/afx-security-audit/SKILL.md` `[FR-36]`
- [x] Create Codex variant: `codex/skills/afx-security-audit/SKILL.md` `[FR-36]`
- [x] Create Antigravity variant: `antigravity/skills/afx-security-audit/SKILL.md` `[FR-36]`
- [x] Create Copilot variant: `copilot/agents/afx-security-audit.agent.md` `[FR-36]`
- [x] Include guardrails: security audit workflow with @see tracing `[FR-38]`

---

## Phase 3: afx-cli — Download & Detection

> Ref: [DESIGN-3.1] through [DESIGN-3.8], [FR-13], [FR-24a/b], [FR-34], [FR-25] through [FR-31], [FR-44], [FR-45]

### 3.1 Argument Parsing

> File: `afx-cli`

- [x] Add `--pack NAME` flag (repeatable for multiple packs) `[FR-13] [FR-14]`
- [x] ~~Add `--pack-disable NAME` flag `[FR-15]`~~ — Removed
- [x] ~~Add `--pack-enable NAME` flag `[FR-16]`~~ — Removed
- [x] Add `--pack-remove NAME` flag `[FR-17]`
- [x] Add `--pack-list` flag `[FR-18]`
- [x] Add `--skill-disable NAME --pack PACK` flag combination `[FR-19]`
- [x] Add `--skill-enable NAME --pack PACK` flag combination `[FR-20]`
- [x] Add `--update --packs` flag combination `[FR-21]`
- [x] Add `--add-skill REPO:PATH/SKILL` flag `[FR-23]`
- [x] Add `--branch NAME` flag (default: `main`) `[FR-24a]`
- [x] Add `--version TAG` flag (auto-prefix `v` if missing) `[FR-24b]`
- [x] Validate `--version` and `--branch` are mutually exclusive `[FR-24a] [FR-24b]`
- [x] Ensure `--dry-run` works with all pack flags `[FR-22]`
- [x] Verify existing flags still parse correctly `[NFR-1]` `[DESIGN-3.3]`

### 3.2 Manifest Fetch

> File: `afx-cli` — `fetch_manifest()` function

- [x] Implement `fetch_manifest()` — fetch YAML manifest from `raw.githubusercontent.com` `[DESIGN-3.4]`
- [x] Resolve ref: `--version` → `v{tag}`, `--branch` → `{branch}`, default → `main`
- [x] Auto-prefix `afx-pack-` if user provides short name (e.g., `qa` → `afx-pack-qa`) `[DESIGN-3.4]`
- [x] Parse YAML manifest with bash (field extraction) `[DESIGN-3.4]`

### 3.3 Download Items

> File: `afx-cli` — `download_items()` function

- [x] Implement `download_items()` — download via `codeload.github.com` tarballs `[NFR-2]`
- [x] Extract specific `path/items[]` from tarball using `tar --strip-components` `[DESIGN-3.5]`
- [x] Handle multiple repos per manifest (Antigravity, OpenAI, Claude Code, AFX) `[FR-4]`
- [x] Clean up temp directories on success and failure (trap handler) `[DESIGN-6]`
- [x] Verify only `curl`, `tar`, `bash` are used — no git, node, python `[NFR-5]`

### 3.4 Skill Type Detection

> File: `afx-cli` — `detect_type()` function

- [x] Implement `detect_type()` with detection rules `[DESIGN-3.6]`
- [x] Detect Simple Skill: `SKILL.md` at root, no `.claude-plugin/` → Claude + Codex + Antigravity `[FR-34]`
- [x] Detect Claude Plugin: `.claude-plugin/plugin.json` exists → Claude only `[FR-25]`
- [x] Detect OpenAI Skill: `SKILL.md` + `agents/openai.yaml` → Codex only `[FR-26]`
- [x] Detect AFX-built: from `rixrix/afx` repo → pre-organized by provider `[FR-42]`
- [x] Ensure external skills are never modified during detection `[FR-27]`

### 3.5 Item Routing

> File: `afx-cli` — `route_item()` function

- [x] Implement `route_item()` — route detected items to `.afx/packs/{pack}/{provider}/` `[DESIGN-3.7]`
- [x] Simple Skills → `claude/skills/{name}/` AND `codex/skills/{name}/` AND `antigravity/skills/{name}/` `[FR-39]`
- [x] Claude Plugins → `claude/plugins/{name}/` `[FR-40]`
- [x] OpenAI Skills → `codex/skills/{name}/` `[FR-41]`
- [x] AFX-built → copy pre-organized provider dirs as-is `[FR-42]`
- [x] Copilot receives only AFX-built skills `[FR-43]`
- [x] Gate routing on manifest `platforms:` field — skip providers marked `false` or missing `[FR-45]`
- [x] Create `.afx/packs/{pack}/{provider}/` directory structure `[FR-28] [FR-29]`

### 3.6 Name Collision Detection

> File: `afx-cli` — `check_collision()` function

- [x] Implement `check_collision()` — check if destination already owned by another pack `[FR-44]`
- [x] Scan provider directories for existing items before copy `[DESIGN-3.8]`
- [x] Fail with error message identifying the conflicting pack `[FR-44]`
- [x] Allow override with `--force` flag `[DESIGN-3.8]`

### 3.7 Gitignore Management

> File: `afx-cli` — `ensure_gitignore()` function

- [x] Implement `ensure_gitignore()` — add `.afx/` to `.gitignore` `[FR-31] [NFR-7]`
- [x] Only add if not already present `[NFR-6]`
- [x] Create `.gitignore` if it doesn't exist `[DESIGN-3.9]`

---

## Phase 4: afx-cli — State Management

> Ref: [DESIGN-3.10] through [DESIGN-3.13], [FR-14] through [FR-23], [FR-32], [FR-33]

### 4.1 YAML Read/Write Helpers

> File: `afx-cli`

- [x] Implement `afx_yaml_get_pack()` — read pack status from `.afx.yaml` `[DESIGN-3.11]`
- [x] Implement `afx_yaml_set_pack()` — write/update pack entry with name, status, installed_ref `[DESIGN-3.11]`
- [x] Implement `afx_yaml_remove_pack()` — remove pack entry from `.afx.yaml` `[DESIGN-3.11]`
- [x] Implement `afx_yaml_get_disabled_items()` — read disabled items list `[DESIGN-3.11]`
- [x] Implement `afx_yaml_set_disabled_items()` — write disabled items list `[DESIGN-3.11]`
- [x] Handle missing `.afx.yaml` gracefully (create packs section on first install) `[FR-32]`

### 4.2 Pack Install Flow

> File: `afx-cli` — `pack_install()` function

- [x] Implement `pack_install()` orchestrating: fetch manifest → download → detect → route → copy → state `[FR-13]`
- [x] Support multiple packs in one command (`--pack qa --pack security`) `[FR-14]`
- [x] Record pack in `.afx.yaml` with `status: enabled`, `installed_ref`, `disabled_items: []` `[FR-32]`
- [x] Resolve `installed_ref` from `--version`, `--branch`, or default `main` `[FR-32]`
- [x] Create `.afx/.cache/` directory `[FR-31]`

### 4.3 Provider Copy Management

> File: `afx-cli` — `pack_copy_to_providers()` / `pack_remove_from_providers()` functions

- [x] Implement `pack_copy_to_providers()` — `cp -r` from `.afx/` master to provider dirs `[FR-16] [DESIGN-3.12]`
- [x] Copy to `.claude/skills/`, `.claude/plugins/`, `.agents/skills/`, `.github/agents/` as appropriate `[FR-39] [FR-40] [FR-41] [FR-43]`
- [x] Implement `pack_remove_from_providers()` — remove provider copies by pack `[FR-15] [DESIGN-3.12]`
- [x] Ensure enable/disable is instant — no network, no conversion `[NFR-3]`

### 4.4 Pack Enable / Disable / Remove

> File: `afx-cli`

- [x] Implement `pack_disable()` — remove provider copies, keep `.afx/` master, update status to `disabled` `[FR-15]`
- [x] Implement `pack_enable()` — copy from `.afx/` master to providers, update status to `enabled` `[FR-16]`
- [x] Implement `pack_remove()` — delete `.afx/packs/{pack}/` AND provider copies, remove from `.afx.yaml` `[FR-17]`
- [x] Skip disabled items during enable (respect `disabled_items[]`) `[FR-19]`

### 4.5 Skill Disable / Enable

> File: `afx-cli`

- [x] Implement `skill_disable()` — remove skill from provider dirs, add to `disabled_items` `[FR-19]`
- [x] Implement `skill_enable()` — restore from `.afx/` master, remove from `disabled_items` `[FR-20]`
- [x] Check for name collisions when re-enabling `[FR-44]`

### 4.6 Pack List

> File: `afx-cli` — `pack_list()` function

- [x] Implement `pack_list()` — read `.afx.yaml` and output packs with status `[FR-18]`
- [x] Show: name, status (enabled/disabled), installed ref, disabled item count

### 4.7 Pack Update

> File: `afx-cli` — `pack_update_all()` function

- [x] Implement `pack_update_all()` — re-download and replace items for all enabled packs `[FR-21]`
- [x] Preserve `disabled_items[]` across update `[FR-21]`
- [x] Update `installed_ref` in `.afx.yaml` after successful update
- [x] Skip disabled packs during update

### 4.8 One-Off Skill Install

> File: `afx-cli`

- [x] Parse `--add-skill REPO:PATH/SKILL` format `[FR-23]`
- [x] Download single skill via tarball extraction `[FR-23]`
- [x] Type-detect and route directly to provider dirs (no `.afx/packs/` master) `[FR-23]`
- [x] Track in `.afx.yaml` under `custom_skills:` with `repo` and `path` `[FR-33]`
- [x] Ensure `--update --packs` does NOT update custom skills `[FR-33]`

### 4.9 Dry Run

> File: `afx-cli`

- [x] Implement dry-run mode for all pack operations `[FR-22]`
- [x] Print what would be changed without writing any files `[FR-22]`
- [x] Support `--dry-run --pack`, `--dry-run --pack-remove`, etc.

### 4.10 Main Dispatch & Help

> File: `afx-cli`

- [x] Add main dispatch logic routing pack flags to functions `[DESIGN-3.13]`
- [x] Update `--help` output with pack management section `[DESIGN-5.3]`
- [x] Ensure `./afx-cli .` (no pack flags) works exactly as before `[NFR-1]`
- [x] Ensure `./afx-cli --update .` works exactly as before `[NFR-1]`
- [x] Ensure all existing flags (`--skills-only`, `--no-claude-md`, `--force`, etc.) continue to work `[NFR-1]`
- [x] Verify all pack operations are idempotent `[NFR-6]`
- [ ] Replace `git clone` fallback with `curl` + `tar` for remote execution `[DESIGN-7]`

---

## Implementation Flow

```
Phase 1: Manifests & Index (static YAML/JSON files)
    ↓
Phase 2: AFX-Built Skills (SKILL.md / .agent.md files)
    ↓
Phase 3: afx-cli — Download & Detection (new functions)
    ↓
Phase 4: afx-cli — State Management (lifecycle commands)
```

---

## Cross-Reference Index

| Task | Spec Requirements                  | Design Section |
| ---- | ---------------------------------- | -------------- |
| 1.1  | FR-1, FR-2, FR-3, FR-4, FR-5, FR-7 | 1.1            |
| 1.2  | FR-2, FR-3, FR-4, FR-5             | 1.1            |
| 1.3  | FR-8, FR-9, FR-10, FR-11, FR-12    | 1.2            |
| 2.1  | FR-35, FR-36, FR-37                | 4              |
| 2.2  | FR-36, FR-38                       | 4.1            |
| 2.3  | FR-36, FR-38                       | 4.2            |
| 2.4  | FR-36, FR-38                       | 4              |
| 2.5  | FR-36, FR-38                       | 4              |
| 3.1  | FR-13–FR-24b, NFR-1                | 3.3            |
| 3.2  | FR-13                              | 3.4            |
| 3.3  | FR-4, NFR-2, NFR-5                 | 3.5            |
| 3.4  | FR-34, FR-25, FR-26, FR-27         | 3.6            |
| 3.5  | FR-28, FR-29, FR-39–FR-43, FR-45   | 3.7            |
| 3.6  | FR-44                              | 3.8            |
| 3.7  | FR-31, NFR-7                       | 3.9            |
| 4.1  | FR-32                              | 3.11           |
| 4.2  | FR-13, FR-14, FR-32                | 3.10           |
| 4.3  | FR-15, FR-16, FR-39–FR-43          | 3.12           |
| 4.4  | FR-15, FR-16, FR-17                | 3.10           |
| 4.5  | FR-19, FR-20, FR-44                | 3.10           |
| 4.6  | FR-18                              | 3.10           |
| 4.7  | FR-21                              | 3.10           |
| 4.8  | FR-23, FR-33                       | 3.10           |
| 4.9  | FR-22                              | 3.10           |
| 4.10 | NFR-1, NFR-6                       | 3.13, 5        |

---

## Notes

- Phases 1 and 2 are independent and can be worked in parallel
- Phase 3 must complete before Phase 4 (state management depends on download + detection)
- Tasks within each phase are ordered by dependency — work top to bottom
- Backward compatibility verification (4.10) should be the final gate before merge

---

## Work Sessions

<!-- Task execution log — updated by /afx-task pick, /afx-task code -->

| Date       | Task    | Action            | Files Modified                                                                | Agent | Human |
| ---------- | ------- | ----------------- | ----------------------------------------------------------------------------- | ----- | ----- |
| 2026-02-28 | 1.1     | /afx-dev code     | packs/afx-pack-qa.yaml                                                        | [x]   |       |
| 2026-02-28 | 1.2     | /afx-dev code     | packs/afx-pack-security.yaml                                                  | [x]   |       |
| 2026-02-28 | 1.3     | /afx-dev code     | packs/index.json                                                              | [x]   |       |
| 2026-02-28 | 2.1     | /afx-dev code     | skills/ (4 skill dirs × 4 providers)                                          | [x]   |       |
| 2026-02-28 | 2.2     | /afx-dev code     | skills/afx-qa-methodology/ (4 variants)                                       | [x]   |       |
| 2026-02-28 | 2.3     | /afx-dev code     | skills/afx-spec-test-planning/ (4 variants)                                   | [x]   |       |
| 2026-02-28 | 2.4     | /afx-dev code     | skills/afx-owasp-top-10/ (4 variants)                                         | [x]   |       |
| 2026-02-28 | 2.5     | /afx-dev code     | skills/afx-security-audit/ (4 variants)                                       | [x]   |       |
| 2026-02-28 | —       | /afx-dev code     | .agent/skills/ (13 core AFX skills)                                           | [x]   |       |
| 2026-02-28 | —       | /afx-dev code     | afx-cli (add Antigravity step 3/12)                                           | [x]   |       |
| 2026-02-28 | —       | /afx-dev code     | CLAUDE.md (.agent/ + packs/ + skills/)                                        | [x]   |       |
| 2026-02-28 | 3.1     | /afx-dev code     | afx-cli (14 new case entries, help text)                                      | [x]   |       |
| 2026-02-28 | 3.2     | /afx-dev code     | afx-cli (resolve_ref, fetch_manifest)                                         | [x]   |       |
| 2026-02-28 | 3.3     | /afx-dev code     | afx-cli (download_items, for_each_include)                                    | [x]   |       |
| 2026-02-28 | 3.4     | /afx-dev code     | afx-cli (detect_type — 5 type rules)                                          | [x]   |       |
| 2026-02-28 | 3.5     | /afx-dev code     | afx-cli (route_item, platform_enabled)                                        | [x]   |       |
| 2026-02-28 | 3.6     | /afx-dev code     | afx-cli (check_collision)                                                     | [x]   |       |
| 2026-02-28 | 3.7     | /afx-dev code     | afx-cli (ensure_gitignore)                                                    | [x]   |       |
| 2026-02-28 | 4.1     | /afx-dev code     | afx-cli (6 afx*yaml*\* helpers)                                               | [x]   |       |
| 2026-02-28 | 4.2     | /afx-dev code     | afx-cli (pack_install orchestrator)                                           | [x]   |       |
| 2026-02-28 | 4.3     | /afx-dev code     | afx-cli (pack_copy/remove_from_providers)                                     | [x]   |       |
| 2026-02-28 | 4.4     | /afx-dev code     | afx-cli (pack_enable, pack_disable, pack_remove)                              | [x]   |       |
| 2026-02-28 | 4.5     | /afx-dev code     | afx-cli (skill_disable, skill_enable)                                         | [x]   |       |
| 2026-02-28 | 4.6     | /afx-dev code     | afx-cli (pack_list)                                                           | [x]   |       |
| 2026-02-28 | 4.7     | /afx-dev code     | afx-cli (pack_update_all)                                                     | [x]   |       |
| 2026-02-28 | 4.8     | /afx-dev code     | afx-cli (add_skill — one-off install)                                         | [x]   |       |
| 2026-02-28 | 4.9     | /afx-dev code     | afx-cli (dry-run for all pack ops)                                            | [x]   |       |
| 2026-02-28 | 4.10    | /afx-dev code     | afx-cli (main dispatch, help, bash -n pass)                                   | [x]   |       |
| 2026-02-28 | 2.1–2.5 | /afx-dev refactor | skills/ (4×4 provider dirs → 4 canonical SKILL.md)                            | [x]   |       |
| 2026-02-28 | 3.5     | /afx-dev refactor | afx-cli (transform_for_provider, generate_copilot_agent, route_item afx case) | [x]   |       |
| 2026-02-28 | —       | /afx-dev code     | design.md (Section 3.7 rewrite: canonical + transform docs)                   | [x]   |       |
| 2026-02-28 | —       | /afx-dev test     | afx-cli (8 test suites, 27 transform tests, 3 bugs fixed)                     | [x]   |       |
