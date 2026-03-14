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

| Command         | Purpose                            |
| --------------- | ---------------------------------- |
| `/afx-discover` | Project discovery (tools, scripts) |
| `/afx-init`     | Feature spec scaffolding           |
| `/afx-session`  | Discussion capture                 |
| `/afx-work`     | Task execution                     |
| `/afx-update`   | Framework update maintenance       |
