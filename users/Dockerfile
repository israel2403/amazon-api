FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
COPY eureka-server/ eureka-server/
COPY users/ users/
COPY gateway/ gateway/

RUN mvn -DskipTests -pl users -am package
RUN cp users/target/*.jar /tmp/app.jar

FROM eclipse-temurin:21-jre
ENV SERVER_PORT=8081
EXPOSE 8081
COPY --from=build /tmp/app.jar /app.jar
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app.jar"]
