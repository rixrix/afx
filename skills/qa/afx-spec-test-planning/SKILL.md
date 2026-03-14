---
name: afx-spec-test-planning
description: Generate test plans from specifications — extract testable requirements, map acceptance criteria to test cases, and detect coverage gaps between spec and implementation
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "qa,test-planning,spec-tracing,acceptance-criteria"
---

# AFX Spec Test Planning

Plan tests by deriving them directly from spec requirements and acceptance criteria.

## Activation

Use this skill when you need to:

- Derive tests from spec requirements — _"Create a test plan from this spec"_
- Map tests to acceptance criteria — _"What tests do I need for these requirements?"_
- Detect gaps in test coverage — _"Find gaps in my test coverage"_

## Instructions

### Derive Tests from Spec

1. Read `docs/specs/{feature}/spec.md`
2. For each FR-{n} and NFR-{n}, derive one or more test cases
3. For each acceptance criteria item, derive at least one assertion
4. Document the mapping:

   | Requirement | Test Case              | Type        | Status  |
   | ----------- | ---------------------- | ----------- | ------- |
   | FR-1        | test_user_login        | Integration | Pending |
   | NFR-1       | test_login_latency_p95 | Performance | Pending |

### Test File Structure

Every test file must include traceability:

```typescript
/**
 * @see docs/specs/{feature}/spec.md#FR-1
 * @see docs/specs/{feature}/tasks.md#3.1-write-login-tests
 */
describe('User Login', () => { ... });
```

### Gap Detection

After planning, check for:

- Requirements without test cases
- Test cases without requirement links
- Acceptance criteria without assertions

### AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-check path` to verify execution flow from UI to DB
- Use `/afx-task audit` to verify test coverage against spec
<!-- @afx:/provider-commands -->
- Follow the spec → design → tasks → code traceability chain

## Output

Always end your response with:
> AFX skill: `afx-spec-test-planning`
