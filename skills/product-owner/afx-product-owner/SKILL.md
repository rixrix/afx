---
name: afx-product-owner
description: Drive product decisions — prioritize features with RICE scoring, write PRD templates, run customer discovery interviews, and define success metrics and KPIs
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "product,prioritization,prd,discovery,metrics"
---

# AFX Product Owner

From discovery to delivery — prioritize what matters, ship what counts.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `product-manager-toolkit` by community contributors.

## Activation

Use this skill when you need to:

- Prioritize features or build a roadmap — _"Help me prioritize these features"_
- Write PRDs, user stories, or acceptance criteria — _"Write a PRD for this feature"_
- Run customer discovery or validate hypotheses — _"How should I validate this idea?"_
- Define success metrics for a feature or product — _"What metrics should I track?"_

## Prioritization

### RICE Framework

```
Score = (Reach x Impact x Confidence) / Effort

Reach:      Users affected per quarter
Impact:     Massive(3x) | High(2x) | Medium(1x) | Low(0.5x) | Minimal(0.25x)
Confidence: High(100%) | Medium(80%) | Low(50%)
Effort:     Person-months
```

### Value vs Effort Matrix

```
              Low Effort    High Effort
High Value    QUICK WINS    BIG BETS
Low Value     FILL-INS      TIME SINKS
```

### MoSCoW — Must | Should | Could | Won't

## PRD Templates

| Template | Use When | Duration |
|---|---|---|
| **Standard PRD** | Complex features, cross-team | 6-8 weeks |
| **One-Page PRD** | Smaller features, clear scope | 2-4 weeks |
| **Feature Brief** | Exploration, pre-PRD phase | 1 week |
| **Agile Epic** | Sprint-based delivery | Varies |

**Structure**: Problem → Solution → Success Metrics → Out of Scope → Acceptance Criteria

## Discovery

### Hypothesis Template

```
We believe that [building this feature]
For [these users]
Will [achieve this outcome]
We'll know we're right when [metric changes by X]
```

### Customer Interview (30 min)

1. **Context** (5 min) — Role, workflow, tools
2. **Problems** (15 min) — Pain points, frequency, workarounds
3. **Validation** (10 min) — Reaction to concepts, willingness to pay

**Rules**: Ask "why" 5 times. Focus on past behavior, not future intentions. Never lead.

## Success Metrics

- **Adoption**: % of users using the feature
- **Frequency**: Usage per user per period
- **Depth**: % of feature capability used
- **Retention**: Continued usage over time
- **Satisfaction**: NPS/CSAT for the feature

## Key Principles

1. **Problem first** — understand before you build
2. **Measure impact** — no feature without success criteria
3. **Communicate early** — stakeholder surprise kills products
4. **Ship and learn** — avoid analysis paralysis
5. **Buffer 20%** — unexpected work always arrives

## AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-init feature <name>` to scaffold a new feature spec
- Use `/afx-session note` to capture discovery insights
<!-- @afx:/provider-commands -->

## Output

Always end your response with:
> AFX skill: `afx-product-owner`
