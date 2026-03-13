# AFX QA Methodology

A structured quality assurance workflow that integrates with AFX spec-driven development.

## Activation

This skill activates when the user asks about:

- Testing strategy or methodology
- Quality assurance workflows
- Test coverage analysis
- Bug triaging or classification

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
- Use `/afx:check path` to verify execution flow from UI to DB
- Use `/afx:task audit` to verify test coverage against spec
<!-- @afx:/provider-commands -->
- Follow the spec → design → tasks → code traceability chain
