#!/usr/bin/env bash
# Claude Code Hook: After File Edit (tool-use-complete)
# Equivalent to Cursor's afterFileEdit hook
# Validates JSON files in workflows/ directory and logs all file changes

TOOL_NAME="$1"
FILE_PATH="$2"

# Only process Edit/Write tool operations
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

TESTING_DIR="docs/testing"
LOG_FILE="$TESTING_DIR/hook-log.md"

# Ensure testing directory exists
mkdir -p "$TESTING_DIR"

# Logging function
log_entry() {
  local message="$1"
  echo "- $(date -u +%Y-%m-%dT%H:%M:%SZ) - $message" >> "$LOG_FILE"
}

# Get relative path for cleaner logs
RELATIVE_PATH="${FILE_PATH#$(pwd)/}"

# Special validation for workflow JSON files
if [[ "$FILE_PATH" == */workflows/* && "$FILE_PATH" == *.json ]]; then
  if [[ -f "$FILE_PATH" ]]; then
    if python3 -m json.tool "$FILE_PATH" > /dev/null 2>&1; then
      log_entry "✅ Validated JSON: $RELATIVE_PATH"
    else
      log_entry "❌ JSON validation failed for $RELATIVE_PATH"
      echo "❌ Invalid JSON in workflow file: $RELATIVE_PATH" >&2
      exit 1
    fi
  fi
else
  # Log other file edits
  log_entry "📝 Edited file: $RELATIVE_PATH"
fi

exit 0
