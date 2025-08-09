# eks-web-game-java

Simple Spring Boot web app (Game API) for demo CI/CD with Jenkins -> ECR -> EKS.

## Build locally
mvn -B -DskipTests clean package

## Docker
docker build -t webapp-game:local .
docker run -p 8080:8080 webapp-game:local

## API
GET /api/games
GET /api/games/{id}
POST /api/games
PUT /api/games/{id}
DELETE /api/games/{id}
