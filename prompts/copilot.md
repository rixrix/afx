# AFX copilot-instructions.md Snippet

> Copy everything below this line into your .github/copilot-instructions.md file.

---

## AgenticFlowX (AFX)

This project uses **AgenticFlowX (AFX)** for spec-driven development. Read `docs/agenticflowx/agenticflowx.md` for the full framework reference.

### Key Rules

- All work originates from approved specs (`docs/specs/{feature}/spec.md`, `design.md`, `tasks.md`, `journal.md`)
- Code MUST include `@see` annotations linking back to specs: `/** @see docs/specs/{feature}/design.md#section */`
- Gate 1 (`/afx:check path`) is **blocking** — tasks cannot close without path verification
- Tasks require both Agent (`[x]`) AND Human (`[x]`) approval before completion

### Commands

AFX prompts are in `.github/prompts/afx-*.prompt.md`. Each delegates to canonical definitions in `.claude/commands/afx-*.md` — read the source command fully before executing.

### Git Commit Attribution

```
Co-authored-by: copilot <noreply@github.com>
```
