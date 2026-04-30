#!/bin/sh
set -eu

APP_NAME="${APP_NAME:-mc-server}"
DATA_DIR="${DATA_DIR:-/data}"
CONTAINER_PORT="${CONTAINER_PORT:-25565}"
JAVA_MEMORY="${JAVA_MEMORY:-1G}"
EULA="${EULA:-false}"
LEVEL_NAME="${LEVEL_NAME:-world}"

echo "Starting ${APP_NAME} container..."
echo "Checking data directory: ${DATA_DIR}"

mkdir -p "${DATA_DIR}"

if [ ! -w "${DATA_DIR}" ]; then
  echo "Data directory is not writable: ${DATA_DIR}" >&2
  exit 1
fi

if [ ! -f /app/server.jar ]; then
  echo "Missing /app/server.jar" >&2
  exit 1
fi

if [ ! -f /app/fabric-server-launcher.jar ]; then
  echo "Missing /app/fabric-server-launcher.jar" >&2
  exit 1
fi

if [ "${EULA}" != "true" ]; then
  echo "You must set EULA=true to accept the Minecraft EULA." >&2
  exit 1
fi

echo "eula=true" > "${DATA_DIR}/eula.txt"

cd "${DATA_DIR}"

touch server.properties

if grep -q "^level-name=" server.properties; then
  sed -i "s|^level-name=.*|level-name=${LEVEL_NAME}|" server.properties
else
  echo "level-name=${LEVEL_NAME}" >> server.properties
fi

mkdir -p mods

if [ -d /app/mods ]; then
  echo "Syncing bundled server mods..."
  for MOD_FILE in /app/mods/*.jar; do
    if [ ! -e "${MOD_FILE}" ]; then
      continue
    fi

    MOD_NAME="$(basename "${MOD_FILE}")"

    if [ ! -f "mods/${MOD_NAME}" ]; then
      cp "${MOD_FILE}" "mods/${MOD_NAME}"
    fi
  done
fi

echo "Starting Minecraft server on port ${CONTAINER_PORT}..."

exec java -Xms"${JAVA_MEMORY}" -Xmx"${JAVA_MEMORY}" -jar /app/fabric-server-launcher.jar nogui
