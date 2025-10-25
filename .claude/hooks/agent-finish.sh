#!/usr/bin/env bash
# Claude Code Hook: On Agent/Task Completion (agent-finish)
# Equivalent to Cursor's onAgentFinish hook
# Sends Slack notification when slash command agents complete

# This hook doesn't have direct access to modified files list like Cursor
# Instead, we'll check git status for recently modified files

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
  # Silently exit if no webhook configured
  exit 0
fi

# Get list of modified files from git
MODIFIED_FILES=$(git status --short 2>/dev/null | awk '{print "• " $2}' | head -20)

if [[ -z "$MODIFIED_FILES" ]]; then
  MODIFIED_FILES="• None"
fi

# Create JSON payload
PAYLOAD=$(cat <<EOF
{
  "text": "🤖 Claude Code agent run complete.\n\nModified files:\n${MODIFIED_FILES}"
}
EOF
)

# Send to Slack
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD" \
  --silent --show-error > /dev/null 2>&1

exit 0
