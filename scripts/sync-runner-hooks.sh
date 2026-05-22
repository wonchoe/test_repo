#!/usr/bin/env bash
set -euo pipefail

REMOTE="ubuntu@10.0.0.140"
RUNNER_DIR="/home/ubuntu/test-actions-runner"
HOOKS_DIR="$RUNNER_DIR/hooks"
REMOTE_HOOK="$HOOKS_DIR/job-started.sh"

scp ops/runner-hooks/job-started.sh "$REMOTE:$REMOTE_HOOK"
ssh "$REMOTE" "chmod +x $REMOTE_HOOK"
ssh "$REMOTE" "grep -q '^ACTIONS_RUNNER_HOOK_JOB_STARTED=' $RUNNER_DIR/.env && sed -i 's|^ACTIONS_RUNNER_HOOK_JOB_STARTED=.*|ACTIONS_RUNNER_HOOK_JOB_STARTED=$REMOTE_HOOK|' $RUNNER_DIR/.env || echo 'ACTIONS_RUNNER_HOOK_JOB_STARTED=$REMOTE_HOOK' >> $RUNNER_DIR/.env"
ssh "$REMOTE" "sudo systemctl restart actions.runner.wonchoe-test_repo.my-test-runner.service"
ssh "$REMOTE" "sudo systemctl --no-pager --full status actions.runner.wonchoe-test_repo.my-test-runner.service | sed -n '1,40p'"
