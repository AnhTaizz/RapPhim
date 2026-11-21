FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /project
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 mvn -B package
FROM tomcat:10.1-jdk17-temurin
COPY --from=build /project/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war
