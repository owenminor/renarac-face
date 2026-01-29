#!/bin/bash
# Sync activities from memory files to Renarac's face
# Run this periodically to keep my face updated

MEMORY_DIR="/home/owenm/clawd/memory"
API_URL="http://localhost:3000/api"
STATE_FILE="/home/owenm/clawd/renarac-face/state.json"

# Get today's memory file
TODAY=$(date +%Y-%m-%d)
MEMORY_FILE="$MEMORY_DIR/$TODAY.md"

if [ ! -f "$MEMORY_FILE" ]; then
    echo "No memory file for today"
    exit 0
fi

# Extract activity-like lines from memory
# Looking for lines with actions/verbs at the start
ACTIVITIES=$(grep -E "^- \[" "$MEMORY_FILE" | head -5 | while read line; do
    # Extract text between [ ]
    TEXT=$(echo "$line" | sed 's/.*\[\([^]]*)\].*/\1/')
    # Determine icon based on content
    case "$TEXT" in
        *email*|*gmail*) ICON="📧" ;;
        *search*|*web*) ICON="🔍" ;;
        *browser*) ICON="🌐" ;;
        *telegram*|*signal*) ICON="💬" ;;
        *calendar*) ICON="📅" ;;
        *phone*) ICON="📱" ;;
        *build*|*create*) ICON="🔧" ;;
        *github*) ICON="💻" ;;
        *send*|*message*) ICON="✉️" ;;
        *) ICON="📌" ;;
    esac
    echo "$TEXT:$ICON"
done)

# Update state with new activity count
IDEAS_COUNT=$(grep -c "^- " "$MEMORY_FILE" 2>/dev/null || echo 0)

# Read current state
if [ -f "$STATE_FILE" ]; then
    CURRENT_IDEAS=$(grep -o '"ideas": [0-9]*' "$STATE_FILE" | grep -o '[0-9]*' || echo 0)
    NEW_IDEAS=$((CURRENT_IDEAS + IDEAS_COUNT))

    # Update state file
    sed -i "s/\"ideas\": $CURRENT_IDEAS/\"ideas\": $NEW_IDEAS/" "$STATE_FILE"
    echo "Updated ideas count: $NEW_IDEAS"
else
    echo "State file not found"
fi

echo "Synced from memory: $MEMORY_FILE"
