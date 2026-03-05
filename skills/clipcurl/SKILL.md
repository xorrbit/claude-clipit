---
name: clipcurl
description: Extract and copy just the curl command from the last Claude response
allowed-tools: [Bash, Read]
user-invocable: true
---

If the file `~/.claude/clipit/latest.md` does not exist, respond with "No saved response found. The clipit hook may not have fired yet — try again after the next response."

1. Read `~/.claude/clipit/latest.md`
2. Extract just the curl command — nothing else. No explanation, no surrounding text.
3. Copy it verbatim: `echo '<extracted>' | CLIPIT_RAW=1 CLIPIT_MD=1 ~/.claude/scripts/clipit-copy.sh`

Confirm with "Copied curl command to clipboard." Do not read or restate the content.
