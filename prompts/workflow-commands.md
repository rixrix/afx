# AgenticFlowX - Session Continuity

> Add this section to your CLAUDE.md to enable AFX workflow commands and session continuity.

```markdown
## AgenticFlowX - Session Continuity

This project uses **AgenticFlowX (AFX)** for spec-driven development with session continuity. GitHub tickets serve as living execution logs, not just task lists.

### Core Principle

The spec tells you _what_ to build. The GitHub ticket tells you _where you left off_.

### Session Continuity Rules

**CRITICAL**: After completing work on a GitHub ticket, ALWAYS update:

1. **Session Log**: Add timestamped entry with task, action, files modified
2. **Discovered Issues**: Document any unexpected findings
3. **Decisions Made**: Record rationale for choices
4. **Subtask Checkboxes**: Mark completed items

### Session Log Format

\`\`\`markdown
| Date | Task | Action | Files Modified |
| ---------------- | ---- | ---------------------------- | ---------------------- |
| 2025-12-07 14:30 | 4.1 | Completed email templates | mailer/templates/\*.ts |
| 2025-12-07 15:00 | 4.2 | Integrated mailer in actions | claim.action.ts |
\`\`\`

### GitHub Ticket Workflow

1. **Starting work**: Read GitHub ticket, check Session Log for last entry
2. **During work**: Check off subtasks as completed
3. **Completing work**: Update Session Log with final entry
4. **Before closing**: Verify all subtasks checked, run verification commands

### Agent Resumption Workflow

When starting or resuming work on a ticket:

1. **READ** GitHub ticket - see current state, what's done, what's pending
2. **CHECK** Session Log - understand last session's work
3. **CHECK** Discovered Issues - see pending edge cases
4. **READ** linked spec/design - get exact values, interfaces, patterns
5. **CONTINUE** from next unchecked subtask
6. **UPDATE** Session Log when done

### Commands

**Discovery**

- `/afx:discover capabilities` - High-level project overview (what exists)
- `/afx:discover infra [type]` - Find infrastructure provisioning scripts
- `/afx:discover scripts [keyword]` - Find automation/deployment scripts
- `/afx:discover tools` - List dev/deployment tools

**Work Orchestration**

- `/afx:work status` - Quick state check after interruption
- `/afx:work next <spec-path>` - Pick next task from spec
- `/afx:work resume [spec|num]` - Continue in-progress work
- `/afx:work sync [spec] [issue]` - Bidirectional GitHub sync
- `/afx:work plan [instruction]` - Generate tickets from specs

**Task Verification**

- `/afx:task verify <task-id>` - Verify task implementation vs spec
- `/afx:task summary <task-id>` - Get implementation summary
- `/afx:task list [phase]` - List tasks by phase
- `/afx:task status` - Overall task completion

**Quality Checks**

- `/afx:check path <feature-path>` - Trace execution path UI → DB (Gate 1)
- `/afx:check lint [path]` - Audit annotations for PRD compliance
- `/afx:check links <spec-path>` - Verify cross-references
- `/afx:check all <feature-path>` - Run all checks

**Development Actions**

- `/afx:dev code [instruction]` - Implement with @see traceability
- `/afx:dev debug [error]` - Debug with spec trace
- `/afx:dev refactor [scope]` - Refactor maintaining spec alignment
- `/afx:dev review [scope]` - Code review against specs
- `/afx:dev test [scope]` - Run/generate tests

**Session Capture**

- `/afx:session note "content" [tags]` - Smart note (unifies capture/append)
- `/afx:session save [feature]` - Save session to log
- `/afx:session show [feature|all]` - Show recent discussions
- `/afx:session active [feature|all]` - Show active discussions
- `/afx:session search "query"` - Search notes across journals
- `/afx:session recap [feature|all]` - Recap for resumption
- `/afx:session promote <id>` - Promote discussion to ADR
- `/afx:next` - Context-aware "Golden Thread" guidance

**Reporting**

- `/afx:report health [spec]` - Overall traceability metrics
- `/afx:report orphans [path]` - Code without @see links
- `/afx:report coverage <spec>` - Spec → Code coverage map

**Setup & Context**

- `/afx:init feature <name>` - Create new feature spec
- `/afx:init adr <title>` - Create global ADR in `docs/adr/`
- `/afx:context save [feature]` - Generate context bundle
- `/afx:context load` - Load context from previous context
- `/afx:help` - Show command reference

### Session Discussion Capture

Use `/afx:session` to capture important discussions with AI agents:

\`\`\`bash
/afx:next # "What do I do now?"
/afx:session note "content" # Smart note (auto-tags)
/afx:session note --ref UA-D001 "content" # Append to discussion
/afx:session save [feature] # Summarize session to log
/afx:session show [feature|all] # Show recent discussions
/afx:session search "query" # Search notes
/afx:session promote <id> # Promote to ADR
\`\`\`

Discussions are stored in `docs/specs/{feature}/journal.md` with auto-generated tags for filtering.
```
