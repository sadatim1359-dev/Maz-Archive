
FROM gradle:8.10.2-jdk17 AS build

USER root
WORKDIR /workspace

COPY . /workspace/repo

RUN ZIP_FILE="$(find /workspace/repo -maxdepth 1 -type f -iname '*Stage5*zip' | head -n 1)" && \
    test -n "$ZIP_FILE" && \
    mkdir /workspace/unpacked && \
    cd /workspace/unpacked && \
    jar xf "$ZIP_FILE" && \
    mkdir -p /workspace/backend && \
    cp -a /workspace/unpacked/backend/. /workspace/backend/

WORKDIR /workspace/backend

RUN gradle installDist --no-daemon

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /workspace/backend/build/install/mazarchive-backend/ /app/

ENV PORT=8080

EXPOSE 8080

CMD ["/app/bin/mazarchive-backend"]
