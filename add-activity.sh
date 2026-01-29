#!/bin/bash
# Add an activity to Renarac's face
# Usage: ./add-activity.sh "Activity text" "📧"

API_URL="http://localhost:3000/api"

TEXT="$1"
ICON="${2:-📌}"

if [ -z "$TEXT" ]; then
    echo "Usage: ./add-activity.sh \"Activity text\" [icon]"
    echo "Example: ./add-activity.sh \"Sent email to Owen\" \"📧\""
    exit 1
fi

curl -X POST "$API_URL/activity" \
    -H "Content-Type: application/json" \
    -d "{\"text\":\"$TEXT\",\"icon\":\"$ICON\"}"

echo ""
