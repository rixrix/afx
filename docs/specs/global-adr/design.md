---
afx: true
type: DESIGN
status: Draft
owner: "@rix"
version: 1.0
tags: [global-adr, framework, architecture]
---

# Design: global-adr

> NOTE: This is a living document. Do not include historical decisions or abandoned paths here. Keep this factual to the current state.

## Architecture

```
docs/adr/                          # Global ADRs (NEW)
├── ADR-0001-short-slug.md
├── ADR-0002-short-slug.md
└── ...

docs/specs/{feature}/research/     # Feature-local ADRs (EXISTING, unchanged)
├── ADR-001-local-decision.md
└── ...
```

### Config Schema Addition

```yaml
paths:
  adr: "docs/adr" # New field, optional, defaults to 'docs/adr'
```

### `/afx-init adr <title>` Flow

1. Read `paths.adr` from `.afx.yaml` (default: `docs/adr`)
2. Scan directory for highest existing ADR number
3. Increment → `ADR-NNNN`
4. Copy `templates/adr.md`, fill in number, title, date
5. Open for editing

### Installer Changes

- `afx-cli` creates `docs/adr/` alongside `docs/specs/`
- `--update` preserves existing ADRs
- `.afx.yaml.template` gains `paths.adr` field

### Command Awareness

| Command         | Change                                 |
| --------------- | -------------------------------------- |
| `/afx-init`     | New `adr <title>` subcommand           |
| `/afx-next`     | Check for Proposed ADRs needing review |
| `/afx-context`  | Include ADRs in context bundle         |
| `/afx-discover` | List ADR count and latest decisions    |

---

## `/afx-init` Changes

### 1. Usage Block

Add new line:

```bash
/afx-init adr <title>                       # Create numbered ADR in docs/adr/
```

### 2. Next Command Suggestion Table

Add row:

| Context             | Suggested Next Command        |
| ------------------- | ----------------------------- |
| After `adr` created | `Edit docs/adr/ADR-NNNN-*.md` |

### 3. New Subcommand: `## 5. adr`

Create a global architecture decision record.

#### Usage

```bash
/afx-init adr <title>
```

Where `<title>` is a short noun phrase (e.g., "database choice", "api versioning strategy"). Gets kebab-cased into the filename slug.

#### Process

1. Read `paths.adr` from `.afx.yaml` (default: `docs/adr`)
2. Create ADR directory if it doesn't exist
3. Scan directory for highest existing `ADR-NNNN` number
4. Increment → next number, zero-padded to 4 digits
5. Slugify title → kebab-case
6. Copy `templates/adr.md`, fill in: number, title, date, status=Proposed
7. Output confirmation with file path

#### Execution Script

```bash
TITLE="$ARGUMENTS"  # e.g. "database choice"
if [ -z "$TITLE" ]; then echo "Error: Title required"; exit 1; fi

CONFIG=".afx.yaml"
ADR_DIR="docs/adr"  # default
if [ -f "$CONFIG" ]; then
  CONFIGURED=$(grep 'adr:' "$CONFIG" | head -1 | sed "s/.*adr:[[:space:]]*['\"]*//" | sed "s/['\"].*//")
  [ -n "$CONFIGURED" ] && ADR_DIR="$CONFIGURED"
fi

mkdir -p "$ADR_DIR"

# Find next number
LAST=$(ls "$ADR_DIR"/ADR-*.md 2>/dev/null | sed 's/.*ADR-\([0-9]*\).*/\1/' | sort -n | tail -1)
NEXT=$(printf "%04d" $(( ${LAST:-0} + 1 )))

# Slugify title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

DATE=$(date +%Y-%m-%d)
FILE="$ADR_DIR/ADR-${NEXT}-${SLUG}.md"

cat <<EOF > "$FILE"
---
afx: true
type: ADR
status: Proposed
version: 1.0
created: $DATE
owner: '@handle'
tags: [adr]
---

# ADR $NEXT: $TITLE

## Context

{What is the context and problem?}

## Decision

{What is the change?}

## Rationale

{Why this option?}

## Consequences

{What becomes easier or harder?}

## Alternatives Considered

- **{Alternative 1}**: Rejected because {reason}.
EOF

echo "ADR created: $FILE"
```

#### Output

```markdown
## ADR Created: ADR-NNNN-{slug}

**File**: docs/adr/ADR-NNNN-{slug}.md
**Status**: Proposed

Next (ranked):

1. Edit docs/adr/ADR-NNNN-{slug}.md # Fill in context & decision
2. /afx-session note specs "ADR discussion" # Capture related discussion
3. /afx-next # Check project state
```

#### Error Handling

**No title provided:**

```
Error: Title required
Usage: /afx-init adr <title>
Example: /afx-init adr "database choice"
```

**ADR directory not writable:**

```
Error: Cannot write to docs/adr/
Check directory permissions.
```

### 4. Related Commands Table

Add row:

| Command         | Relationship                   |
| --------------- | ------------------------------ |
| `/afx-init adr` | Create global ADR in docs/adr/ |

---

## Data Model

ADR files use existing `templates/adr.md` frontmatter with status lifecycle:

```
Proposed → Accepted → (Deprecated | Superseded)
         → Rejected
```
