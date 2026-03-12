---
afx: true
type: COMMAND
status: Living
tags: [afx, command, update, maintenance]
---

# /afx:update

Check for upstream AFX updates and apply them safely.

## Configuration

Read config using two-tier resolution: `.afx/.afx.yaml` (managed defaults) + `.afx.yaml` (user overrides). Use defaults when neither exists:

- upstream repo: `rixrix/afx`
- upstream ref: `main`

## Usage

```bash
/afx:update check [--repo <owner/repo>] [--ref <branch>]
/afx:update apply [--repo <owner/repo>] [--ref <branch>] [--commands-only] [--no-docs] [--no-claude-md] [--no-agents-md] [--dry-run] [--force]
```

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx:update` action, suggest the most appropriate next command:

| Context                          | Suggested Next Command                 |
| -------------------------------- | -------------------------------------- |
| After `check` (update available) | `/afx:update apply`                    |
| After `check` (up to date)       | `/afx:help`                            |
| After `apply` (success)          | `/afx:update check`                    |
| After `apply` (error)            | `/afx:update apply --dry-run`          |
| After `apply` (major changes)    | `/afx:check links <spec-path>`         |

---

## Subcommands

---

## 1. check

Check local AFX version against upstream.

### Execution Contract

- Uses shell commands: Yes
- Uses network: Yes (`curl`)
- Uses git operations: No
- Writes files: No

### Process

Run:

```bash
REPO="rixrix/afx"
REF="main"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --ref) REF="$2"; shift 2 ;;
    *) shift ;;
  esac
done

LOCAL_VERSION=$(grep -h "AFX Version:" CLAUDE.md AGENTS.md 2>/dev/null | head -1 | sed -E 's/.*AFX Version: ([^ ]+).*/\1/')
if [ "$LOCAL_VERSION" = "Unknown" ]; then
  LOCAL_VERSION=""
fi
if [ -z "$LOCAL_VERSION" ]; then
  LOCAL_VERSION=$(awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ { gsub(/\[|\]/, "", $2); print $2; exit }' CHANGELOG.md 2>/dev/null)
fi

UPSTREAM_VERSION=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/${REF}/CHANGELOG.md" \
  | awk '/^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ { gsub(/\[|\]/, "", $2); print $2; exit }')

if [ -z "$UPSTREAM_VERSION" ]; then
  echo "Status: UPSTREAM_PARSE_ERROR"
  exit 1
fi

if [ -z "$LOCAL_VERSION" ]; then
  echo "Local version: Unknown"
  echo "Upstream version: $UPSTREAM_VERSION"
  echo "Status: UNKNOWN"
  exit 0
fi

if [ "$LOCAL_VERSION" = "$UPSTREAM_VERSION" ]; then
  echo "Local version: $LOCAL_VERSION"
  echo "Upstream version: $UPSTREAM_VERSION"
  echo "Status: UP TO DATE"
  exit 0
fi

HIGHEST=$(printf "%s\n%s\n" "$LOCAL_VERSION" "$UPSTREAM_VERSION" | sort -V | tail -1)
if [ "$HIGHEST" = "$UPSTREAM_VERSION" ]; then
  echo "Local version: $LOCAL_VERSION"
  echo "Upstream version: $UPSTREAM_VERSION"
  echo "Status: UPDATE AVAILABLE"
else
  echo "Local version: $LOCAL_VERSION"
  echo "Upstream version: $UPSTREAM_VERSION"
  echo "Status: LOCAL AHEAD"
fi
```

### Next Command

```text
Next (ranked):
  1. /afx:update apply
  2. /afx:update apply --dry-run
  3. /afx:help
  4. /afx:check links <spec-path>
  5. /afx:next
```

---

## 2. apply

Apply updates using upstream installer in update mode.

### Process

Run:

```bash
REPO="rixrix/afx"
REF="main"
EXTRA_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --ref) REF="$2"; shift 2 ;;
    --commands-only|--no-docs|--no-claude-md|--no-agents-md|--dry-run|--force)
      EXTRA_ARGS+=("$1")
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

curl -fsSL "https://raw.githubusercontent.com/${REPO}/${REF}/install.sh" \
  | bash -s -- --update "${EXTRA_ARGS[@]}" .
```

### Next Command

```text
Next (ranked):
  1. /afx:update check
  2. /afx:help
  3. /afx:check links <spec-path>
  4. /afx:next
  5. /afx:session save "AFX updated"
```
