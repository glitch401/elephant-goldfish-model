#!/usr/bin/env bash
# PreToolUse guard for the ship-branch skill. Reads the hook JSON on stdin and
# blocks the git/gh commands that can destroy work. Exit 2 = block, with the
# reason on stderr. Normal push / PR / merge are not blocked here: the skill
# only runs them when the user's request names them.
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

block() { echo "ship-branch guard: $1 Ask the user first." >&2; exit 2; }

case "$cmd" in
  *"git push"*" --force "*|*"git push"*" -f "*|*"git push"*" --force"|*"git push"*" -f"|*"git push"*"+"*:*)
    block "force-push blocked (use --force-with-lease only if the user asked)." ;;
  *"git branch -D"*|*"git branch --delete --force"*)
    block "force-deleting a branch (-D) can lose unmerged commits." ;;
  *"git reset --hard"*|*"git clean -f"*|*"git checkout -- ."*|*"git restore ."*)
    block "this discards uncommitted work." ;;
  *"gh pr merge"*"--admin"*)
    block "--admin bypasses branch protection." ;;
esac
exit 0
