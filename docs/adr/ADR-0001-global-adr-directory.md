---
afx: true
type: ADR
status: Accepted
version: 1.0
created: 2026-02-24
owner: "@rix"
tags: [adr, architecture, framework]
---

# ADR 0001: Use docs/adr/ for Global Architecture Decision Records

## Context

AFX organizes all feature work under `docs/specs/{feature}/`, with each feature having its own `research/` directory for local ADRs. However, many decisions are cross-cutting and don't belong to any single feature:

- Database choices
- API versioning strategy
- Monorepo vs polyrepo
- Framework conventions

These project-wide decisions had no canonical home, leading to them being scattered across feature journals or lost entirely.

## Decision

Add a top-level `docs/adr/` directory for global architecture decision records. Feature-specific ADRs remain in `docs/specs/{feature}/research/`. The `.afx.yaml` config gains a `paths.adr` field pointing to this directory.

ADR files follow the naming convention: `ADR-NNNN-short-slug.md` (zero-padded 4-digit number).

## Rationale

- **`docs/adr/`** is the industry-standard path, originating from Michael Nygard's ADR proposal and the widely-used `adr-tools` CLI
- Keeping it separate from `docs/specs/` avoids polluting the feature namespace
- The underscore-prefix alternative (`docs/specs/_global/`) was considered but rejected as non-standard — developers universally recognize `docs/adr/`
- `docs/decisions/` was considered for broader scope but ADR is more precise and established

## Consequences

- AFX commands that scan for context (`/afx:next`, `/afx:context`) should be updated to read from `docs/adr/`
- The installer should create `docs/adr/` in target projects
- Feature-local ADRs in `research/` still work — this adds a global layer, not a replacement
- The existing `templates/adr.md` template applies to both global and feature-local ADRs

## Alternatives Considered

- **`docs/specs/_project/adrs/`**: Inside specs dir with underscore prefix. Rejected because it's non-standard and adds nesting.
- **`docs/decisions/`**: Broader name. Rejected because ADR is the established industry term and more precise.
- **`docs/architecture/decisions/`**: Enterprise-style deep nesting. Rejected as overly verbose for most projects.
