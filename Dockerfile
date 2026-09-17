FROM gradle:8.10.2-jdk17 AS build

ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs=-Xmx768m"

WORKDIR /home/gradle/project

COPY . .

RUN gradle clean installDist --no-daemon --stacktrace

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=build /home/gradle/project/build/install/mazarchive-backend/ /app/

ENV PORT=8080

EXPOSE 8080

CMD ["/app/bin/mazarchive-backend"]
