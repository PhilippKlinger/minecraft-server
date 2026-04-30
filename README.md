# Minecraft Server

This repository contains a Dockerized Minecraft Java Edition server with Fabric
mod support for local testing and VPS deployment.

The server is designed to run as the `mc-server` service, persist game data
under `data/`, and be reachable on host port `8888` by default.

The setup includes:

- `Dockerfile` for the Java runtime image
- `compose.yml` for service, port, restart, and bind mount configuration
- `entrypoint.sh` for EULA handling, world name configuration, mod syncing, and startup
- `minecraft-java-image/` with the required Minecraft, Fabric, and baseline mod JARs
- `.env.example` for runtime configuration

## Table of Contents

- [Quickstart](#quickstart)
- [Usage](#usage)
- [Configuration](#configuration)
- [Security Notes](#security-notes)
- [Validation](#validation)

---

## Quickstart

Prerequisites:

- Docker Engine or Docker Desktop with Docker Compose
- Git
- Python is optional and only needed for the `mcstatus` validation command

Clone the repository and enter the project folder.

```bash
git clone <repository-url>
cd minecraft-server
```

Create a local environment file.

```bash
cp .env.example .env
```

Open `.env`, set `EULA=true`, and review the values listed in the
[Configuration](#configuration) section.

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

The server is available at:

```text
<host-address>:${HOST_PORT}
```

---

## Usage

### Local Docker Usage

Start the server:

```bash
docker compose up --build -d
```

Stop the server without deleting persistent data:

```bash
docker compose down
```

Do not remove the `data/` directory if you want to keep the world, server
configuration, logs, and installed mods.

### VPS Deployment

Clone the repository on the VPS and enter the project folder.

```bash
git clone <repository-url>
cd minecraft-server
```

Create `.env` from the template and adjust deployment-specific values.

```bash
cp .env.example .env
```

Prepare the bind mount directory for the non-root container user.

```bash
mkdir -p data
sudo chown -R 999:999 data
```

Start the server.

```bash
docker compose up --build -d
```

Open the server with a Minecraft Java Edition client or a status tool:

```text
<server-ip>:8888
```

### Mods

The image includes these baseline Fabric server mods:

- Fabric API
- Lithium
- ServerCore

During startup, missing bundled mods are copied into the persistent `data/mods/`
directory. Additional compatible Fabric server mods can be installed by placing
their `.jar` files into `data/mods/` and restarting the service.

```bash
docker compose restart mc-server
```

Only use mods that match the Minecraft server version, Fabric loader, and Java
Edition server environment.

---

## Configuration

Copy `.env.example` to `.env` and adjust the values below for your target
environment.

| Variable | Purpose | Default Value |
| --- | --- | --- |
| `APP_NAME` | Container and image name prefix. | `mc-server` |
| `APP_VERSION` | Image tag used by Docker Compose. | `latest` |
| `HOST_PORT` | Published host port for Docker Compose. | `8888` |
| `CONTAINER_PORT` | Internal Minecraft server port. | `25565` |
| `DATA_DIR` | Persistent runtime data directory inside the container. | `/data` |
| `EULA` | Must be set to `true` after accepting the Minecraft EULA. | `false` |
| `JAVA_MEMORY` | Java heap memory. The official Minecraft example uses `4G`; lower it for local testing if needed. | `4G` |
| `LEVEL_NAME` | Minecraft world folder/name written to `server.properties`. | `your-world-name` |

The container runtime stores persistent data under:

```text
/data
```

This path is mounted from the local `data/` directory and remains available
after a normal restart. Changing `LEVEL_NAME` can create or load a different
world directory.

---

## Security Notes

- Do not commit real `.env` files.
- Do not store SSH keys, passwords, tokens, usernames, server IP addresses, or other sensitive values in the repository.
- Keep runtime data, logs, and generated files out of version control.
- The container runs as a dedicated non-root `app` user.
- Only commit the required Minecraft, Fabric, and baseline mod artifacts from `minecraft-java-image/`.
- Use trusted mod sources and verify that mod versions match the server version.

---

## Validation

The server can be tested with a Minecraft Java Edition client or with a status
check tool such as `mcstatus`.

```bash
python -m pip install mcstatus
python -m mcstatus <server-ip>:8888 status
```

To check persistence, restart the container and confirm that the configured
world data remains available under `data/`.

```bash
docker compose down
docker compose up -d
```
