#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-production}"
APP_DIR="${APP_DIR:-/opt/devops-agent}"
COMPOSE_FILE="${COMPOSE_FILE:-docker/docker-compose.yml}"

echo "[deploy] Environment: $ENVIRONMENT"
echo "[deploy] App dir: $APP_DIR"

if [ ! -d "$APP_DIR" ]; then
  sudo mkdir -p "$APP_DIR"
  sudo chown "$USER":"$USER" "$APP_DIR"
fi

if [ ! -d "$APP_DIR/.git" ]; then
  git clone --depth 1 "${REPO_SSH_URL}" "$APP_DIR"
fi

cd "$APP_DIR"
git fetch --prune
git checkout "${REF:-main}"
git pull --ff-only

# Build & up (compose v2)
docker compose -f "$COMPOSE_FILE" build
docker compose -f "$COMPOSE_FILE" up -d

echo "[deploy] Done."
