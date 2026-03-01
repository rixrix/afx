---
afx: true
type: COMMAND
status: Living
tags: [afx, command, report, metrics]
---

# /afx:report

Traceability metrics and project health reporting for AgenticFlowX.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-report.md`

## Gemini-Specific Guidance

When generating reports:

1.  **Traceability Analysis**: Use `grep_search` to map `@see` links from code back to specifications.
2.  **Health Metrics**: Use `grep_search` to calculate spec quality and task completion rates.
3.  **Coverage**: Use `grep_search` and `codebase_investigator` to identify which specs have implementation versus those that are documentation-only.

## Usage

```bash
/afx:report traceability
/afx:report health
/afx:report coverage
```
