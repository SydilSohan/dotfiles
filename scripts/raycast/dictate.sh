#!/bin/bash
# Voice dictation using local Whisper
# Records until 2 seconds of silence, transcribes, copies to clipboard

WHISPER_MODEL="$HOME/.local/share/whisper-models/ggml-large-v3-turbo.bin"
TMPFILE="/tmp/dictation_$$.wav"

# Show notification that we're recording
osascript -e 'display notification "Recording... (speak now)" with title "🎤 Dictation"'

# Record until 2 seconds of silence
# -d coreaudio uses macOS audio
# silence 1 0.1 1% = start recording after sound
# 1 2.0 1% = stop after 2 seconds of silence
rec -q -r 16000 -c 1 "$TMPFILE" silence 1 0.1 1% 1 2.0 1% 2>/dev/null

# Notify transcribing
osascript -e 'display notification "Transcribing..." with title "⏳ Dictation"'

# Transcribe
TRANSCRIPT=$(/opt/homebrew/bin/whisper-cli \
    -m "$WHISPER_MODEL" \
    -f "$TMPFILE" \
    --no-timestamps \
    2>/dev/null | grep -v "^\[" | sed '/^$/d' | tr -d '\n')

# Copy to clipboard
echo -n "$TRANSCRIPT" | pbcopy

# Notify done and show text
osascript -e "display notification \"$TRANSCRIPT\" with title \"✅ Copied to clipboard\""

# Cleanup
rm -f "$TMPFILE"

# Optional: paste immediately (uncomment if you want auto-paste)
# osascript -e 'tell application "System Events" to keystroke "v" using command down'

echo "$TRANSCRIPT"
