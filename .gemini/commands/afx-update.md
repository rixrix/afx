---
afx: true
type: COMMAND
status: Living
tags: [afx, command, maintenance]
---

# /afx:update

Check for upstream AFX updates and apply them safely.

## Source of Truth

**CRITICAL**: Follow the canonical command logic and output format defined in:

- `.claude/commands/afx-update.md`

## Gemini-Specific Guidance

When updating the framework:

1.  **Version Checking**: Use `run_shell_command` with `curl` or `git` to compare the local AFX version to the latest upstream release.
2.  **Applying Updates**: Use `run_shell_command` to execute the installer update flow (`install.sh --update`). Always honor safety flags like `--dry-run`.

## Usage

```bash
/afx:update check
/afx:update apply
```
