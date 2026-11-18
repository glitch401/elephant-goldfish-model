---
name: ship-branch
description: Run the user's commit → push → PR → merge → cleanup sequence, doing exactly the steps they name and no more. Use only when the user says "ship it", "push; create pr; merge to main", "merge it and pull main", or invokes /ship-branch.
when_to_use: Needs explicit wording. "commit this" alone means commit and stop. This skill never pushes, switches branches or deletes branches on its own; the user has corrected that more than once.
argument-hint: "[steps, e.g. 'push; pr; merge; delete branch; pull main']"
arguments: [steps]
disable-model-invocation: true
effort: medium
allowed-tools: Bash(cat *) Bash(git status *) Bash(git diff *) Bash(git log *) Bash(git branch) Bash(git branch --show-current) Bash(git branch -vv) Bash(git remote -v) Bash(git worktree list) Bash(gh pr view *) Bash(gh pr list *) Bash(gh pr checks *) Bash(gh repo view *)
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "${CLAUDE_SKILL_DIR}/scripts/guard.sh"
metadata:
  color: "#16a34a"
  family: git
  self-learning: learned.md
---

# ship-branch

Do the steps the user named, in order, and stop. Read-only git/gh inspection is
pre-approved; every write (commit, push, PR, merge, delete) goes through the normal
permission flow on purpose.

## Learned rules (read first, they override defaults below)

!`cat "${CLAUDE_SKILL_DIR}/learned.md" 2>/dev/null || true`

## Current state

!`git status --short --branch 2>&1 || true`
!`git log -5 --oneline 2>&1 || true`

## Requested steps

`$steps`

If that is empty, restate what the user last asked in this conversation. If it names no
git action, ask which of these they want: **commit, push, PR, merge, delete branch,
rebase/pull main**. Do not assume the full sequence.

## Hard rules

1. **No push without an explicit "push".** Creating a feature locally means local only.
2. **No creating or switching branches** unless the user said to. If they say changes go
   on `main`, stay on `main`.
3. **No deleting a branch** unless the user named it in this request ("delete this
   feature branch"). "Don't delete it this time" is a standing instruction for that
   task.
4. Never force-push, `reset --hard`, `branch -D` or `clean -f` (a guard hook blocks
   them; do not look for a way around it).
5. Never skip hooks or checks (`--no-verify`). If a check fails, stop and report.

## The sequence (run only the named steps)

1. **Inspect:** `git status`, `git diff --stat`, current branch, upstream, and whether
   the branch is behind `main`. Tell the user what will ship before writing anything.
2. **Commit:** stage specific files, never `git add -A` over unrelated changes. Run the
   project's tests first if the user named tests or CLAUDE.md lists a test command. Write
   a message that matches the repo's recent style and end it with the attribution
   trailer the session specifies.
3. **Push:** `git push -u origin <branch>`, to the branch the user is on.
4. **PR:** `gh pr create` with a title under 70 characters and a body of what changed
   and how it was verified. End the body with the session's attribution line. Return the
   URL.
5. **Merge:** `gh pr merge <n> --merge` unless the repo or the user prefers squash or
   rebase; check `gh pr checks` first and stop on red.
6. **Cleanup:** delete the remote and local feature branch only if named. Then
   `git checkout main && git pull origin main` ("rebase to main and pull" means update
   the local `main`, and rebase only if the user says rebase).
7. **Report:** one line per step: done, skipped (and why) or failed (with output), plus
   the final `git status` and PR URL.

## Self-learning

If the user corrects what you did to git ("I didn't ask you to push", "wrong branch",
"don't delete it"), append `- YYYY-MM-DD: <rule> (why: <correction>)` to
[learned.md](learned.md), replacing any older line it contradicts. If the correction is
about all work and not just git shipping, also tell the user it belongs in CLAUDE.md or
memory.
