---
name: session-handoff
description: Save or restore a session handoff so work survives /compact, a usage limit or a fresh session. Use when the user says "continue", "pick up where we left off", "we left off at…", "I'll be afk", runs /compact, or a session starts from a continuation summary.
when_to_use: Also use before a long autonomous run ("take all the decisions you need") and when context is getting long. `/session-handoff save` writes the handoff, `/session-handoff resume` (or a bare "continue" in a project that has one) restores it.
argument-hint: "[save|resume]"
arguments: [mode]
effort: low
allowed-tools: Read Write Bash(git status *) Bash(git branch *) Bash(git log *) Bash(git diff *) Bash(git worktree list) Bash(ls *) Bash(cat *) Bash(*/session-handoff/scripts/show.sh*)
metadata:
  color: "#d97706"
  family: continuity
  self-learning: learned.md
---

# session-handoff

A handoff is a short file that lets a cold session continue correctly. It lives outside
the repo so it never gets committed: `~/.claude/handoffs/<project-slug>.md`, where the
slug is the project path with `/`, `.` and spaces replaced by `-`.

## Learned rules (read first)

!`cat "${CLAUDE_SKILL_DIR}/learned.md" 2>/dev/null || true`

## Saved handoff for this project

!`"${CLAUDE_SKILL_DIR}/scripts/show.sh" "${CLAUDE_PROJECT_DIR}"`

Mode: `$mode`. If empty, resume when a handoff exists above, otherwise save.

## Save

Write the file (overwrite, do not append). Keep it under about 60 lines. Sections:

1. **Goal**: one sentence, in the user's words.
2. **State**: what is done, what is half done, what is verified versus assumed. Include
   branch, last commit, uncommitted files (from `git status`/`git log`, not from memory),
   running processes or remote services, and exact commands that were last run.
3. **Next step**: the single next action, concrete enough to start without questions.
4. **Open decisions**: what the user still has to decide, with your recommendation.
5. **Autonomy**: if the user said they are away or told you to decide, record the
   decisions already made and the limits they set (for example "no pushing").
6. **Do not**: dead ends already tried and standing prohibitions from this session.

Then, before compaction or exit, write any durable fact (a rule the user stated, a path,
a correction) to memory instead of burying it in the handoff. Handoffs describe work in
flight; memory holds what stays true.

Never put secrets, tokens or key material in a handoff.

## Resume

1. Read the handoff above. Treat it as a claim about the past, not as truth.
2. **Verify before acting:** run `git status`, `git branch --show-current` and
   `git log -3 --oneline`; check any remote service or process the handoff names. If the
   repo no longer matches the State section, say what changed and ask before continuing.
3. State the goal and next step back in two lines, then start. Do not re-explain the
   whole history, and do not redo steps the handoff marks done and verified.
4. If the handoff is more than a few days old, say so and re-confirm the goal.
5. When the work finishes, delete or update the handoff so a stale one never misleads.

## Self-learning

If the user corrects what a handoff missed ("you forgot that I said…"), add a line to
[learned.md](learned.md): `- YYYY-MM-DD: <rule> (why: <correction>)`, and add the field
to the Save sections if it is a recurring gap.
