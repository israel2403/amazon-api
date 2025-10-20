FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# 1) Copy root pom and ALL module directories so the reactor sees them
COPY pom.xml .
COPY eureka-server/ eureka-server/
COPY users/ users/
COPY gateway/ gateway/

# 2) Build ONLY this module (+ any needed deps) from the reactor
RUN mvn -DskipTests -pl gateway -am package

# 3) Extract jar
RUN cp gateway/target/*.jar /tmp/app.jar

FROM eclipse-temurin:21-jre
ENV SERVER_PORT=8080
EXPOSE 8080
COPY --from=build /tmp/app.jar /app.jar
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app.jar"]
