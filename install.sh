#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install it with: brew install jq"
    exit 1
fi

if ! command -v pbcopy &> /dev/null && ! command -v wl-copy &> /dev/null && ! command -v xclip &> /dev/null && ! command -v xsel &> /dev/null && ! command -v clip.exe &> /dev/null; then
    echo "Error: no supported clipboard command found."
    echo "Install one of: pbcopy (macOS), xclip, xsel, wl-copy (Linux), or clip.exe (WSL)."
    exit 1
fi

# Install the Stop hook script
mkdir -p ~/.claude/scripts
cp "$SCRIPT_DIR/scripts/clipit-save.sh" ~/.claude/scripts/clipit-save.sh
cp "$SCRIPT_DIR/scripts/clipit-copy.sh" ~/.claude/scripts/clipit-copy.sh
chmod +x ~/.claude/scripts/clipit-save.sh ~/.claude/scripts/clipit-copy.sh

# Install the skill
mkdir -p ~/.claude/skills/clipit
cp "$SCRIPT_DIR/skills/clipit/SKILL.md" ~/.claude/skills/clipit/SKILL.md

# Create the clipit data directory
mkdir -p ~/.claude/clipit

echo "clipit installed!"
echo ""
echo "One manual step required: add the Stop hook to ~/.claude/settings.json"
echo ""
echo "If you already have a \"Stop\" hook, add this to your existing hooks array:"
echo ""
echo '  { "type": "command", "command": "~/.claude/scripts/clipit-save.sh" }'
echo ""
echo "If you don't have any hooks yet, add this to your settings.json:"
echo ""
cat <<'EXAMPLE'
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/clipit-save.sh"
          }
        ]
      }
    ]
  }
EXAMPLE
echo ""
echo "Then restart Claude Code and use /clipit to copy the last response."
