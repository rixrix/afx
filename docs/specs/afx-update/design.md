---
afx: true
type: DESIGN
status: Draft
owner: "@rix"
version: 1.0
tags: [afx-update, command-design]
---

# Design: afx-update

> NOTE: This is a living document. Keep this to current-state design only.

## Where This Command Lives

This PRD file does **not** execute commands. It defines behavior to be implemented in command artifacts.

Implementation artifact mapping:

- Claude skill definition (runtime behavior source):
  - `.claude/skills/afx-update.md`
- Agents skill (shared by Codex, Copilot, Antigravity):
  - `.agents/skills/afx-update/SKILL.md`

Execution model:

- User runs `/afx-update ...` (Claude) or `afx-update ...` (Codex).
- Agent reads the skill markdown (`.claude/skills/afx-update.md`) and executes shell steps (`bash`, `curl`) described there.
- `tasks.md` is a planning/verification checklist only; it does not run shell commands.

## Command Surface

### Claude

```bash
/afx-update check [--repo <owner/repo>] [--ref <branch>]
/afx-update apply [--repo <owner/repo>] [--ref <branch>] [--skills-only] [--no-docs] [--no-claude-md] [--no-agents-md] [--with-gemini-md] [--dry-run] [--force] [--yes]
```

### Codex

```bash
afx-update check [same flags]
afx-update apply [same flags]
```

## Behavior Model

### `check`

#### Execution Contract (explicit)

- **Executes shell commands**: Yes (`bash` commands for file reads and comparison)
- **Uses network fetch**: Yes (`curl` to read upstream raw `CHANGELOG.md`)
- **Uses git operations**: No (read-only version check does not require `git fetch/pull`)
- **Writes files**: No (strictly read-only)

#### Step-by-step Runtime

1. Resolve upstream source (default `rixrix/afx@main`, overridable by flags).
2. Resolve local version with this order:
   1. Parse AFX managed marker from `CLAUDE.md` / `AGENTS.md` (`AFX Version: X.Y.Z`) if present.
   2. Fallback: parse latest local semver heading from `CHANGELOG.md`.
3. Fetch upstream `CHANGELOG.md` via:
   - `curl -fsSL https://raw.githubusercontent.com/<repo>/<ref>/CHANGELOG.md`
4. Parse latest upstream semver heading from fetched markdown.
5. Compare versions with semver-aware sort (`sort -V`) and return status:
   - `UP TO DATE`
   - `UPDATE AVAILABLE`
   - `LOCAL AHEAD`
   - `UNKNOWN` (if local version cannot be resolved)
6. Provide ranked next commands.

#### Concrete Command Shape

```bash
# local version (marker first, changelog fallback)
LOCAL_VERSION=$(grep -h "AFX Version:" CLAUDE.md AGENTS.md 2>/dev/null | head -1 | sed -E 's/.*AFX Version: ([^ ]+).*/\1/')
if [ -z "$LOCAL_VERSION" ]; then
  LOCAL_VERSION=$(awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ { gsub(/\[|\]/, "", $2); print $2; exit }' CHANGELOG.md 2>/dev/null)
fi

# upstream version
UPSTREAM_VERSION=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${REF}/CHANGELOG.md" \
  | awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ { gsub(/\[|\]/, "", $2); print $2; exit }')

# comparison
HIGHEST=$(printf "%s\n%s\n" "$LOCAL_VERSION" "$UPSTREAM_VERSION" | sort -V | tail -1)
```

#### Failure Handling (check)

- `curl` fails: return `NETWORK_ERROR` with retry guidance.
- Upstream parse fails: return `UPSTREAM_PARSE_ERROR` with repo/ref hint.
- Local parse fails: continue with `UNKNOWN` status (non-blocking).

### `apply`

1. Resolve upstream source and validated flag set.
2. Execute:
   - `curl -fsSL https://raw.githubusercontent.com/<repo>/<ref>/afx-cli | bash -s -- --update ... .`
3. Surface installer output and final status.
4. Recommend immediate follow-up `check`.

## Safety and Error Handling

- Unknown flag: explicit error and usage reminder.
- Network failure: fail fast with retry suggestion.
- Upstream parse failure: fail with explicit repo/ref hint.
- Installer failure: suggest `--dry-run` and/or scoped update (`--skills-only`).

## Integration Points

- Canonical behavior spec: `skills/agenticflowx/afx-update/SKILL.md`
- Discovery/help/docs updates required:
  - `.claude/skills/afx-help.md`
  - `README.md`
  - `CLAUDE.md`
  - `AGENTS.md`
  - `prompts/agents.md`
  - `docs/agenticflowx/codex.md`
  - `docs/_index.md`
