---
afx: true
type: COMMAND
status: Living
tags: [afx, command, report, metrics]
---

# /afx:report

Traceability metrics and project health reporting for AgenticFlowX.

## Configuration

**Read `.afx.yaml`** at project root to resolve paths:

- `paths.specs` - Where spec files live (default: `docs/specs`)
- `features` - List of active features
- `scan_for_orphans` - File patterns to scan

If `.afx.yaml` doesn't exist, use defaults.

## Usage

```bash
/afx:report health [spec]           # Overall traceability metrics
/afx:report orphans [path]          # Code without @see links
/afx:report coverage <spec>         # Spec → Code coverage map
/afx:report stale [days]            # Specs not updated recently
```

## Agent Instructions

### Next Command Suggestion (MANDATORY)

**CRITICAL**: After EVERY `/afx:report` action, suggest the most appropriate next command:

| Context                         | Suggested Next Command               |
| ------------------------------- | ------------------------------------ |
| After `health` (issues found)   | `/afx:check lint` or `/afx:dev code` |
| After `health` (all good)       | `/afx:work next <spec>`              |
| After `orphans` (orphans found) | `/afx:check lint <file>:<line>`      |
| After `coverage` (gaps found)   | `/afx:dev code` to implement         |
| After `stale` (stale specs)     | `/afx:check links <spec>`            |

---

## Subcommands

---

## 1. health

Generate overall traceability health metrics.

### Usage

```bash
/afx:report health              # All specs
/afx:report health <spec>       # Specific spec
```

### Process

Run this inline script to check health:

```bash
echo "## Traceability Health Report"
echo "**Generated**: $(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
echo ""

TOTAL_DOCS=$(find docs -name "*.md" | grep -v "templates" | wc -l)
VALID_DOCS=$(find docs -name "*.md" | grep -v "templates" | xargs grep -l "afx: true" | wc -l)
MISSING=$((TOTAL_DOCS - VALID_DOCS))

echo "### Summary"
echo ""
echo "| Metric | Value |"
echo "| --- | --- |"
echo "| Total Docs | $TOTAL_DOCS |"
echo "| Valid Frontmatter | $VALID_DOCS |"
echo "| Missing Frontmatter | $MISSING |"
echo ""

echo "### Spec Completeness"
echo "| Feature | Completeness |"
echo "| --- | --- |"

# Identify feature folders
find docs/specs -maxdepth 1 -type d | grep -v "docs/specs$" | while read -r DIR; do
  FEATURE=$(basename "$DIR")
  if [ "$FEATURE" != "_templates" ]; then
    REQUIRED=("spec.md" "design.md" "tasks.md" "journal.md")
    MISSING_FILES=""
    for FILE in "${REQUIRED[@]}"; do
      if [ ! -f "$DIR/$FILE" ]; then
        MISSING_FILES="$MISSING_FILES $FILE"
      fi
    done

    if [ -z "$MISSING_FILES" ]; then
      echo "| $FEATURE | ✅ |"
    else
      echo "| $FEATURE | ⚠️ Missing: $MISSING_FILES |"
    fi
  fi
done
```

### Output

```markdown
## Traceability Health Report

**Generated**: 2025-12-16

### Summary

| Metric            | Score | Status  |
| ----------------- | ----- | ------- |
| Spec Completeness | 95%   | OK      |
| Link Validity     | 87%   | WARNING |
| Code Coverage     | 72%   | WARNING |
| Session Activity  | 100%  | OK      |

**Overall Score**: 88/100 WARNING

### By Feature

| Feature           | Complete | Links   | Coverage | Last Update |
| ----------------- | -------- | ------- | -------- | ----------- |
| user-auth         | OK       | OK      | 85%      | 2025-12-15  |
| users-permissions | OK       | WARNING | 65%      | 2025-12-10  |
| agenticflow       | OK       | OK      | N/A      | 2025-12-16  |

### Issues Found

1. **Broken link**: users-permissions/design.md#auth-flow (anchor missing)
2. **Low coverage**: users-permissions has 12 uncovered requirements
3. **Orphaned code**: 5 files missing @see links

Next (ranked):

1. /afx:report orphans # Find code without @see
2. /afx:check links users-permissions # Fix broken links
3. /afx:report coverage users-permissions # See coverage details
4. /afx:dev code # Address gaps
5. /afx:work next <spec> # Continue if healthy
```

---

## 2. orphans

Find code files missing required @see references.

### Usage

```bash
/afx:report orphans                 # Scan entire codebase
/afx:report orphans packages/db     # Scan specific path
```

### Process

Run this inline script to find orphans:

```bash
# Finds .ts files missing @see links
grep -rL "@see docs/specs" src/ apps/ packages/ \
  --include="*.ts" --include="*.tsx" \
  | grep -v "node_modules" \
  | grep -v ".test.ts" \
  | grep -v "config"
```

### Output

````markdown
## Orphaned Code Report

**Scanned**: packages/db, apps/admin, apps/portal
**Files checked**: 127
**Orphans found**: 5

