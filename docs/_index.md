---
afx: true
type: MOC
status: Living
tags: [agenticflow, afx, moc]
---

# AgenticFlow

> **Session continuity for AI-assisted development**

---

## Core Docs

- [[agenticflow|Main Guide]]
- [[guide|Quick Reference]]

---

## Templates

```dataview
TABLE WITHOUT ID
  file.link as "Template",
  type as "Type"
FROM "agenticflow/templates"
SORT file.name ASC
```

---

## Commands

> Note: AFX skills are installed to `.claude/skills/` (Claude Code) and `.agents/skills/` (Codex, Copilot, Antigravity).

| Command         | Purpose                                            |
| --------------- | -------------------------------------------------- |
| `/afx-spec`     | Spec management — validate, review, approve        |
| `/afx-design`   | Design authoring, validation, and approval         |
| `/afx-task`     | Implementation lifecycle — plan, pick, code, sync  |
| `/afx-dev`      | Advanced diagnostics — debug, refactor, test       |
| `/afx-check`    | Quality gates — path, trace, links, deps, coverage |
| `/afx-init`     | Feature spec scaffolding                           |
| `/afx-session`  | Discussion capture                                 |
| `/afx-discover` | Project discovery (tools, scripts)                 |
| `/afx-next`     | Context-aware "what should I do now?"              |
| `/afx-hello`    | Environment diagnostics                            |
