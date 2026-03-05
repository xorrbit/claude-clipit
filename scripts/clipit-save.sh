#!/bin/bash
set -e

# Save the last assistant message from a Claude Code Stop hook.
input=$(cat)
mkdir -p ~/.claude/clipit
printf '%s' "$input" | jq -r '.last_assistant_message // empty' > ~/.claude/clipit/latest.md