### Orphaned Files

| File                                                    | Type       | Suggested PRD             |
| ------------------------------------------------------- | ---------- | ------------------------- |
| `packages/db/src/core/services/notification.service.ts` | Service    | docs/specs/notifications/ |
| `apps/admin/src/user-auth/_actions/export.action.ts`    | Action     | docs/specs/user-auth/     |
| `packages/db/src/core/repositories/audit.repository.ts` | Repository | docs/specs/audit-log/     |

### Fix Command

For each orphan, add @see reference:

```typescript
/**
 * @see docs/specs/{feature}/design.md#{section}
 * @see docs/specs/{feature}/tasks.md#{task}
 */
```

Next (ranked):

1. /afx:check lint notification.service.ts:1 # Fix first orphan
2. /afx:dev code # Add @see links
3. /afx:report health # Re-check after fixes
````

---

## 3. coverage

Show requirements coverage - which spec items have implementations.

### Usage

```bash
/afx:report coverage <spec>
```

### Process

### Process

Run this inline script (approximate regex):

```bash
SPEC_FILE="docs/specs/$ARGUMENTS/spec.md"
if [ ! -f "$SPEC_FILE" ]; then echo "Spec not found"; exit 1; fi

echo "## Coverage Report: $ARGUMENTS"
echo "| Requirement | Refs |"
echo "| --- | --- |"

grep -oE "FR-[0-9]+" "$SPEC_FILE" | sort | uniq | while read -r REQ; do
  COUNT=$(grep -r "$REQ" src/ apps/ packages/ | wc -l)
  if [ "$COUNT" -gt 0 ]; then
    echo "| $REQ | ✅ $COUNT files |"
  else
    echo "| $REQ | ❌ Not covered |"
  fi
done
```

### Output

```markdown
## Coverage Report: user-auth

### Requirements Coverage

| Requirement | Description           | Code References | Status      |
| ----------- | --------------------- | --------------- | ----------- |
| FR-1        | Submit claim          | 3 files         | Covered     |
| FR-2        | Upload photos         | 2 files         | Covered     |
| FR-3        | View claim status     | 1 file          | Covered     |
| FR-4        | Admin assign supplier | 0 files         | Not covered |
| FR-5        | Supplier notification | 0 files         | Not covered |

### Tasks Coverage

| Phase | Total | Implemented | Coverage |
| ----- | ----- | ----------- | -------- |
| 0     | 5     | 5           | 100%     |
| 1     | 4     | 4           | 100%     |
| 2     | 6     | 6           | 100%     |
| 3     | 5     | 5           | 100%     |
| 7     | 4     | 2           | 50%      |

### Uncovered Items

1. **FR-4**: Admin assign supplier
   - Expected in: apps/admin/src/user-auth/
   - Task: 7.3

2. **FR-5**: Supplier notification
   - Expected in: packages/mailer/
   - Task: Phase 2 (deferred)

Next (ranked):

1. /afx:work next docs/specs/user-auth # Implement uncovered
2. /afx:task list 7 # See Phase 7 tasks
3. /afx:dev code # Start implementation
```

---

## 4. stale

Find specs that haven't been updated recently.

### Usage

```bash
/afx:report stale              # Default: 30 days
/afx:report stale 14           # Custom threshold
```

### Process

### Process

Run this inline script:

```bash
DAYS="${1:-30}"
echo "## Stale Specs Report (> $DAYS days)"
echo "| File | Last Update |"
echo "| --- | --- |"

find docs/specs -name "*.md" -mtime +$DAYS -print0 | xargs -0 ls -lt | awk '{print "| " $9 " | " $6 " " $7 " |"}'
```

### Output

```markdown
## Stale Specs Report

**Threshold**: 30 days
**Checked**: 2025-12-16

### Stale Specs

| Spec              | Last Update | Days Stale | Status  |
| ----------------- | ----------- | ---------- | ------- |
| users-permissions | 2025-11-10  | 36         | Stale   |
| bookings          | 2025-11-25  | 21         | Warning |

### Active Specs

| Spec        | Last Update | Days |
| ----------- | ----------- | ---- |
| user-auth   | 2025-12-15  | 1    |
| agenticflow | 2025-12-16  | 0    |

Next (ranked):

1. /afx:check links users-permissions # Verify stale spec
2. /afx:session recap users-permissions # Review discussions
3. /afx:work status # Check overall state
```

---

## Metric Definitions

| Metric                | Calculation                                                       |
| --------------------- | ----------------------------------------------------------------- |
| **Spec Completeness** | % of specs with all required files (spec, design, tasks, journal) |
| **Link Validity**     | % of @see links that resolve to valid anchors                     |
| **Code Coverage**     | % of spec requirements with at least one @see backlink            |
| **Session Activity**  | % of specs with session log entries in last 30 days               |

---

## Related Commands

| Command            | Relationship             |
| ------------------ | ------------------------ |
| `/afx:check lint`  | Fix orphaned annotations |
| `/afx:check links` | Fix broken links         |
| `/afx:work status` | See active work state    |
