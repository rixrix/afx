---
name: afx-architect
description: Design system architecture — select patterns, evaluate quality attributes, validate designs against requirements, and create Architecture Decision Records (ADRs)
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "architecture,design,adr,quality-attributes"
---

# AFX Architect

System design with the right patterns for the right problem at the right scale.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `architect-review` and `brainstorming` by community contributors.

## Activation

Use this skill when you need to:

- Design a new system, service, or major component — _"Design a system for X"_
- Review architecture for scalability or maintainability — _"Review this architecture"_
- Evaluate trade-offs between approaches — _"What are the trade-offs?"_
- Assess quality attributes or pattern compliance — _"Which pattern should I use?"_

## Review Process

1. **Gather context** — goals, constraints, scale, team, timeline
2. **Assess current state** — what exists, what's proposed, what's assumed
3. **Evaluate patterns** — compliance, violations, anti-patterns
4. **Identify risks** — scalability, security, coupling, single points of failure
5. **Recommend** — improvements with trade-offs, not just ideals
6. **Document** — ADR for every significant decision

## Pattern Selection

| Pattern | Best For | Avoid When |
|---|---|---|
| **Clean Architecture** | Business logic must survive framework changes | Simple CRUD |
| **Hexagonal** | Multiple integrations (APIs, DBs, queues) | Single data source |
| **Microservices** | Independent scaling, team autonomy | Small team, early stage |
| **Event-Driven** | Loose coupling, async workflows, audit trails | Strong consistency needed |
| **Modular Monolith** | Boundaries without microservice overhead | Truly independent scaling |
| **CQRS** | Read/write asymmetry, complex queries | Simple domain |
| **Serverless** | Spiky traffic, quick iteration | Long-running processes |

## Quality Attributes Checklist

- **Reliability** — fault tolerance, graceful degradation, recovery
- **Scalability** — horizontal/vertical, auto-scaling, data partitioning
- **Security** — zero trust, auth boundaries, encryption, secrets management
- **Performance** — caching layers, connection pooling, async processing
- **Observability** — logging, metrics, distributed tracing, alerting
- **Maintainability** — modularity, testability, deployment independence
- **Cost** — resource efficiency, right-sizing, FinOps awareness

## Design Validation

Before approving any architecture:

```
[ ] Dependencies point inward (domain knows nothing about infrastructure)
[ ] Each module has one reason to change
[ ] Boundaries are explicit (interfaces, not shared internals)
[ ] Failure modes are handled (circuit breakers, retries, timeouts)
[ ] Data ownership is clear (no shared databases across services)
[ ] Scaling strategy matches actual load patterns
[ ] Security boundaries align with trust boundaries
```

## Key Principles

1. **Start simple, extract when pain is real** — premature abstraction kills
2. **Depend on abstractions** — interfaces at boundaries, implementations injected
3. **Design for change** — enable evolution, don't prevent it
4. **Balance excellence with delivery** — perfect architecture shipped never beats good architecture shipped now

## AFX Integration

<!-- @afx:provider-commands -->
- Use `/afx-init adr <title>` to create architecture decision records
- Use `/afx-check path` to verify architecture layers are respected
<!-- @afx:/provider-commands -->

## Output

Always end your response with:
> AFX skill: `afx-architect`
