# Minecraft Server

This repository provides a Dockerized Minecraft Java Edition server with Fabric
mod support. It builds a dedicated server image and runs it as the `mc-server`
Docker Compose service.

The server publishes port `8888` by default and stores its runtime state in a
Docker named volume. The same Compose workflow applies on a local machine and
on a VPS; each Docker host maintains its own volume data.

## Contents

- [Components](#components)
- [Quickstart](#quickstart)
- [Operations and persistence](#operations-and-persistence)
- [Configuration](#configuration)
- [Mods](#mods)
- [Security notes](#security-notes)
- [Validation](#validation)

## Components

- `Dockerfile` builds the Java runtime image without using a prebuilt Minecraft
  server image.
- `compose.yml` defines the `mc-server` service, networking, port publishing,
  restart policy, and the `minecraft_data` named volume.
- `entrypoint.sh` checks runtime prerequisites and the EULA, applies selected
  server configuration, synchronizes bundled baseline mods, and starts the
  server.
- `minecraft-java-image/` contains the required Minecraft, Fabric, and
  baseline-mod artifacts.
- `.env.example` documents the non-sensitive runtime configuration contract.

## Quickstart

Prerequisites:

- Docker Engine or Docker Desktop with Docker Compose
- Git
- Python is optional and only needed for the `mcstatus` validation command

Clone the repository and create the local environment file:

```bash
git clone <repository-url>
cd minecraft-server
cp .env.example .env
```

Open `.env`, set `EULA=true` after accepting the Minecraft EULA, and review the
values in [Configuration](#configuration).

Build and start the service:

```bash
docker compose up --build -d
docker compose logs --tail 100 mc-server
```

The server is ready when the logs contain `Done (...s)! For help, type "help"`.
Connect with a compatible Minecraft Java Edition client or a status tool at
`<host-address>:<HOST_PORT>`; the default host port is `8888`.

## Operations and persistence

Use the same commands for routine operation on every Docker host:

```bash
docker compose up -d
docker compose restart mc-server
docker compose down
```

The `minecraft_data` Docker named volume is mounted at `/data` in the
container. It holds world data, `server.properties`, logs, EULA state, and
installed mods. Docker creates the volume on first use and retains it after a
normal `docker compose down` or container recreate.

> [!WARNING]
> Do not use `docker compose down -v` or remove the `minecraft_data` named
> volume unless the server data has been intentionally backed up and may be
> discarded.

Named volumes are local to one Docker host; moving a world between hosts
requires a separate backup and restore process.

No host `data/` directory or manual `chown` step is required. The container
runs as the dedicated non-root `app` user and checks that `/data` is writable
before starting the server.

## Configuration

Copy `.env.example` to `.env` and adjust only non-sensitive values. Do not
commit `.env`.

| Variable | Purpose | Default value |
| --- | --- | --- |
| `APP_NAME` | Container and image name prefix. | `mc-server` |
| `APP_VERSION` | Image tag used by Docker Compose. | `latest` |
| `HOST_PORT` | Published host port. | `8888` |
| `CONTAINER_PORT` | Internal Minecraft server port. | `25565` |
| `DATA_DIR` | Runtime data path in the container. Keep this as `/data`, the named-volume mount target. | `/data` |
| `EULA` | Must be set to `true` after accepting the Minecraft EULA. | `false` |
| `JAVA_MEMORY` | Java heap-memory setting. | `4G` |
| `LEVEL_NAME` | World folder/name written to `server.properties`. | `your-world-name` |
| `MAX_PLAYERS` | Maximum concurrent players written to `server.properties`; only integer values from `1` to `20` are accepted. | `20` |

The variables above are part of the supported configuration contract. Other
Minecraft server properties remain under Minecraft's normal file-based
configuration and are not silently managed by the entrypoint. On every start,
the entrypoint updates `level-name` and `max-players` from `LEVEL_NAME` and
`MAX_PLAYERS`, so the effective values remain reproducible across restarts.

## Mods

The image includes these baseline Fabric server mods:

- **Fabric API** provides the shared API required by many Fabric mods.
- **Lithium** improves server-side performance.
- **ServerCore** provides server-side management and performance features.

At startup, the entrypoint copies missing bundled mods into the persistent
`/data/mods/` directory. It does not overwrite an existing mod with the same
filename, so manually managed compatible mods remain intact. Additional mods
must match the Minecraft server version, Fabric loader, and Java Edition server
environment.

After adding or changing a compatible mod, restart the service:

```bash
docker compose restart mc-server
```

## Security notes

- Do not commit real `.env` files.
- Do not store SSH keys, passwords, tokens, usernames, server IP addresses, or
  other sensitive values in the repository.
- Keep generated runtime data and logs out of version control.
- The Minecraft process runs as the non-root `app` user.
- Only use trusted, version-compatible Minecraft, Fabric, and mod artifacts.

## Validation

Check the final service state with its logs and, when available, a Minecraft
Java Edition client. A status check can be performed with `mcstatus`:

```bash
python -m pip install mcstatus
python -m mcstatus <host-address>:8888 status
```

To verify persistence, record an observable server state, recreate the
container without deleting the volume, and verify that the state remains:

```bash
docker compose down
docker compose up -d
```

Also verify the configured restart policy with a controlled test before the
final submission.
