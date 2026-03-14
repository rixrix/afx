---
name: afx-tdd
description: Practice test-driven development — write failing tests first, implement minimal code to pass, then refactor using the red-green-refactor cycle with FIRST principles
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "tdd,testing,red-green-refactor,test-first"
---

# AFX Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass.

> Adapted from [openclaw-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `test-driven-development` by community contributors.

## Activation

Use this skill when you need to:

- Implement a new feature or bug fix — _"Write a test for this feature"_
- Apply test-driven development — _"Help me do TDD"_
- Write code that currently has no tests — _"What should I test first?"_

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over. No exceptions.

## Red-Green-Refactor

### RED — Write one failing test

- Test the behavior, not the implementation
- One assertion per test
- Name describes the expected behavior: `retries failed operations 3 times`

### GREEN — Write minimal code to pass

- Simplest thing that works — even if ugly
- Don't over-engineer during green
- All tests must pass, not just the new one

### REFACTOR — Clean up while green

- Remove duplication
- Improve names
- Extract methods
- Tests stay green throughout

## What Makes a Good Test

**F.I.R.S.T.**
- **Fast** — milliseconds, not seconds
- **Independent** — no test depends on another
- **Repeatable** — same result every run, any environment
- **Self-validating** — pass or fail, no manual checking
- **Timely** — written before or with the code, not after

## Common Traps

| Trap | Fix |
|------|-----|
| Testing implementation details | Test behavior and outputs |
| Too many mocks | Test real integrations where possible |
| "I'll add tests later" | You won't. Write them now |
| Giant test setup | Extract builders or fixtures |
| Flaky tests | Fix immediately — flaky = broken |

## AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-dev test` to run or generate tests
- Use `/afx-check path` to verify test coverage against spec
<!-- @afx:/provider-commands -->

## Output

Always end your response with:
> AFX skill: `afx-tdd`
