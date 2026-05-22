#!/usr/bin/env bash
set -euo pipefail

REMOTE="ubuntu@10.0.0.140"
RUNNER_DIR="/home/ubuntu/test-actions-runner"
HOOKS_DIR="$RUNNER_DIR/hooks"
REMOTE_HOOK="$HOOKS_DIR/job-started.sh"
SERVICE_NAME="actions.runner.wonchoe-test_repo.my-test-runner.service"
RUNTIME_ENV_FILE="$HOOKS_DIR/prehook-runtime.env"

scp ops/runner-hooks/job-started.sh "$REMOTE:$REMOTE_HOOK"
ssh "$REMOTE" "mkdir -p $HOOKS_DIR && chmod +x $REMOTE_HOOK"
ssh "$REMOTE" "[[ -f $RUNTIME_ENV_FILE ]] || touch $RUNTIME_ENV_FILE"
ssh "$REMOTE" "grep -q '^ACTIONS_RUNNER_HOOK_JOB_STARTED=' $RUNNER_DIR/.env && sed -i 's|^ACTIONS_RUNNER_HOOK_JOB_STARTED=.*|ACTIONS_RUNNER_HOOK_JOB_STARTED=$REMOTE_HOOK|' $RUNNER_DIR/.env || echo 'ACTIONS_RUNNER_HOOK_JOB_STARTED=$REMOTE_HOOK' >> $RUNNER_DIR/.env"
ssh "$REMOTE" "sudo mkdir -p /etc/systemd/system/$SERVICE_NAME.d"
ssh "$REMOTE" "cat > /tmp/prehook-runner-override.conf <<'EOF'
[Service]
Environment=BASH_ENV=$RUNTIME_ENV_FILE
EOF"
ssh "$REMOTE" "sudo mv /tmp/prehook-runner-override.conf /etc/systemd/system/$SERVICE_NAME.d/override.conf"
ssh "$REMOTE" "sudo systemctl daemon-reload"
ssh "$REMOTE" "sudo systemctl restart $SERVICE_NAME"
ssh "$REMOTE" "sudo systemctl --no-pager --full status $SERVICE_NAME | sed -n '1,40p'"
