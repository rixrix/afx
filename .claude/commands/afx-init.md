---
afx: true
type: COMMAND
status: Living
tags: [afx, command, init, scaffolding]
---

# /afx:init

Feature spec scaffolding for AgenticFlowX projects.

## Configuration

**Read `.afx.yaml`** at project root to resolve paths:

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `paths.adr` - Where global ADRs live (default: `docs/adr`)
- `paths.templates` - Where templates live (default: `docs/agenticflowx/templates`)

If `.afx.yaml` doesn't exist, use defaults.

## Usage

```bash
/afx:init feature <name>                    # Create new feature spec
/afx:init feature <name> --from <template>  # Create from existing template
/afx:init adr <title>                       # Create numbered ADR in docs/adr/
/afx:init template <name>                   # Create reusable template from feature
/afx:init prefix <feature> <prefix>         # Set discussion ID prefix
/afx:init config <action> <key> [value]     # Manage .afx.yaml config
```

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx:init` action, suggest the most appropriate next command:

| Context                  | Suggested Next Command                |
| ------------------------ | ------------------------------------- |
| After `feature` created  | `/afx:spec show <name>`               |
| After `adr` created      | `Edit docs/adr/ADR-NNNN-*.md`         |
| After `template` created | `/afx:init feature --from <template>` |
| After `prefix` set       | `/afx:session capture <feature>`      |

**Suggestion Format** (5 ranked options):

```
Next (ranked):
  1. /afx:spec show {feature}                # View spec overview
  2. Edit docs/specs/{feature}/spec.md       # Define requirements
  3. Edit docs/specs/{feature}/design.md     # Plan architecture
  4. /afx:work plan                          # Generate tasks from spec
  5. /afx:session capture {feature} "note"   # Capture initial ideas
```

---

## Subcommands

---

## 1. feature

Create a new feature spec with full directory structure.

### Usage

```bash
/afx:init feature <name>
/afx:init feature <name> --from <template>
```

### Smart Init Protocol (MANDATORY)

**STOP! Do not run the scaffold script yet.**

Before creating any files, you MUST perform this interactive analysis:

#### Phase 1: Context Scan

1.  **Search Codebase**: `grep -r "{feature-name}" src/ packages/` (Check for existing code/collisions).
2.  **Search Specs**: `ls docs/specs/` (Check for related features).
3.  **Identify Dependencies**: Does this feature likely need `auth`, `payment`, `notification`?

#### Phase 2: Clarification

Ask the user **at least 2** strategic questions based on Phase 1:

- "Is this a UI-only feature or full-stack?"
- "I found 'X' in the codebase—should this integrate with it?"
- "What is the primary user goal?"

#### Phase 3: Proposal

Summarize your understanding:

> "This looks like a _[Size]_ feature. I will scaffold it in `docs/specs/{name}`. I see potential integration with _[Module]_."

#### Phase 4: Execution (Scaffold)

Only AFTER user confirms, run the script below.

---

### Phase 4: Execution Script

Run this inline script to generate the scaffold:

```bash
FEATURE="$ARGUMENTS" # e.g. "shopping-cart"
if [ -z "$FEATURE" ]; then echo "Error: Name required"; exit 1; fi

SPEC_DIR="docs/specs/$FEATURE"
if [ -d "$SPEC_DIR" ]; then echo "Error: $FEATURE exists"; exit 1; fi

