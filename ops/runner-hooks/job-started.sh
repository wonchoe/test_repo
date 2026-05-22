#!/usr/bin/env bash
set -euo pipefail

RUNNER_ROOT="${RUNNER_ROOT:-$HOME/test-actions-runner}"
CONTEXT_DIR="$RUNNER_ROOT/_work/_prehook_context"
CONTEXT_FILE="$CONTEXT_DIR/latest.env"
LOG_FILE="$RUNNER_ROOT/hooks/job-started.log"

mkdir -p "$CONTEXT_DIR"

UTC_NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EPOCH_NOW="$(date +%s)"
RUNNER_NAME_VALUE="${RUNNER_NAME:-unknown}"
HOST_VALUE="$(hostname)"

{
  echo "[$UTC_NOW] PREHOOK_START"
  echo "RUNNER_NAME=$RUNNER_NAME_VALUE"
  echo "HOST=$HOST_VALUE"
  echo "CONTEXT_FILE=$CONTEXT_FILE"
  echo "PREHOOK_END"
} >> "$LOG_FILE"

cat > "$CONTEXT_FILE" <<EOF
PREHOOK_EXECUTED=true
PREHOOK_TIME_UTC=$UTC_NOW
PREHOOK_TIME_EPOCH=$EPOCH_NOW
PREHOOK_RUNNER_NAME=$RUNNER_NAME_VALUE
PREHOOK_HOST=$HOST_VALUE
EOF
