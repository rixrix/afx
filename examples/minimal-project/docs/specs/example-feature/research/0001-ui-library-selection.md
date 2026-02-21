---
afx: true
type: ADR
status: Accepted
version: 1.0
created: 2024-03-24
owner: "@lead-dev"
tags: [adr, frontend, ui]
---

# ADR 0001: Adopt shadcn/ui for Component Library

## Context

The new Dashboard application requires a comprehensive set of UI components to ensure a consistent user experience and accelerate development time. The team needs to select a UI component library that provides high-quality accessibility, supports complex interactive components (like DatePickers and DataTables), but also allows for complete stylistic customization to match the brand guidelines without fighting CSS overrides.

## Decision

We will use **shadcn/ui** as the foundational component library for the new UI application, built on top of Tailwind CSS and Radix UI primitives.

## Rationale

Unlike traditional component libraries (like MUI or Ant Design) which bundle styles and logic into an npm package, shadcn/ui provides components by copying source code directly into our project (`components/ui`).

This approach provides three major advantages:

1. **Zero Abstraction Cost**: We own the code. If we need a fundamentally different variant of a Button, we modify the button file directly rather than fighting complex prop APIs or CSS nesting.
2. **First-Class Accessibility**: It is built on Radix UI, meaning complex keyboard navigation and ARIA attributes are handled out-of-the-box.
3. **Tailwind Native**: We are already using Tailwind CSS class-variance-authority, meaning this scales perfectly with our existing design token infrastructure.

## Consequences

**Positive:**

- Complete control over DOM structure and styling.
- No bulky npm dependencies that are difficult to tree-shake.
- Exceptional accessibility compliance (WCAG 2.1).

**Negative:**

- We are responsible for maintaining the component code; bug fixes pushed upstream by shadcn require manual diffing/updating in our codebase instead of a simple `npm update`.
- Slightly higher initial boilerplate in the `components/ui` folder.

## Alternatives Considered

- **Material-UI (MUI)**: Rejected. Too opinionated about design and requires fighting their Emotion styling engine. Bundle size is also historically a concern.
- **Chakra UI**: Rejected. While the API is fantastic, the runtime CSS-in-JS overhead negatively impacts performance, especially on lower-end devices.
- **Building from scratch**: Rejected. The engineering cost of implementing robust accessibility (focus traps, keyboard navigation) for complex components is too high for the current sprint timeline.
