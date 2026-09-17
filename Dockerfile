# Build backend
FROM gradle:8.10.2-jdk17 AS build

WORKDIR /home/gradle/project

COPY backend/ .

RUN gradle installDist --no-daemon

# Runtime
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /home/gradle/project/build/install/mazarchive-backend/ /app/

ENV PORT=8080

EXPOSE 8080

CMD ["/app/bin/mazarchive-backend"]
