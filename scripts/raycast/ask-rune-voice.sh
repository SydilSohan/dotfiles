#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ask Rune (Voice)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪨
# @raycast.packageName Rune

# Documentation:
# @raycast.description Voice → Whisper → Rune → Speak response
# @raycast.author Rune

MODEL="$HOME/.local/share/whisper-models/ggml-base.en.bin"
TEMP_AUDIO=$(mktemp).wav

echo "🎤 Listening..."

# Record until 2s silence (max 20s)
/opt/homebrew/bin/rec -q -r 16000 -c 1 "$TEMP_AUDIO" \
    silence 1 0.1 0.5% 1 2.0 0.5% \
    trim 0 20 2>/dev/null

if [ ! -s "$TEMP_AUDIO" ]; then
    echo "❌ No audio captured"
    rm -f "$TEMP_AUDIO"
    exit 1
fi

echo "⏳ Transcribing..."

# Transcribe
MESSAGE=$(/opt/homebrew/bin/whisper-cli -m "$MODEL" -nt -np "$TEMP_AUDIO" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
rm -f "$TEMP_AUDIO"

if [ -z "$MESSAGE" ]; then
    echo "❌ Couldn't transcribe"
    exit 1
fi

# Show sent immediately
echo "✅ Sent: $MESSAGE"

# Send to main session (same thread as webchat/whatsapp) and get response
RESPONSE=$(/Users/mdsydilragib/.npm-global/bin/clawdbot agent \
    --to "+8801783564601" \
    --message "[voice] $MESSAGE" \
    --json \
    --timeout 60 2>/dev/null | jq -r '.result.payloads[0].text // empty' 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    say "Sorry, I couldn't get a response."
    exit 1
fi

# Speak the response
say "$RESPONSE"
