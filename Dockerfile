FROM eclipse-temurin:25-jre

WORKDIR /data

ARG CONTAINER_PORT=25565

# Run the application as a dedicated non-root user.
RUN groupadd --system app && useradd --system --gid app --home-dir /app app && mkdir -p /app /data

COPY minecraft-java-image/ /app/
COPY entrypoint.sh /entrypoint.sh

#ARG SERVER_JAR_URL=...
#ARG SERVER_JAR_SHA256=...
#RUN curl -fsSL "${SERVER_JAR_URL}" -o /app/server.jar && echo "${SERVER_JAR_SHA256}  /app/server.jar" | sha256sum -c -

RUN chown -R app:app /app /data /entrypoint.sh && chmod +x /entrypoint.sh

USER app

EXPOSE ${CONTAINER_PORT}

ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["sh", "-c", "echo 'Replace this command with the project start command.' && sleep infinity"]
