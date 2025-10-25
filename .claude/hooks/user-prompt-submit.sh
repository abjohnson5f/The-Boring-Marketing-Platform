#!/usr/bin/env bash
# Claude Code Hook: Before Command Execution (user-prompt-submit)
# Equivalent to Cursor's beforeCommand hook
# Blocks dangerous commands that could harm the repository

PROMPT="$1"

# Define forbidden patterns (read-only checks)
FORBIDDEN_PHRASES=(
  "rm -rf"
  "cat .env"
)

RISKY_PATTERNS=(
  'rm\s+-rf\s+(\.\.|\.)'
  'cat\s+.*\.env'
  'grep.*\.env'
  'sed.*\.env'
  'awk.*\.env'
)

# Check for forbidden phrases
for phrase in "${FORBIDDEN_PHRASES[@]}"; do
  if echo "$PROMPT" | grep -qF "$phrase"; then
    echo "❌ Blocked command containing: $phrase" >&2
    echo "This appears to be a dangerous operation that could harm the repository." >&2
    exit 1
  fi
done

# Check for risky regex patterns
for pattern in "${RISKY_PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qE "$pattern"; then
    echo "❌ Blocked command matching dangerous pattern: $pattern" >&2
    echo "This operation could expose secrets or delete critical files." >&2
    exit 1
  fi
done

# All checks passed
exit 0
