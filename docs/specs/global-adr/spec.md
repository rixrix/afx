---
afx: true
type: SPEC
status: Draft
owner: "@rix"
version: 1.0
tags: [global-adr, framework, architecture]
---

# Requirements: global-adr

> Add first-class `docs/adr/` support to AFX for project-wide architecture decision records.

## Background

AFX currently supports per-feature ADRs in `docs/specs/{feature}/research/`, but cross-cutting decisions (database choice, API strategy, monorepo structure) have no canonical home. Industry standard is `docs/adr/` with numbered records.

See: [ADR-0001](../../adr/ADR-0001-global-adr-directory.md)

## Functional Requirements

| ID   | Requirement                                                           | Priority |
| ---- | --------------------------------------------------------------------- | -------- |
| FR-1 | Installer creates `docs/adr/` directory in target projects            | P1       |
| FR-2 | `.afx.yaml.template` includes `paths.adr` field                       | P1       |
| FR-3 | `/afx-init` supports `adr <title>` subcommand to create numbered ADRs | P2       |
| FR-4 | `/afx-next` considers ADRs when suggesting next actions               | P2       |
| FR-5 | `/afx-context` includes relevant ADRs in session handoff bundles      | P2       |
| FR-6 | ADR numbering auto-increments (ADR-0001, ADR-0002, ...)               | P1       |

## Non-Functional Requirements

| ID    | Requirement                                                     | Priority |
| ----- | --------------------------------------------------------------- | -------- |
| NFR-1 | Zero breaking changes to existing AFX installations             | P1       |
| NFR-2 | ADR template reused from existing `templates/adr.md`            | P1       |
| NFR-3 | Works with or without `paths.adr` in config (graceful fallback) | P1       |
