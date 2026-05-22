#!/usr/bin/env bash
set -euo pipefail

REMOTE="ubuntu@10.0.0.140"
RUNNER_DIR="/home/ubuntu/test-actions-runner"
HOOKS_DIR="$RUNNER_DIR/hooks"
REMOTE_HOOK="$HOOKS_DIR/job-started.sh"
SERVICE_NAME="actions.runner.wonchoe-test_repo.my-test-runner.service"

scp ops/runner-hooks/job-started.sh "$REMOTE:$REMOTE_HOOK"
ssh "$REMOTE" "mkdir -p $HOOKS_DIR && chmod +x $REMOTE_HOOK"
ssh "$REMOTE" "grep -q '^ACTIONS_RUNNER_HOOK_JOB_STARTED=' $RUNNER_DIR/.env && sed -i 's|^ACTIONS_RUNNER_HOOK_JOB_STARTED=.*|ACTIONS_RUNNER_HOOK_JOB_STARTED=$REMOTE_HOOK|' $RUNNER_DIR/.env || echo 'ACTIONS_RUNNER_HOOK_JOB_STARTED=$REMOTE_HOOK' >> $RUNNER_DIR/.env"
ssh "$REMOTE" "sudo systemctl restart $SERVICE_NAME"
ssh "$REMOTE" "sudo systemctl --no-pager --full status $SERVICE_NAME | sed -n '1,40p'"
