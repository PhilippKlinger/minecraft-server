FROM debian:bookworm-slim

WORKDIR /app

ARG CONTAINER_PORT=TODO_CONTAINER_PORT

RUN groupadd --system app \
    && useradd --system --gid app --home-dir /app app \
    && mkdir -p /app /data

COPY entrypoint.sh /entrypoint.sh
COPY . /app

RUN chown -R app:app /app /data /entrypoint.sh \
    && chmod +x /entrypoint.sh

USER app

EXPOSE ${CONTAINER_PORT}

ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["sh", "-c", "echo 'Replace this command with the project start command.' && sleep infinity"]
