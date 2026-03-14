---
name: afx-research
description: Conduct deep evidence-based investigation — trace code execution paths, cite sources with confidence ratings, and produce structured research findings
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "research,investigation,evidence,analysis"
---

# AFX Research

Deep, evidence-based investigation — no shallow summaries, no guesswork.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `wiki-researcher` and `research-engineer` by community contributors.

## Activation

Use this skill when you need to:

- Investigate how a system actually works — _"How does this system work?"_
- Trace data flows or integration points — _"Trace the data flow from X to Y"_
- Conduct technical research or competitive analysis — _"Deep dive into this codebase"_
- Answer questions requiring depth beyond a surface answer — _"Research how this component integrates"_

## Core Rules (Non-Negotiable)

1. **Trace actual code paths** — don't guess from file names
2. **Read the real implementation** — don't summarize what you think it does
3. **Follow the chain** — if A calls B calls C, trace it all the way
4. **Distinguish fact from inference** — "I read this" vs "I'm inferring"
5. **Zero-confidence for unknowns** — if you haven't read it, say so

## Evidence Standard

| Claim | Required Evidence |
|---|---|
| "X calls Y" | File path + function name |
| "Data flows through Z" | Entry point → transformations → destination |
| "This is the entry point" | Where it's invoked (config, main, route) |
| "These are coupled" | Import/dependency chain |
| "This is dead code" | No call sites exist |

## Research Process (5 Iterations)

1. **Structural** — map the landscape, components, entry points
2. **Data flow** — trace data through the system end-to-end
3. **Integration** — external connections, API contracts, boundaries
4. **Patterns** — design patterns, trade-offs, technical debt, risks
5. **Synthesis** — combine findings, actionable recommendations

### For Every Finding

- **State it** — one clear sentence
- **Show evidence** — file paths, line numbers, call chains
- **Explain why it matters** — implications and consequences
- **Rate confidence** — HIGH (read code) | MEDIUM (partial) | LOW (inferred)
- **Flag gaps** — what would you need to trace next?

## Scientific Rigor

- **Zero hallucination** — never invent APIs, libraries, or bounds
- **Critique first** — if the premise is flawed, correct it before proceeding
- **Complexity is necessary** — don't simplify if it compromises validity
- **Optimal tools** — choose the right language/framework for the domain

## AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-session note` to capture research findings
- Use `/afx-session promote <id>` to turn findings into ADRs
<!-- @afx:/provider-commands -->

## Output

Always end your response with:
> AFX skill: `afx-research`
