# Orca Test JCP Backend - Agent Guide

## Project summary

- Spring Boot + PostgreSQL sample service used for Orca E2E/devcontainer validation.
- Validates multi-container devcontainer setup, DB init, and app startup.

## Design patterns and architecture

- Two-container topology: app (8080) + Postgres (5432).
- Devcontainer drives DB init and app configuration.
- Health endpoints: `/api/health` and `/actuator/health` for activation checks.

## Test layout

- `src/test/kotlin/` - Unit/integration tests.
- `.devcontainer/docker-compose.yml` - Local Postgres for dev/testing.

## How to run tests

```bash
# Start Postgres
docker-compose -f .devcontainer/docker-compose.yml up -d postgres

# Run tests
./gradlew test
```

## How to run locally

```bash
./gradlew bootRun
```

## E2E components

- Devcontainer config: `.devcontainer/devcontainer.json`.
- Typical run command for environments: `./gradlew bootRun`.
- Used by Orca facade E2E provisioning to validate DB-backed containers.
