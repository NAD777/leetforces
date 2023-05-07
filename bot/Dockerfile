FROM gradle:8.1.1-jdk17 AS build
WORKDIR /bot
COPY build.gradle.kts .
COPY src ./src
RUN gradle build --no-daemon

FROM openjdk:17-oracle
WORKDIR /bot
COPY --from=build /bot/build/libs/*.jar bot.jar
CMD java -jar bot.jar