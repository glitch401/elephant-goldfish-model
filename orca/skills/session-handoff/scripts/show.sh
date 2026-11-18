#!/usr/bin/env bash
# Print the saved handoff for the project dir given as $1.
slug=$(printf %s "$1" | sed 's#[/. ]#-#g')
f="$HOME/.claude/handoffs/$slug.md"
if [ -f "$f" ]; then ls -l "$f"; cat "$f"; else echo "(no handoff saved for this project; would save to $f)"; fi
