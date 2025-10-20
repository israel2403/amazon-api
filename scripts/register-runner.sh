#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   export GH_REPO_URL="https://github.com/<owner>/<repo>"
#   export RUNNER_LABELS="self-hosted,linux,wsl"
#   export RUNNER_NAME="$(hostname)-wsl"
#   # Option A: Acquire the registration token via API (needs GH_PAT), or
#   # Option B: Use the GitHub UI to get a token and set RUNNER_TOKEN directly.
#
# Option A (API): export GH_PAT="<a GitHub PAT with repo admin or actions:write permissions>"
# Option B (UI): export RUNNER_TOKEN="<registration token from GitHub UI>"

WORKDIR="${HOME}/actions-runner"
RUNNER_VERSION="2.320.0"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

if [ ! -f "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" ]; then
  curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
  tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
fi

if [ -z "${GH_REPO_URL:-}" ]; then
  echo "Please export GH_REPO_URL (e.g., https://github.com/owner/repo)"
  exit 1
fi

if [ -z "${RUNNER_TOKEN:-}" ]; then
  if [ -z "${GH_PAT:-}" ]; then
    echo "Set RUNNER_TOKEN from the GitHub UI, or set GH_PAT to fetch a token via API."
    exit 1
  fi
  TOKEN_JSON=$(curl -sX POST -H "Accept: application/vnd.github+json"     -H "Authorization: Bearer ${GH_PAT}"     "${GH_REPO_URL}/actions/runners/registration-token")
  RUNNER_TOKEN=$(echo "$TOKEN_JSON" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
fi

./config.sh --url "${GH_REPO_URL}" --token "${RUNNER_TOKEN}" --name "${RUNNER_NAME:-wsl-runner}" --labels "${RUNNER_LABELS:-self-hosted,linux,wsl}" --unattended

sudo ./svc.sh install
sudo ./svc.sh start

echo "Runner registered and started with labels: ${RUNNER_LABELS:-self-hosted,linux,wsl}"
