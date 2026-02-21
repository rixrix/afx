---
afx: true
type: GUIDE
status: Stable
owner: "@rix"
version: 1.6
tags: [methodology, sdd, testing, verification]
---

# Spec-Driven Development

This project uses **Spec-Driven Development (SDD)** to manage feature planning and implementation. This approach separates requirements, technical design, and task tracking into distinct documents, making it easier to scale as the codebase grows.

For AI-assisted development, we use **[AFX (AgenticFlowX)](../agenticflowx/agenticflowx.md)** - a workflow extension that adds session continuity, agent resumption, and PRD-first traceability to SDD.

---

## What is Spec-Driven Development?

Spec-Driven Development inverts traditional software development by making **specifications the primary artifact** that drives implementation. Instead of specifications serving as secondary documentation, code serves specifications.

> "Specifications don't serve code—code serves specifications."

The core insight: eliminate the gap between intent and implementation by making specifications precise, complete, and unambiguous enough to guide working systems.

---

## Why This Approach?

| Benefit                | Description                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------ |
| **Scales with growth** | Each feature has its own folder with consistent structure                            |
| **Evergreen Docs**     | Strict separation between factual state (specs) and historical footprints (journals) |
| **Clear separation**   | Requirements (what) separate from design (how) separate from tasks (when)            |
| **GitHub integration** | Specs link to milestones and issues for tracking                                     |
| **AI-friendly**        | Claude Code can read specs to understand context                                     |
| **Session continuity** | AgenticFlowX enables agents to resume interrupted work                               |
| **Review-friendly**    | Stakeholders review specs, engineers review designs                                  |
| **Reduces rework**     | Catch requirement gaps before writing code                                           |

---

## The Four-File Structure

```
docs/specs/{feature-name}/
├── spec.md          # WHAT to build (requirements)
├── design.md        # HOW to build it (architecture)
├── tasks.md         # WHEN to build (implementation tasks)
├── journal.md       # Session discussion capture (via /afx:session)
└── research/        # ADRs, RFCs, decision records
```

### File Purposes

| File            | Purpose                                          | Updated When       | Reviewed By   |
| --------------- | ------------------------------------------------ | ------------------ | ------------- |
| `spec.md`       | Requirements, user stories, acceptance criteria  | Planning phase     | Stakeholders  |
| `design.md`     | Architecture, data models, API contracts         | Design phase       | Engineers     |
| `tasks.md`      | Implementation tasks with cross-references       | Pre-implementation | Engineers     |
| `journal.md`    | Session discussions, captured via `/afx:session` | During sessions    | Agent         |
| `research/*.md` | ADRs, RFCs, decision records                     | Design phase       | Human + Agent |

### Journal Structure

The `journal.md` file has three sections:

1. **Captures** - Quick notes during active chat (cleared when recorded)
2. **Discussions** - Permanent records with IDs (e.g., `UA-D001`)
3. **Work Sessions** - Task execution log (updated by `/afx:work`)

#### Discussion Status Keywords

Discussions use inline status tags for tracking ad-hoc work:

```markdown
### INF-D001 - 2025-12-22 - Warranty Claims Dev Deployment

`status:active` `[deployment, aws, user-auth]`

**Progress**:

- [x] RDS PostgreSQL setup
- [ ] Deploy to Amplify
```

| Keyword          | Meaning                             |
| ---------------- | ----------------------------------- |
| `status:active`  | Work in progress, has pending items |
| `status:blocked` | Waiting on external dependency      |
| `status:closed`  | Completed or abandoned              |
| _(no status)_    | Treated as closed (legacy)          |

Use `/afx:session active` to list all active discussions across features.

### Why tasks.md?

The `tasks.md` file bridges the gap between design and GitHub issues:

| Benefit                  | Description                                             |
| ------------------------ | ------------------------------------------------------- |
| **Hierarchical tasks**   | Numbered tasks (1.1, 1.2, 2.1) for easy cross-reference |
| **Spec traceability**    | Links tasks to requirements (`[REQ-FR-1]`)              |
| **Design traceability**  | Links tasks to design sections (`[DESIGN-3.1]`)         |
| **Pre-implementation**   | Captures cleanup tasks before coding starts             |
| **GitHub issue content** | Task groups become issue descriptions                   |
| **Progress tracking**    | Checkboxes track completion within each phase           |

---

## Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │     │                 │
│    spec.md      │────▶│   design.md     │────▶│   tasks.md      │────▶│    GitHub       │
│    (WHAT)       │     │    (HOW)        │     │    (WHEN)       │     │    (TRACK)      │
│                 │     │                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │                       │
        ▼                       ▼                       ▼                       ▼
   Requirements            Architecture            Task Breakdown          Implementation
   User Stories            Decisions               Phase Grouping          Tracked in Issues
   Acceptance              Data Models             Cross-References        Linked to Milestone
   Criteria                API Contracts           Cleanup Tasks
