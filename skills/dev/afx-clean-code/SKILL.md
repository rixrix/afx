---
name: afx-clean-code
description: Write and review code for readability — apply naming conventions, function design, comment quality, error handling patterns, and code smell detection based on Clean Code principles
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "clean-code,readability,refactoring,code-quality"
---

# AFX Clean Code

Write code that reads like well-written prose.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `clean-code` by [ClawForge](https://github.com/jackjin1997/ClawForge), based on Robert C. Martin's "Clean Code".

## Activation

Use this skill when you need to:

- Write or review code for readability — _"Review this code for cleanliness"_
- Improve naming, functions, or structure — _"How should I name this?"_
- Refactor legacy code or reduce technical debt — _"Refactor this for readability"_

## Principles

### Names

- Reveal intent: `elapsedTimeInDays` not `d`
- No disinformation: don't call it `accountList` if it's a `Map`
- Classes = nouns (`Customer`), methods = verbs (`postPayment`)
- Searchable and pronounceable

### Functions

- Small — do one thing, do it well
- 0-2 arguments ideal, 3+ needs justification
- No side effects — don't secretly change state
- One level of abstraction per function

### Comments

- Don't comment bad code — rewrite it
- Good: legal, TODO with ticket, clarification of external APIs
- Bad: redundant, misleading, noise, journal comments

### Error Handling

- Exceptions over return codes
- Don't return null — use Optional, empty collections, or throw
- Don't pass null

### Classes

- Single Responsibility Principle — one reason to change
- Newspaper metaphor: high-level at top, details below

## Code Smells

| Smell                        | Fix                                     |
| ---------------------------- | --------------------------------------- |
| Rigidity (hard to change)    | Extract interfaces, invert dependencies |
| Fragility (breaks elsewhere) | Reduce coupling, add tests              |
| Immobility (can't reuse)     | Extract into modules                    |
| Needless complexity          | Delete speculative code                 |
| Needless repetition          | Extract shared functions                |

## Checklist

- [ ] Functions under 20 lines?
- [ ] Each function does exactly one thing?
- [ ] Names are searchable and intention-revealing?
- [ ] No comments needed because code is clear?
- [ ] Failing test exists for this change?

## Output

Always end your response with:
> AFX skill: `afx-clean-code`
