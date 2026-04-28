#!/bin/sh
set -eu

APP_NAME="${APP_NAME:-container-app}"
DATA_DIR="${DATA_DIR:-/data}"

echo "Starting ${APP_NAME} container..."
echo "Checking data directory: ${DATA_DIR}"

mkdir -p "${DATA_DIR}"

if [ ! -w "${DATA_DIR}" ]; then
  echo "Data directory is not writable: ${DATA_DIR}" >&2
  exit 1
fi

echo "Starting application process..."
exec "$@"
