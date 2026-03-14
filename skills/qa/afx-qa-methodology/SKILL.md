---
name: afx-qa-methodology
description: Plan and execute QA workflows — build test strategies, triage bugs by severity, map test coverage to spec requirements, and ensure quality gates pass
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "qa,testing,test-strategy,bug-triage,coverage"
---

# AFX QA Methodology

A structured quality assurance workflow that integrates with AFX spec-driven development.

## Activation

Use this skill when you need to:

- Plan a test strategy for a feature — _"What's the test strategy for this feature?"_
- Triage and classify bugs — _"Help me triage these bugs"_
- Map test coverage to spec requirements — _"Check test coverage against the spec"_

## Instructions

### Test Strategy

1. **Read the spec first** — always check `docs/specs/{feature}/spec.md` for acceptance criteria
2. **Link tests to requirements** — every test file must include `@see` annotations:
```
@see docs/specs/{feature}/spec.md#FR-{n}
@see docs/specs/{feature}/tasks.md#2.1-task-slug
```
3. **Two-stage verification** — mark tasks `[x]` in agent column, leave human column for reviewer
4. **Coverage mapping** — identify untested requirements and flag gaps

### Bug Triage

- Link bugs to spec requirements where possible
- Classify by severity: Critical (data loss), Major (broken workflow), Minor (cosmetic)
- Include reproduction steps tied to acceptance criteria

### AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-check path` to verify execution flow from UI to DB
- Use `/afx-task audit` to verify test coverage against spec
<!-- @afx:/provider-commands -->
- Follow the spec → design → tasks → code traceability chain

## Output

Always end your response with:
> AFX skill: `afx-qa-methodology`
