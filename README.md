# JCP Backend Service - Spring Boot + PostgreSQL

A realistic Spring Boot backend service with PostgreSQL database for E2E testing.

## Purpose

Tests the following scenarios:
- Multi-container devcontainer setup (app + database)
- Database connections and initialization
- Spring Boot application startup
- Health checks and actuator endpoints
- Complex dependency resolution

## Architecture

```
┌─────────────────┐
│  Spring Boot    │
│  Application    │
│   (Port 8080)   │
└────────┬────────┘
         │
         │ JDBC
         ↓
┌─────────────────┐
│   PostgreSQL    │
│   Database      │
│   (Port 5432)   │
└─────────────────┘
```

## Quick Start

### Using Devcontainer

The container setup automatically:
1. Starts PostgreSQL database
2. Runs init script with sample data
3. Configures Spring Boot to connect
4. Downloads Gradle dependencies

### Manual Local Run

```bash
# Start PostgreSQL
docker-compose -f .devcontainer/docker-compose.yml up -d postgres

# Run application
./gradlew bootRun
```

### Test the Service

```bash
# Health check
curl http://localhost:8080/api/health

# Ping endpoint
curl http://localhost:8080/api/ping

# Actuator health
curl http://localhost:8080/actuator/health
```

## Database

### Schema

- **users**: User accounts (id, username, email, timestamps)
- **tasks**: User tasks (id, user_id, title, description, status, timestamps)

### Access

```bash
# From within the container
psql -h postgres -U appuser -d appdb

# Or via port forwarding
psql -h localhost -p 5432 -U appuser -d appdb
# Password: apppass
```

## Testing

```bash
./gradlew test
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `postgres` | Database host |
| `DB_PORT` | `5432` | Database port |
| `DB_NAME` | `appdb` | Database name |
| `DB_USER` | `appuser` | Database username |
| `DB_PASSWORD` | `apppass` | Database password |
| `PORT` | `8080` | Application port |
| `SPRING_PROFILES_ACTIVE` | `dev` | Spring profile |

## Expected Behavior

1. **Clone**: ~15 MB
2. **Build**: ~60 seconds (with dependency download)
3. **Startup**: ~10 seconds (including DB connection)
4. **Memory**: ~1 GB
5. **Container Size**: ~800 MB (app + database)

## Use in E2E Tests

```kotlin
val payload = mapOf(
    "definition" to mapOf(
        "type" to "devcontainer",
        "instanceTypeId" to instanceTypeId,
        "git" to mapOf(
            "repositories" to listOf(
                mapOf(
                    "cloneUrl" to "https://github.com/your-org/orca-test-jcp-backend",
                    "ref" to "main"
                )
            )
        ),
        "workspaceFolder" to "orca-test-jcp-backend",
        "configPath" to "orca-test-jcp-backend/.devcontainer/devcontainer.json",
        "env" to mapOf(
            "GITHUB_TOKEN" to mapOf("key" to "GITHUB_TOKEN", "value" to githubToken)
        ),
        "runCmd" to "./gradlew bootRun"
    )
)
```

## Health Check Integration

The service provides multiple health endpoints for monitoring:

- `/api/health` - Custom health endpoint
- `/actuator/health` - Spring Boot actuator health
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics

Perfect for testing environment activation detection in Orca.
