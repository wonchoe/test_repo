#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Runner System Hook - Job Started
# =============================================================================
# This hook runs automatically as "Set up runner" step for every job on this
# self-hosted runner. It uses GITHUB_ENV to inject variables into ALL subsequent
# user steps. Users cannot modify or skip this hook.
#
# From runner source (JobHookProvider.cs), file commands are processed:
#   - GITHUB_OUTPUT  (outputs scoped to this hook step)
#   - GITHUB_ENV     (env vars for ALL subsequent steps)
#   - GITHUB_PATH    (PATH additions for ALL subsequent steps)
# =============================================================================

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOOK_DIR}/job-started.log"

UTC_NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EPOCH_NOW="$(date +%s)"
RUNNER_NAME_VALUE="${RUNNER_NAME:-unknown}"
HOST_VALUE="$(hostname)"

# --- Log execution ---
echo "[$UTC_NOW] HOOK_START runner=$RUNNER_NAME_VALUE host=$HOST_VALUE" >> "$LOG_FILE"

# =============================================================================
# SYSTEM WORKFLOW LOGIC (runs here, invisible to user YAML)
# Add custom checks, validations, or any logic you need.
# =============================================================================

SYSTEM_CHECK_RESULT="passed"
SYSTEM_CHECK_DETAILS="All pre-flight checks OK"

# Check disk space
DISK_FREE_MB=$(df -m /home | awk 'NR==2{print $4}')
if (( DISK_FREE_MB < 1024 )); then
  SYSTEM_CHECK_RESULT="warning"
  SYSTEM_CHECK_DETAILS="Low disk space: ${DISK_FREE_MB}MB free"
fi

# Check Docker availability
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  DOCKER_STATUS="available"
else
  DOCKER_STATUS="unavailable"
fi

# =============================================================================
# WRITE TO GITHUB_ENV → available in ALL user steps automatically
# =============================================================================
{
  echo "RUNNER_HOOK_EXECUTED=true"
  echo "RUNNER_HOOK_TIME_UTC=$UTC_NOW"
  echo "RUNNER_HOOK_TIME_EPOCH=$EPOCH_NOW"
  echo "RUNNER_HOOK_NAME=$RUNNER_NAME_VALUE"
  echo "RUNNER_HOOK_HOST=$HOST_VALUE"
  echo "RUNNER_HOOK_SYSTEM_CHECK=$SYSTEM_CHECK_RESULT"
  echo "RUNNER_HOOK_SYSTEM_DETAILS=$SYSTEM_CHECK_DETAILS"
  echo "RUNNER_HOOK_DISK_FREE_MB=$DISK_FREE_MB"
  echo "RUNNER_HOOK_DOCKER=$DOCKER_STATUS"
} >> "$GITHUB_ENV"

# =============================================================================
# PRINT SUMMARY (visible in "Set up runner" step in GitHub UI)
# =============================================================================
echo "============================================================"
echo "  Runner System Hook - Pre-flight Report"
echo "============================================================"
echo "  Runner:       $RUNNER_NAME_VALUE"
echo "  Host:         $HOST_VALUE"
echo "  Time:         $UTC_NOW"
echo "  Disk Free:    ${DISK_FREE_MB}MB"
echo "  Docker:       $DOCKER_STATUS"
echo "  System Check: $SYSTEM_CHECK_RESULT"
echo "  Details:      $SYSTEM_CHECK_DETAILS"
echo "============================================================"

# --- Log completion ---
echo "[$UTC_NOW] HOOK_END result=$SYSTEM_CHECK_RESULT" >> "$LOG_FILE"
