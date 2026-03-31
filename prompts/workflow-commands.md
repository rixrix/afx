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

The Work Sessions table in `tasks.md` must be the **last section** in the file. Append rows — never replace existing ones.

\`\`\`markdown
| Date | Task | Action | Files Modified | Agent | Human |
| ---------- | ---- | --------- | ----------------------- | ----- | ----- |
| 2025-12-07 | 4.1 | Coded | mailer/templates/\*.ts | [x] | - |
| 2025-12-07 | 4.2 | Completed | claim.action.ts | [x] | - |
\`\`\`

### Agent Resumption Workflow

When starting or resuming work on a ticket:

1. **READ** GitHub ticket - see current state, what's done, what's pending
2. **CHECK** Session Log - understand last session's work
3. **CHECK** Discovered Issues - see pending edge cases
4. **READ** linked spec/design - get exact values, interfaces, patterns
5. **CONTINUE** from next unchecked subtask
6. **UPDATE** Session Log when done

### Commands

**Spec Lifecycle**

- `/afx-spec create <name>` - Initialize new feature spec
- `/afx-spec validate <name>` - Check spec structure integrity
- `/afx-spec review <name>` - Automated quality scoring
- `/afx-spec approve <name>` - Approve spec (unlocks design phase)

**Design Lifecycle**

- `/afx-design author <name>` - Generate design.md from approved spec
- `/afx-design validate <name>` - Check design structure and traceability
- `/afx-design review <name>` - Advisory quality check
- `/afx-design approve <name>` - Approve design (unlocks task planning)

**Task Lifecycle & Implementation**

- `/afx-task plan <name>` - Generate tasks.md from approved design
- `/afx-task pick <id>` - Check out a task as active
- `/afx-task code <id>` - Implement with @see traceability
- `/afx-task verify <id>` - Verify task implementation vs spec
- `/afx-task complete <id>` - Mark task done
- `/afx-task sync [spec] [issue]` - Bidirectional GitHub sync
- `/afx-task brief <id>` - Get implementation summary
- `/afx-task review <name>` - Check for planning gaps

**Advanced Diagnostics**

- `/afx-dev debug [error]` - Debug with spec trace
- `/afx-dev refactor [scope]` - Refactor maintaining spec alignment
- `/afx-dev review [scope]` - Code review against specs
- `/afx-dev test [scope]` - Run/generate tests
- `/afx-dev optimize [target]` - Performance optimization

**Quality Checks**

- `/afx-check path <feature-path>` - Trace execution path UI → DB (Gate 1)
- `/afx-check trace [path]` - Audit annotations for PRD compliance
- `/afx-check links <spec-path>` - Verify cross-references
- `/afx-check deps [feature]` - Validate dependency graph
- `/afx-check coverage <spec-path>` - Spec-to-code coverage map
- `/afx-check all <feature-path>` - Run all checks

**Discovery**

- `/afx-discover capabilities` - High-level project overview (what exists)
- `/afx-discover infra [type]` - Find infrastructure provisioning scripts
- `/afx-discover scripts [keyword]` - Find automation/deployment scripts
- `/afx-discover tools` - List dev/deployment tools

**Session Capture**

- `/afx-session note "content" [tags]` - Smart note (unifies capture/append)
- `/afx-session log [feature]` - Save session to log
- `/afx-session active [feature|all]` - Show active discussions
- `/afx-session recap [feature|all]` - Recap for resumption
- `/afx-session promote <id>` - Promote discussion to ADR
- `/afx-next` - Context-aware "Golden Thread" guidance

**Reporting**

- `/afx-report health [spec]` - Overall traceability metrics
- `/afx-report orphans [path]` - Code without @see links
- `/afx-report coverage <spec>` - Spec → Code coverage map

**Setup & Context**

- `/afx-init feature <name>` - Create new feature spec
- `/afx-init adr <title>` - Create global ADR in `docs/adr/`
- `/afx-context save [feature]` - Generate context bundle
- `/afx-context load` - Load context from previous context
- `/afx-hello` - Environment diagnostics
- `/afx-help` - Show command reference

### Session Discussion Capture

Use `/afx-session` to capture important discussions with AI agents:

\`\`\`bash
/afx-next # "What do I do now?"
/afx-session note "content" # Smart note (auto-tags)
/afx-session note --ref UA-D001 "content" # Append to discussion
/afx-session log [feature] # Summarize session to log
/afx-session active [feature|all] # Show active discussions
/afx-session promote <id> # Promote to ADR
\`\`\`

Discussions are stored in `docs/specs/{feature}/journal.md` with auto-generated tags for filtering.
```
