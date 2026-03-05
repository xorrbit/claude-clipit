#!/bin/bash
set -e

# --- Normalization ---
# CLIPIT_RAW=1 skips normalization, CLIPIT_NORMALIZE=1 forces it,
# otherwise respects ~/.claude/clipit/no-normalize config file.
should_normalize=true
if [[ -f ~/.claude/clipit/no-normalize ]]; then
    should_normalize=false
fi
if [[ "$CLIPIT_RAW" == "1" ]]; then
    should_normalize=false
elif [[ "$CLIPIT_NORMALIZE" == "1" ]]; then
    should_normalize=true
fi

if [[ "$should_normalize" == "true" ]]; then
    normalize() {
        sed -e 's/—/-/g' -e 's/–/-/g' -e 's/→/->/g' -e 's/←/<-/g'
    }
else
    normalize() { cat; }
fi

# --- Markdown stripping ---
# CLIPIT_MD=1 keeps markdown, CLIPIT_PLAIN=1 forces stripping,
# otherwise respects ~/.claude/clipit/keep-markdown config file.
should_strip=true
if [[ -f ~/.claude/clipit/keep-markdown ]]; then
    should_strip=false
fi
if [[ "$CLIPIT_MD" == "1" ]]; then
    should_strip=false
elif [[ "$CLIPIT_PLAIN" == "1" ]]; then
    should_strip=true
fi

if [[ "$should_strip" == "true" ]]; then
    strip_md() {
        sed \
            -e 's/^######[ \t]*//' \
            -e 's/^#####[ \t]*//' \
            -e 's/^####[ \t]*//' \
            -e 's/^###[ \t]*//' \
            -e 's/^##[ \t]*//' \
            -e 's/^#[ \t]*//' \
            -e 's/\*\*\([^*]*\)\*\*/\1/g' \
            -e 's/\*\([^*]*\)\*/\1/g' \
            -e 's/`\([^`]*\)`/\1/g' \
            -e 's/^[[:space:]]*[-*+] /  - /g' \
            -e 's/^---*$//' \
            -e '/^```/d'
    }
else
    strip_md() { cat; }
fi

# --- Clipboard ---
copy_cmd=""
if command -v pbcopy &> /dev/null; then
    copy_cmd="pbcopy"
elif command -v wl-copy &> /dev/null; then
    copy_cmd="wl-copy"
elif command -v xclip &> /dev/null; then
    copy_cmd="xclip -selection clipboard"
elif command -v xsel &> /dev/null; then
    copy_cmd="xsel --clipboard --input"
elif command -v clip.exe &> /dev/null; then
    copy_cmd="clip.exe"
else
    echo "Error: no supported clipboard command found." >&2
    echo "Install one of: pbcopy (macOS), xclip, xsel, wl-copy (Linux), or clip.exe (WSL)." >&2
    exit 1
fi

normalize | strip_md | $copy_cmd
