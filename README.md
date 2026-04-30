# Minecraft Server

Containerized Minecraft Java Edition server with Fabric mod support, persistent
server data, and environment-based runtime configuration.

## Table of Contents

- [Overview](#overview)
- [Quickstart](#quickstart)
- [Usage](#usage)
- [Configuration](#configuration)
- [Security Notes](#security-notes)
- [Validation](#validation)

## Overview

This repository contains the Docker setup for running a Minecraft Java Edition
server as a containerized service.

The server uses Fabric as modloader and ships with a small baseline set of
server-side mods:

- Fabric API
- Lithium
- ServerCore

The main project files are:

| File | Purpose |
| --- | --- |
| `Dockerfile` | Builds the Java runtime image and copies the Minecraft server artifacts. |
| `compose.yml` | Defines the `mc-server` service, port mapping, environment file, restart policy, and persistent bind mount. |
| `entrypoint.sh` | Validates runtime settings, accepts the EULA only when configured, applies the world name, syncs bundled mods, and starts Fabric. |
| `.env.example` | Documents the required runtime configuration values. |
| `.dockerignore` | Keeps local runtime data and secrets out of the Docker build context while allowing required server artifacts. |
| `.gitignore` | Keeps local environment files, server data, logs, and unrelated JAR artifacts out of Git. |

Generated runtime data is stored in `data/` on the host and mounted into the
container as `/data`. This keeps the world, server configuration, logs, and
mods available after a container restart or recreation.

## Quickstart

Create the local environment file.

```bash
cp .env.example .env
```

Set `EULA=true` in `.env` after reading and accepting the Minecraft EULA.

The repository includes the required server artifact directory.

```text
minecraft-java-image/
  server.jar
  fabric-server-launcher.jar
  mods/
    fabric-api-*.jar
    lithium-*.jar
    servercore-*.jar
```

Build and start the server.

```bash
docker compose up --build -d
```

Check the logs.

```bash
docker compose logs --tail 100 mc-server
```

The server is ready when the logs contain:

```text
Done (...s)! For help, type "help"
```

## Usage

The container is started through Docker Compose.

```bash
docker compose up -d
```

Stop and remove the container while keeping persistent data.

```bash
docker compose down
```

View recent logs.

```bash
docker compose logs --tail 100 mc-server
```

The server listens on the internal Minecraft port `25565`. By default, Compose
publishes it on host port `8888`, so the server can be reached through:

```text
<host-address>:8888
```

### Mods

The image includes a baseline Fabric mod set in `/app/mods`. During startup,
the entrypoint creates `/data/mods` and copies missing bundled mods into that
persistent directory.

Additional server-side Fabric mods can be installed by placing compatible
`.jar` files into:

```text
data/mods/
```

Then restart the container.

```bash
docker compose restart mc-server
```

Only use mods that match the Minecraft server version, the Fabric loader, and
the Java Edition server environment. Incompatible mods can prevent the server
from starting.

## Configuration

Runtime configuration is provided through `.env`. The real `.env` file must not
be committed.

| Variable | Purpose | Default Value |
| --- | --- | --- |
| `APP_NAME` | Container and image name prefix. | `mc-server` |
| `APP_VERSION` | Image tag used by Docker Compose. | `latest` |
| `HOST_PORT` | Published host port. | `8888` |
| `CONTAINER_PORT` | Internal Minecraft server port. | `25565` |
| `DATA_DIR` | Persistent runtime data directory inside the container. | `/data` |
| `EULA` | Must be set to `true` in `.env` to accept the Minecraft EULA before startup. | `false` |
| `JAVA_MEMORY` | Java heap memory for the Minecraft server. The official Minecraft example uses `4G`; lower this value for local testing if needed. | `4G` |
| `LEVEL_NAME` | Minecraft world folder/name written to `server.properties`. | `your-world-name` |

Changing `LEVEL_NAME` can create or load a different world directory. Existing
worlds should not be renamed casually.

## Security Notes

- Do not commit real `.env` files.
- Do not store SSH keys, passwords, tokens, usernames, server IP addresses, or other sensitive values in the repository.
- Keep runtime data, logs, and generated files out of version control.
- Run the container as the dedicated non-root `app` user.
- Only commit the required Minecraft, Fabric, and baseline mod artifacts from `minecraft-java-image/`.
- Use only trusted mod sources and verify that mod versions match the server version.

## Validation

Build and start the container.

```bash
docker compose up --build -d
```

Confirm that the container is running.

```bash
docker compose ps
```

Confirm that Minecraft started successfully.

```bash
docker compose logs --tail 150 mc-server
```

Confirm that the host port is reachable.

```powershell
Test-NetConnection 127.0.0.1 -Port 8888
```

Confirm that the configured world name was written.

```powershell
Select-String .\data\server.properties -Pattern "level-name"
```

Confirm that bundled mods were installed into the persistent data directory.

```powershell
Get-ChildItem .\data\mods
```

Confirm persistence after container recreation.

```bash
docker compose down
docker compose up -d
```

The `data/` directory should still contain files such as `server.properties`,
`mods/`, `logs/`, and the configured world directory.