```

### Phase Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│  1. SPECIFY                                                       │
│     Write spec.md with requirements & acceptance criteria         │
│     Get stakeholder approval                                      │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. DESIGN                                                        │
│     Write design.md with architecture & technical decisions       │
│     Get engineering review                                        │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. TASK BREAKDOWN                                                │
│     Write tasks.md with hierarchical task numbering               │
│     Cross-reference spec requirements and design sections         │
│     Identify pre-implementation cleanup tasks                     │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  4. PLAN (GitHub)                                                 │
│     Create GitHub Milestone for the phase                         │
│     Create Epic issue linking to spec, design & tasks             │
│     Create task issues from tasks.md phase groups                 │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  5. IMPLEMENT                                                     │
│     Work through GitHub issues                                    │
│     Update tasks.md checkboxes as work completes                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## AgenticFlowX: AI-Assisted Development

When using AI agents (like Claude Code) for implementation, we extend the standard SDD workflow with **AgenticFlowX** principles:

### Key Concepts

| Concept                | Description                                                        |
| ---------------------- | ------------------------------------------------------------------ |
| **Session Continuity** | GitHub tickets serve as living execution logs, not just task lists |
| **Agent Resumption**   | Explicit workflow for agents to pick up interrupted work           |
| **Discovered Issues**  | First-class tracking of edge cases found during implementation     |
| **Session Logging**    | Timestamped audit trail of agent work sessions                     |
| **Granular Subtasks**  | File-level + change-level breakdown for precise agent guidance     |

### Core Principle

> The spec tells you _what_ to build. The GitHub ticket tells you _where you left off_.

### Agent Workflow

When an agent starts or resumes work:

1. **READ** GitHub ticket → See current state, what's done, what's pending
2. **CHECK** Session Log → Understand last session's work
3. **CHECK** Discovered Issues → See pending edge cases
4. **READ** linked spec/design → Get exact values, interfaces, patterns
5. **CONTINUE** from next unchecked subtask → Work through remaining items
6. **UPDATE** Session Log when done → Record what was accomplished

See the full **[AFX (AgenticFlowX)](../agenticflowx/agenticflowx.md)** guide for detailed GitHub ticket templates, AFX commands, and examples.

---

## Integration with GitHub

### Milestones

- Create one milestone per feature phase (e.g., "Warranty Claims MVP")

### Epic Issues

Create an epic issue that references all spec documents:

```markdown
## Warranty Claims MVP

**Spec:** docs/specs/user-auth/spec.md
**Design:** docs/specs/user-auth/design.md
**Tasks:** docs/specs/user-auth/tasks.md

### Implementation Issues

- [ ] #43 - Phase 1: Kysely + Types Setup (tasks 1.1-1.5)
- [ ] #44 - Phase 2: Repository + Service (tasks 2.1-2.5)
- [ ] #45 - Phase 3: Server Actions + S3 (tasks 3.1-3.4)
      ...
```

### Task Issues

Individual issues for each implementation task:

- Reference the spec for acceptance criteria
- Link to the epic issue
- Assign to milestone

---

## Using with Claude Code

### Reference Specs in Prompts

When starting work on a feature, point Claude Code to the specs:

```
Read the spec at docs/specs/user-auth/spec.md and the design
at docs/specs/user-auth/design.md, then implement the
PostgreSQL connection layer.
```

### Let Claude Code Read Context

Claude Code can read these files to understand:

- What the feature should do (spec.md)
- How it should be built (design.md)
- What tasks need to be done (tasks.md)

### Generate Tasks from Specs

Ask Claude Code to help break down work:

```
Based on the design in docs/specs/user-auth/design.md,
create a list of GitHub issues for Phase 1 implementation.
```

---

## Directory Structure

```
docs/
├── agenticflowx/                # AgenticFlowX Framework
│   ├── agenticflowx.md         # AFX Framework Reference
│   ├── guide.md                # SDD Guide (This file)
│   └── templates/              # Spec templates (spec, design, tasks, journal, adr)
│
├── specs/                      # Spec-driven feature docs
│   ├── journal.md              # Global discussions
│   ├── research/               # Global ADRs
│   ├── {feature}/              # Feature Modules
│   │   ├── spec.md
│   │   ├── design.md
│   │   ├── tasks.md
│   │   ├── journal.md          # Session discussions (via /afx:session)
│   │   └── research/           # ADRs, RFCs, decision records
│
├── guides/                     # Tool-specific documentation
│   ├── shadcnui.md
│   ├── jest.md
│   └── ...
│
└── _archive/                   # Archived old docs
```

---

## Creating a New Feature Spec

1. Copy templates to new folder:

   ```bash
   cp -r docs/agenticflowx/templates docs/specs/{feature-name}
   ```

2. Fill out `spec.md` with requirements

3. Get stakeholder approval

4. Fill out `design.md` with architecture

5. Get engineering review

6. Fill out `tasks.md` with implementation breakdown

7. Create GitHub milestone and issues (from tasks.md phases)

---

## References

This approach is inspired by:

- **[GitHub Spec Kit](https://github.com/github/spec-kit)** - Open-source toolkit for spec-driven development with AI coding assistants

- **[Spec-Driven Methodology](https://github.com/github/spec-kit/blob/main/spec-driven.md)** - Detailed methodology documentation

- **[GitHub Blog: Spec-driven development with AI](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)** - Introduction to the approach

- **[Martin Fowler: Understanding Spec-Driven Development](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)** - Comparison of SDD tools (Kiro, Spec Kit, Tessl)

- **[AWS Kiro](https://kiro.dev)** - AWS's spec-driven IDE built on similar principles

---

## Quick Reference

| I want to...                        | Go to...                       |
| ----------------------------------- | ------------------------------ |
| Understand what a feature should do | `{feature}/spec.md`            |
| Understand how it's built           | `{feature}/design.md`          |
| See what tasks need to be done      | `{feature}/tasks.md`           |
| Create a new feature                | Copy `templates/` folder       |
| Set up AI-assisted development      | `agenticflowx/agenticflowx.md` |
| Find tool-specific docs             | `docs/guides/`                 |
