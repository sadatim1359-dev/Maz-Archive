FROM gradle:8.10.2-jdk17 AS build

ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs=-Xmx768m"

WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y unzip && \
    rm -rf /var/lib/apt/lists/*

COPY . .

RUN ZIP_FILE=$(find /workspace -maxdepth 2 -type f -iname "*.zip" | head -n 1) && \
    test -n "$ZIP_FILE" && \
    mkdir -p /workspace/extracted && \
    unzip -q "$ZIP_FILE" -d /workspace/extracted && \
    BACKEND_DIR=$(dirname "$(find /workspace/extracted -type f -path "*/backend/settings.gradle.kts" -print -quit)") && \
    cd "$BACKEND_DIR" && \
    gradle clean installDist --no-daemon --stacktrace && \
    cp -r build/install/mazarchive-backend /workspace/dist

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /workspace/dist/ /app/

ENV PORT=8080

EXPOSE 8080

CMD ["/app/bin/mazarchive-backend"]
