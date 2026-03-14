---
name: afx-architecture-patterns
description: Choose the right architecture pattern — compare Clean Architecture, Hexagonal, DDD, Event-Driven, and Microservices with trade-off analysis and ADR documentation
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "architecture,patterns,clean-architecture,hexagonal,ddd"
---

# AFX Architecture Patterns

Choose the right architecture for the right problem.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `architecture-patterns` and `architecture-decision-records` by community contributors.

## Activation

Use this skill when you need to:

- Choose between architecture patterns — _"Which pattern fits this?"_
- Design a new system or refactor an existing one — _"Should I use Clean Architecture or Hexagonal?"_
- Document architecture decisions — _"Help me write an ADR"_

## Pattern Selection

| Pattern                          | Use When                                            | Avoid When                      |
| -------------------------------- | --------------------------------------------------- | ------------------------------- |
| **Clean Architecture**           | Business logic must survive framework changes       | Simple CRUD apps                |
| **Hexagonal (Ports & Adapters)** | Multiple integrations (APIs, DBs, queues)           | Single data source              |
| **Domain-Driven Design**         | Complex business domains with rich rules            | Simple data transformations     |
| **Event-Driven**                 | Loose coupling, async workflows, audit trails       | Strong consistency required     |
| **Modular Monolith**             | Team wants boundaries without microservice overhead | Truly independent scaling needs |

## Clean Architecture Layers

```
External (frameworks, DB, UI)
  → Interface Adapters (controllers, presenters, gateways)
    → Application (use cases, orchestration)
      → Domain (entities, value objects, business rules)
```

**Dependency rule**: Dependencies point inward. Domain knows nothing about the outside.

## Key Principles

1. **Separate what changes from what doesn't** — business rules outlive frameworks
2. **Depend on abstractions** — interfaces at boundaries, implementations injected
3. **One module, one reason to change** — if two things change for different reasons, split them
4. **Start simple, extract when pain is real** — three similar lines > a premature abstraction

## Architecture Decision Records

When making significant choices, capture them:

```markdown
# ADR-NNNN: Title

## Status: Accepted

## Context

What forces are at play? What constraints?

## Decision

What we chose and why.

## Consequences

What becomes easier? What becomes harder?
```

## AFX Integration

<!-- @afx:provider-commands -->

- Use `/afx-init adr` to create architecture decision records
- Use `/afx-check path` to verify architecture layers are respected
<!-- @afx:/provider-commands -->

## Output

Always end your response with:
> AFX skill: `afx-architecture-patterns`
