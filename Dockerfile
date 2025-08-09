# ---- build stage ----
FROM maven:3.9.6-amazoncorretto-17 AS builder
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests clean package

# ---- runtime stage ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /workspace/target/webapp-game-0.0.1-SNAPSHOT.jar /app/app.jar

EXPOSE 8080

USER appuser

ENTRYPOINT ["java","-jar","/app/app.jar"]
