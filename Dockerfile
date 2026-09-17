FROM gradle:8.10.2-jdk17 AS build

WORKDIR /workspace

COPY . .

RUN set -eux; \
    ZIP_FILE="$(find /workspace -type f -iname '*Stage9*zip' | head -n 1)"
    test -n "$ZIP_FILE"; \
    mkdir -p /workspace/unpacked; \
    cd /workspace/unpacked; \
    jar xf "$ZIP_FILE"; \
    BACKEND_DIR="$(find /workspace/unpacked -type d -name backend | head -n 1)"; \
    test -n "$BACKEND_DIR"; \
    mkdir -p /home/gradle/project; \
    cp -a "$BACKEND_DIR/." /home/gradle/project/

WORKDIR /home/gradle/project

RUN gradle installDist --no-daemon

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /home/gradle/project/build/install/ ./

CMD ["sh", "-c", "find . -name '*.sh' -exec sh {} \\;"]
