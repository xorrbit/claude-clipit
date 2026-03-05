---
name: clipit
description: Copy the last Claude response to your clipboard
allowed-tools: [Bash, Read]
user-invocable: true
---

If the file `~/.claude/clipit/latest.md` does not exist, respond with "No saved response found. The clipit hook may not have fired yet — try again after the next response."

## Mode 1: Copy entire response

If the user runs `/clipit` with no arguments or only flags, copy the full response:

~/.claude/scripts/clipit-copy.sh < ~/.claude/clipit/latest.md

Flags can be combined (e.g. `/clipit raw md`):
- `raw` — skip unicode normalization: add `CLIPIT_RAW=1`
- `normalize` — force unicode normalization: add `CLIPIT_NORMALIZE=1`
- `md` — keep markdown formatting: add `CLIPIT_MD=1`
- `plain` — force plain text (strip markdown): add `CLIPIT_PLAIN=1`

Example: `/clipit raw md` → `CLIPIT_RAW=1 CLIPIT_MD=1 ~/.claude/scripts/clipit-copy.sh < ~/.claude/clipit/latest.md`

## Mode 2: Extract and copy a specific part

If the user includes a description of what to extract (e.g. `/clipit the curl command`, `/clipit just the python function`, `/clipit the SQL query`):

1. Read `~/.claude/clipit/latest.md`
2. Extract exactly the part the user described — nothing more. No explanation, no surrounding text.
3. Pipe the extracted text to the clipboard: `echo '<extracted>' | ~/.claude/scripts/clipit-copy.sh`

Unless the user explicitly includes flags, infer the right output format from context:
- Code (commands, functions, queries, etc.) → copy verbatim with `CLIPIT_RAW=1 CLIPIT_MD=1` to preserve exact content
- Prose or mixed content → use defaults (normalize unicode, strip markdown)

If the user explicitly passes flags, always honor those instead.

## After copying

Confirm with "Copied to clipboard." Do not read or restate the file contents.
