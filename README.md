# clipit

Copy the last Claude Code response to your clipboard with `/clipit`.

## How it works

clipit has two parts:

1. **A Stop hook** that runs after every Claude response and saves the output to `~/.claude/clipit/latest.md`. This runs locally with zero token cost.
2. **A skill** (`/clipit`) that copies the saved file to your system clipboard.

## Requirements

- macOS, Linux, or WSL
- A clipboard command: `pbcopy` (macOS), `xclip`, `xsel`, or `wl-copy` (Linux), or `clip.exe` (WSL)
- [jq](https://jqlang.github.io/jq/) (`brew install jq` / `apt install jq`)
- Claude Code 2.x+

## Install

The easiest way is to just tell Claude Code to do it:

```
install this: https://github.com/xorrbit/claude-clipit
```

### Manual install

```bash
git clone https://github.com/xorrbit/claude-clipit.git ~/dev/clipit
cd ~/dev/clipit
./install.sh
```

The install script copies the hook script and skill into `~/.claude/` and checks for required dependencies. You then need to add the Stop hook to your `~/.claude/settings.json`.

If you don't have any hooks yet, add this to your `settings.json`:

```json
{
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
}
```

If you already have a `"Stop"` hook, just add the clipit entry to your existing hooks array:

```json
{ "type": "command", "command": "~/.claude/scripts/clipit-save.sh" }
```

Then restart Claude Code.

## Usage

Just type `/clipit` in Claude Code. The last response will be copied to your clipboard as plain text.

### Flags

Flags can be combined (e.g. `/clipit raw md`):

| Flag | Effect |
|------|--------|
| `/clipit md` | Keep markdown formatting |
| `/clipit plain` | Force plain text (strip markdown) |
| `/clipit raw` | Skip unicode normalization |
| `/clipit normalize` | Force unicode normalization |
| `/clipit raw md` | Keep markdown and skip normalization |

### Defaults

By default, clipit strips markdown and normalizes common unicode characters:

| Unicode | Replacement |
|---------|-------------|
| `—` (em dash) | `-` |
| `–` (en dash) | `-` |
| `→` | `->` |
| `←` | `<-` |

To change defaults, create config files in `~/.claude/clipit/`:

```bash
touch ~/.claude/clipit/keep-markdown    # keep markdown by default
touch ~/.claude/clipit/no-normalize     # skip normalization by default
```

## How tokens are used

The Stop hook (which saves every response) is completely free — it runs as a local shell command with no LLM involvement.

The `/clipit` skill does use tokens. Claude Code skills are LLM-driven, so Claude reads the short skill prompt (~150 tokens) and generates the clipboard command (~30 tokens). However, like any Claude Code interaction, the total cost depends on the size of your current conversation context — the skill prompt is a small fixed addition on top of what's already in the context window.
## FAQ

### Why not use an MCP server instead?

MCP tools still consume tokens. Every MCP tool call requires Claude to read the tool's schema, decide to invoke it, and process the result, all of which use tokens. An MCP-based clipboard tool would cost tokens on *every single response* just to capture it.

clipit avoids this by using a **Stop hook**, which is a plain shell command that runs locally after each response with zero LLM involvement. The only time tokens are spent is when you explicitly type `/clipit` to copy — and even then it's a tiny, fixed cost. So you get always-on response capture for free, and only pay a few tokens when you actually want to copy something.

### How do I use this with zero token cost?

Skip the `/clipit` skill entirely and just use the saved file directly. The Stop hook saves every response to `~/.claude/clipit/latest.md` at zero cost, so you can copy it yourself:

```bash
~/.claude/scripts/clipit-copy.sh < ~/.claude/clipit/latest.md
```

Or read it with any tool you like. The `/clipit` skill is just a convenience wrapper that costs a few tokens and lets you copy without leaving the Claude Code TUI.

### What about multiple concurrent sessions?

clipit saves to a single file (`latest.md`), so if you're running multiple sessions, `/clipit` will always copy the most recent response across all of them. In practice this is fine — the Stop hook fires right after each response, so `/clipit` will grab the response you just saw. Per-session tracking would be ideal, but Claude Code doesn't currently expose the session ID to the bash environment where skills execute, only to hooks.

### Doesn't saving responses to a file expose sensitive information?

clipit saves the last response to `~/.claude/clipit/latest.md`, which is a plain text file on disk. However, Claude Code already saves full conversation history locally in `~/.claude/`, so clipit doesn't expose anything that isn't already stored. The file is overwritten on every response, so only the most recent one is ever on disk.

### Why not use a Claude Code plugin instead?

Plugins also use tokens — they're loaded into Claude's context as tool definitions, and every invocation requires Claude to generate a tool call and process the response. But more importantly, plugins don't have a way to passively run on every response the way a Stop hook does. A plugin would only fire when explicitly invoked, meaning you'd have to call it every time you want to capture a response. clipit's hook silently saves every response in the background at zero cost, so the clipboard is always ready when you need it.

## Uninstall

```bash
rm ~/.claude/scripts/clipit-save.sh ~/.claude/scripts/clipit-copy.sh
rm -rf ~/.claude/skills/clipit ~/.claude/clipit
```

Then remove the clipit hook entry from `~/.claude/settings.json`.
