# AFX Spec Test Planning

Plan tests by deriving them directly from spec requirements and acceptance criteria.

## Activation

This skill activates when the user asks about:

- Test planning or test plan creation
- Deriving tests from specifications
- Mapping tests to requirements

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
