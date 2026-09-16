#!/usr/bin/env bash
# Verification for infra (Docker Compose).
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "MISS docker not found on PATH (need Docker 24.x+)"
  exit 1
fi
echo "OK   $(docker --version)"

if [ -f "docker-compose.yml" ]; then
  echo "OK   docker-compose.yml detected"
  if ! docker compose config >/dev/null 2>&1; then
    echo "FAIL docker-compose.yml exists but is not valid (docker compose config)"
    docker compose config
    exit 1
  fi
  echo "OK   docker-compose.yml is valid (docker compose config)"
else
  echo "----  No docker-compose.yml yet — feat-001 not started."
  echo "     See feature_list.json for the next step."
  exit 1
fi

echo "infra verification passed."
