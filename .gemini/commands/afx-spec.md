---
afx: true
type: COMMAND
status: Living
tags: [afx, command, spec, management]
---

# /afx:spec

Specification management, navigation, review, and approval for spec-centric workflows.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-spec.md`

## Gemini-Specific Guidance

When managing specifications:

1.  **Spec Analysis**: Use `read_file` and `grep_search` to list, show, and validate specifications.
2.  **Interactive Discussion**: Use your reasoning capabilities to discuss specs and identify gaps.
3.  **Comprehensive Review**: When performing an automated review, use `codebase_investigator` if necessary to check for consistency with existing architectural patterns.
4.  **Requirement Extraction**: Use `grep_search` to precisely extract FR/NFR from `spec.md`.

## Usage

```bash
/afx:spec list
/afx:spec show <name>
/afx:spec validate <name>
/afx:spec review <name>
/afx:spec approve <name>
/afx:spec requirements <name>
/afx:spec coverage <name>
```
