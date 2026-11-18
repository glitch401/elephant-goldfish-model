#!/bin/sh
# Orca worker Stop hook: refuse to stop while the task's CHECK fails.
# The lead writes .orca-check (the command) and .orca-report (report path) into the worktree.
input=$(cat)
[ -f .orca-check ] || exit 0
case "$input" in *'"stop_hook_active":true'*) exit 0;; esac   # already pushed back once; the lead's gate catches the rest
report=$(cat .orca-report 2>/dev/null)
[ -n "$report" ] && grep -qsE 'STATUS: (STUCK|NEEDS-DECISION)' "$report" && exit 0
out=$(sh .orca-check 2>&1) && exit 0
printf 'CHECK failed. Fix it, or mark STATUS: STUCK in the report, before stopping.\n%s\n' "$(printf '%s' "$out" | tail -20)" >&2
exit 2
