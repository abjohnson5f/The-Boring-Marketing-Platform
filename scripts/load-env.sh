#!/usr/bin/env bash
# Usage: source scripts/load-env.sh [path-to-env]
ENV_FILE="${1:-.env}"
if [ ! -f "$ENV_FILE" ]; then
  echo "Env file '$ENV_FILE' not found." >&2
  return 1 2>/dev/null || exit 1
fi
set -a
source "$ENV_FILE"
set +a
echo "Loaded environment variables from $ENV_FILE"
