#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Dictate & Type
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎙️
# @raycast.packageName Dictation

# Documentation:
# @raycast.description Voice → Whisper → Type directly into active field
# @raycast.author Rune

MODEL="$HOME/.local/share/whisper-models/ggml-base.en.bin"
TEMP_AUDIO=$(mktemp).wav

# Record until 2s silence (max 30s)
/opt/homebrew/bin/rec -q -r 16000 -c 1 "$TEMP_AUDIO" \
    silence 1 0.1 0.5% 1 2.0 0.5% \
    trim 0 30 2>/dev/null

if [ ! -s "$TEMP_AUDIO" ]; then
    osascript -e 'display notification "No audio captured" with title "❌ Dictation"'
    rm -f "$TEMP_AUDIO"
    exit 1
fi

# Transcribe
TEXT=$(/opt/homebrew/bin/whisper-cli -m "$MODEL" -nt -np "$TEMP_AUDIO" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
rm -f "$TEMP_AUDIO"

if [ -z "$TEXT" ]; then
    osascript -e 'display notification "Could not transcribe" with title "❌ Dictation"'
    exit 1
fi

# Type directly into active field
osascript -e "tell application \"System Events\" to keystroke \"$TEXT\""
