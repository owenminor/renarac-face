#!/bin/bash
# Notify Owen with voice when development is complete

TEXT="$1"

if [ -z "$TEXT" ]; then
    TEXT="Development complete. I'm finished working on my projects."
fi

# Generate TTS and play
clawdbot tts "$TEXT" 2>/dev/null || {
    # Fallback if clawdbot tts not available
    echo "$TEXT"
}

echo "Notification sent: $TEXT"
