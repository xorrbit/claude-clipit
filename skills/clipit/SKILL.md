---
name: clipit
description: Copy the last Claude response to your clipboard
allowed-tools: [Bash]
user-invocable: true
---

Copy the last assistant response to the clipboard by running:

~/.claude/scripts/clipit-copy.sh < ~/.claude/clipit/latest.md

The user may include flags after `/clipit`. Flags can be combined:
- `/clipit raw` — skip unicode normalization: add `CLIPIT_RAW=1`
- `/clipit normalize` — force unicode normalization: add `CLIPIT_NORMALIZE=1`
- `/clipit md` — keep markdown formatting: add `CLIPIT_MD=1`
- `/clipit plain` — force plain text (strip markdown): add `CLIPIT_PLAIN=1`

Examples:
- `/clipit md` → `CLIPIT_MD=1 ~/.claude/scripts/clipit-copy.sh < ~/.claude/clipit/latest.md`
- `/clipit raw md` → `CLIPIT_RAW=1 CLIPIT_MD=1 ~/.claude/scripts/clipit-copy.sh < ~/.claude/clipit/latest.md`

If no flags are given, use the default command (which respects config files in `~/.claude/clipit/`).

If the file does not exist, respond with "No saved response found. The clipit hook may not have fired yet — try again after the next response."

Otherwise confirm with "Copied to clipboard." Do not read or restate the file contents.
