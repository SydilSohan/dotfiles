#!/bin/bash
# Ask Rune via voice - used by Siri Shortcuts
# Usage: ask-rune.sh "your question here"

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
    echo "No message provided"
    exit 1
fi

# Send to Clawdbot agent and get response
RESPONSE=$(npx clawdbot agent --session-id "voice" --agent voice --message "$MESSAGE" --json 2>/dev/null | /opt/homebrew/bin/jq -r '.result.payloads[0].text // "Sorry, I couldn'\''t process that."' 2>/dev/null)

# Fallback if jq fails
if [ -z "$RESPONSE" ] || [ "$RESPONSE" = "null" ]; then
    RESPONSE="Sorry, I couldn't get a response right now."
fi

echo "$RESPONSE"
