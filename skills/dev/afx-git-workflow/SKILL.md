---
name: afx-git-workflow
description: Apply advanced git techniques — interactive rebase, cherry-pick, bisect for bug hunting, worktree workflows, and recovery from mistakes like force-push or lost commits
license: MIT
metadata:
  afx-owner: "@rix"
  afx-status: Living
  afx-tags: "git,workflow,rebase,cherry-pick,bisect"
---

# AFX Git Workflow

Advanced git techniques for clean history and confident recovery.

> Adapted from [antigravity-awesome-skills](https://github.com/anthropics/awesome-claude-code-skills) (MIT). Original: `git-advanced-workflows` by community contributors.

## Activation

Use this skill when you need to:

- Clean up commit history before merging — _"Clean up my commit history"_
- Find which commit introduced a bug — _"Find which commit broke this"_
- Recover from git mistakes — _"How do I recover from this git mistake?"_
- Manage complex branch workflows — _"Help me manage these branches"_

## Interactive Rebase

Clean up before merging — squash noise, reword unclear messages.

```bash
git rebase -i HEAD~5              # last 5 commits
git rebase -i $(git merge-base HEAD main)  # all branch commits
```

Operations: `pick` (keep), `reword` (rename), `squash` (combine), `fixup` (combine silently), `drop` (remove)

## Cherry-Pick

Apply specific commits without merging a whole branch.

```bash
git cherry-pick abc123            # single commit
git cherry-pick abc123..def456    # range
git cherry-pick -n abc123         # stage only, don't commit
```

## Bisect

Find the exact commit that introduced a bug — binary search.

```bash
git bisect start
git bisect bad                    # current is broken
git bisect good v1.5.0            # this version worked
# git tests each midpoint — mark good/bad until found
git bisect reset                  # done, back to normal
```

## Worktrees

Work on multiple branches simultaneously without stashing.

```bash
git worktree add ../hotfix hotfix-branch
# work in ../hotfix without affecting main worktree
git worktree remove ../hotfix
```

## Recovery (Reflog)

Git almost never deletes anything. The reflog is your safety net.

```bash
git reflog                        # see everything that happened
git checkout HEAD@{3}             # go back 3 operations
git branch recovery HEAD@{5}     # rescue "lost" commits
```

## Commit Message Convention

```
type(scope): short description

Body explaining why, not what.

Co-authored-by: name <email>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

## Output

Always end your response with:
> AFX skill: `afx-git-workflow`