mkdir -p "$SPEC_DIR/research"
DATE=$(date +%Y-%m-%d)
PREFIX=$(echo "$FEATURE" | awk -F- '{print toupper(substr($1,0,1) substr($2,0,1))}')
[ ${#PREFIX} -lt 2 ] && PREFIX=$(echo "$FEATURE" | awk '{print toupper(substr($0,0,2))}')

# 1. SPEC
cat <<EOF > "$SPEC_DIR/spec.md"
# Requirements: $FEATURE

## Functional Requirements

| ID | Requirement | Priority |
| -- | ----------- | -------- |
| FR-1 | ... | P1 |

## Non-Functional Requirements

| ID | Requirement | Priority |
| -- | ----------- | -------- |
| NFR-1 | ... | P1 |
EOF

# 2. DESIGN
cat <<EOF > "$SPEC_DIR/design.md"
# Design: $FEATURE

> NOTE: This is a living document. Do not include historical decisions or abandoned paths here. Keep this factual to the current state.

## Architecture

\`\`\`mermaid
graph TD
    User --> UI
\`\`\`

## Data Model

## API
EOF

# 3. TASKS
cat <<EOF > "$SPEC_DIR/tasks.md"
# Tasks: $FEATURE

## Phase 1: Core

- [ ] Task 1.1
EOF

# 4. JOURNAL
cat <<EOF > "$SPEC_DIR/journal.md"
---
afx: true
type: JOURNAL
status: Living
tags: [$FEATURE, journal]
---

# Journal - $FEATURE

<!-- prefix: $PREFIX -->

> Quick captures and discussion history.
> NOTE: This is an append-only log. All architectural decisions, failed experiments, and historical context go here.

## Captures
---

## Discussions
---

## Work Sessions
| Date | Task | Action | Files Modified | Agent | Human |
| ---- | ---- | ------ | -------------- | ----- | ----- |
EOF

echo "Feature '$FEATURE' initialized at $SPEC_DIR"
```

### Output

```markdown
## Feature Created: {name}

**Location**: docs/specs/{name}/
**Prefix**: {XX} (for discussion IDs)

### Files Created

- spec.md - Requirements (edit first)
- design.md - Technical architecture
- tasks.md - Implementation tasks
- journal.md - Discussion capture
- research/ - ADRs directory

Next (ranked):

1. /afx:spec show {name} # View spec overview
2. Edit docs/specs/{name}/spec.md # Define requirements first
3. Edit docs/specs/{name}/design.md # Plan architecture
4. /afx:work plan # Generate tasks from spec
5. /afx:session capture {name} "note" # Capture initial ideas
```

### Template Files

Use templates from `docs/agenticflowx/templates/`:

```bash
docs/agenticflowx/templates/
├── spec.md
├── design.md
├── tasks.md
└── adr.md
```

---

## 2. template

Create a reusable template from an existing feature spec.

### Usage

```bash
/afx:init template <name>
```

### Process

1. **Select source feature**: Prompt if not obvious from context
2. **Copy to templates**: `docs/agenticflowx/templates/<name>/`
3. **Anonymize**: Replace feature-specific names with `{feature}` placeholders

### Templating Validation

- [ ] **Config Check**: Read `.afx.yaml` to resolve context paths (`proposals`, `research`, etc.)
- [ ] **Path Resolution**: Update relative links in `spec.md` references to match configured paths
- [ ] **Placeholders**: Ensure `{feature}` is replaced in all filenames and content
- [ ] **Links**: Verify links to `../../agenticflow/agenticflowx.md` are correct for this depth

4. **Document**: Add template description

### Output

```markdown
## Template Created: {name}

**Source**: docs/specs/{source-feature}/
**Location**: docs/specs/\_templates/{name}/

Use with:
/afx:init feature new-feature --from {name}

Next: /afx:init feature <name> --from {name}
```

---

## 3. prefix

Set or update the discussion ID prefix for a feature.

### Usage

```bash
/afx:init prefix <feature> <prefix>
```

### Process

1. **Validate prefix**: 2-4 uppercase characters
2. **Check conflicts**: Ensure no other feature uses this prefix
3. **Update journal.md**: Set `<!-- prefix: XX -->` comment

### Prefix Rules

- 2-4 uppercase characters
- Derived from feature name (abbreviation)
- Must be globally unique

### Common Prefixes

| Feature             | Prefix |
| ------------------- | ------ |
| `_sessions`         | `GEN`  |
| `user-auth`         | `UA`   |
| `users-permissions` | `UP`   |
| `bookings`          | `BK`   |
| `listings`          | `LS`   |

### Output

```markdown
## Prefix Set: {feature}

**Prefix**: {XX}
**Updated**: docs/specs/{feature}/journal.md

Discussion IDs will be: {XX}-D001, {XX}-D002, etc.

Next: /afx:session capture {feature} "note"
```

## 4. config

Manage project configuration in `.afx.yaml`.

### Usage

```bash
/afx:init config get <key>
/afx:init config set <key> <value>
/afx:init config add <key> <value>
```

### Subcommands

| Action | Description  | Example                                               |
| :----- | :----------- | :---------------------------------------------------- |
| `get`  | Read a value | `/afx:init config get context.proposals`              |
| `set`  | Set a value  | `/afx:init config set context.proposals "docs/ideas"` |
| `add`  | Add to list  | `/afx:init config add features "new-feature"`         |

### Process

Run this inline script to manage configuration:

```bash
ACTION="$1" # get, set, add
KEY="$2"
VAL="$3"
CONFIG=".afx.yaml"

if [ ! -f "$CONFIG" ]; then echo "{}" > "$CONFIG"; fi

case "$ACTION" in
  get)
    grep "^$KEY:" "$CONFIG" | sed "s/^$KEY: //"
    ;;
  set)
    if grep -q "^$KEY:" "$CONFIG"; then
      sed -i '' "s|^$KEY:.*|$KEY: $VAL|" "$CONFIG"
    else
      echo "$KEY: $VAL" >> "$CONFIG"
    fi
    echo "Set $KEY = $VAL"
    ;;
  add)
    # Simple list append support
    if ! grep -q "^$KEY:" "$CONFIG"; then
      echo "$KEY: []" >> "$CONFIG"
    fi
    # Note: Primitive YAML list manipulation for simplicity
    echo "  - $VAL" >> "$CONFIG"
    echo "Added $VAL to $KEY"
    ;;
esac
```

### Output

```markdown
## Config Updated

**Key**: context.proposals
**Old Value**: docs/proposals
**New Value**: docs/ideas
```

---

## 5. adr

Create a global architecture decision record in `docs/adr/`.

### Usage

```bash
/afx:init adr <title>
```

Where `<title>` is a short noun phrase (e.g., "database choice", "api versioning strategy"). Gets kebab-cased into the filename slug.

### Process

1. Read `paths.adr` from `.afx.yaml` (default: `docs/adr`)
2. Create ADR directory if it doesn't exist
3. Scan directory for highest existing `ADR-NNNN` number
4. Increment → next number, zero-padded to 4 digits
5. Slugify title → kebab-case
6. Read `templates/adr.md` for the file structure and frontmatter format
7. **Generate real content** — use the title to write a meaningful first draft:
   - **Context**: Describe the problem space and why this decision is needed now
   - **Decision**: State "To be decided" with the key options identified
   - **Rationale**: Leave as "Pending analysis" (user fills this after deciding)
   - **Consequences**: List likely trade-offs for each option being considered
   - **Alternatives Considered**: List 2-3 concrete alternatives relevant to the title
8. Write the file using the **Write tool** (NOT a bash heredoc with placeholders)
9. Output confirmation with file path

**IMPORTANT**: Do NOT just copy the template with `{placeholder}` text. You MUST generate real, meaningful content for each section based on the ADR title and any available project context.

### Numbering Script

Run this to determine the next ADR number and resolve the directory:

```bash
CONFIG=".afx.yaml"
ADR_DIR="docs/adr"
if [ -f "$CONFIG" ]; then
  CONFIGURED=$(grep 'adr:' "$CONFIG" | head -1 | sed "s/.*adr:[[:space:]]*['\"]*//" | sed "s/['\"].*//")
  [ -n "$CONFIGURED" ] && ADR_DIR="$CONFIGURED"
fi
mkdir -p "$ADR_DIR"
LAST=$(ls "$ADR_DIR"/ADR-*.md 2>/dev/null | sed 's/.*ADR-\([0-9]*\).*/\1/' | sort -n | tail -1)
NEXT=$(printf "%04d" $(( ${LAST:-0} + 1 )))
echo "NEXT=$NEXT ADR_DIR=$ADR_DIR"
```

Then use the **Write tool** to create `$ADR_DIR/ADR-$NEXT-{slug}.md` with the generated content.

### Output

```markdown
## ADR Created: ADR-NNNN-{slug}

**File**: docs/adr/ADR-NNNN-{slug}.md
**Status**: Proposed

Next (ranked):

1. Edit docs/adr/ADR-NNNN-{slug}.md # Fill in context & decision
2. /afx:session capture specs "ADR discussion" # Capture related discussion
3. /afx:work status # Check project state
```

---

## Error Handling

**Feature already exists:**

```
Error: Feature 'user-auth' already exists at docs/specs/user-auth/
Use a different name or delete the existing feature first.
```

**Invalid name:**

```
Error: Feature name must be kebab-case (lowercase with hyphens)
Example: /afx:init feature my-new-feature
```

**Prefix conflict:**

```
Error: Prefix 'WC' already used by 'user-auth'
Choose a different prefix: /afx:init prefix {feature} XX
```

**Template not found:**

```
Error: Template 'custom-template' not found
Available templates: default, api-feature, ui-component
```

**ADR title missing:**

```
Error: Title required
Usage: /afx:init adr <title>
Example: /afx:init adr "database choice"
```

---

## Generated File Templates

### readme.md

```markdown
---
afx: true
type: README
status: Living
tags: [{ feature }, dashboard]
---

# {Feature Name}

> Brief description of the feature

**Status**: Draft
**Created**: {date}

## Phase Status

| Phase | Description         | Status  |
| ----- | ------------------- | ------- |
| 0     | Infrastructure      | Pending |
| 1     | Core Implementation | Pending |
| 2     | Testing             | Pending |

## Links

- [Spec](./spec.md) - Requirements
- [Design](./design.md) - Technical architecture
- [Tasks](./tasks.md) - Implementation tasks
- [Changelog](./changelog.md) - Version history
- [Session Log](./journal.md) - Discussions
```

### journal.md

```markdown
---
afx: true
type: JOURNAL
status: Living
tags: [{ feature }, journal]
---

# Journal - {Feature Name}

<!-- prefix: {XX} -->

> Quick captures and discussion history for AI-assisted development sessions.
> NOTE: This is an append-only log. All architectural decisions, failed experiments, and historical context go here.
> See [agenticflowx.md](../agenticflowx.md) for workflow.

## Captures

<!-- Quick notes during active chat - cleared when recorded -->

---

## Discussions

<!-- Recorded discussions with IDs: {XX}-D001, {XX}-D002, etc. -->

---

## Work Sessions

<!-- Task execution log - updated by /afx:work next, /afx:dev code -->

| Date | Task | Action | Files Modified | Agent | Human |
| ---- | ---- | ------ | -------------- | ----- | ----- |
```

---

## Related Commands

| Command            | Relationship                      |
| ------------------ | --------------------------------- |
| `/afx:work plan`   | Generate tasks after spec created |
| `/afx:session`     | Capture discussions in journal    |
| `/afx:check links` | Verify spec integrity             |
| `/afx:init adr`    | Create global ADR in docs/adr/    |
