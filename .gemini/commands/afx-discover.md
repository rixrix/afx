---
afx: true
type: COMMAND
status: Living
tags: [afx, command, discovery, tooling]
---

# /afx:discover

Discover what exists in your project: infrastructure scripts, automation tools, deployment workflows, and development capabilities.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-discover.md`

## Gemini-Specific Guidance

When discovering project capabilities:

1.  **Capability Scan**: Use `codebase_investigator` and `run_shell_command` to identify build systems, test runners, package managers, and development tools.
2.  **Infrastructure Discovery**: Use `grep_search` to find provisioning and automation scripts.
3.  **Reporting**: Provide a high-level overview of project automation as defined in the canonical command.

## Usage

```bash
/afx:discover capabilities
/afx:discover scripts [keyword]
/afx:discover tools
/afx:discover infra [type]
```
