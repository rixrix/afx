---
name: afx-systematic-debugging
description: Debug systematically to find root causes — investigate symptoms, form hypotheses, isolate failures, apply fixes, and add safeguards to prevent recurrence
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "debugging,root-cause,investigation,prevention"
---

# AFX Systematic Debugging

Find root cause before fixing. No exceptions.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `systematic-debugging` by community contributors.

## Activation

Use this skill when you need to:

- Debug a bug or test failure — _"Help me debug this"_
- Find root cause when a fix didn't work — _"My fix didn't work, what's the root cause?"_
- Investigate unexpected behavior — _"Why isn't this working?"_

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

## Phase 1: Investigate

1. **Read errors carefully** — full stack traces, line numbers, error codes
2. **Reproduce consistently** — exact steps, every time. If not reproducible, gather more data
3. **Check recent changes** — git diff, new dependencies, config changes, environment differences
4. **Add diagnostics before fixing** — logging, assertions, print statements at boundaries

## Phase 2: Analyze

1. **Form a hypothesis** — one specific, testable explanation
2. **Test the hypothesis** — prove it, don't just confirm bias
3. **If wrong, update** — new data means new hypothesis, not forcing the old one

## Phase 3: Fix

1. **Fix the root cause** — not the symptom
2. **Make the smallest change** — one fix per issue
3. **Verify the fix** — run the reproduction steps again
4. **Add a regression test** — prevent recurrence

## Phase 4: Reflect

1. **Why wasn't this caught earlier?** — missing test, missing validation, unclear error?
2. **Document the root cause** — for the commit message, PR, or journal

## Anti-Patterns

- Changing multiple things at once
- "It works now" without understanding why
- Reverting to a known good state without learning what broke
- Blaming the framework before checking your code

## AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-dev debug` to trace with spec alignment
- Use `/afx-session note` to capture root cause findings
<!-- @afx:/provider-commands -->

## Output

Always end your response with:
> AFX skill: `afx-systematic-debugging`
