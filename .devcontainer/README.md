# Devcontainers

## Prerequisites for local development
- Docker
- https://github.com/devcontainers/cli

## Optimized Configuration (Fast & Stable)

This devcontainer configuration is optimized for CI/CD pipelines with:
- **Pre-built Java image** - Avoids SDKMAN downloads (503 errors) and reduces build time from 10+ minutes to ~2-3 minutes
- **Pre-installed dependencies** - All tools (Java, Docker CLI, Python) are baked into the image
- **Retry logic** - Network operations have exponential backoff retry to handle transient failures
- **IPv4 preference** - Avoids IPv6 connectivity issues in CI environments

## Configuration Details

### devcontainer.json
- Uses `dockerComposeFile` with pre-built Dockerfile (no runtime feature installations)
- All dependencies are pre-installed in the Dockerfile for maximum stability

### Dockerfile
- **Base image**: `mcr.microsoft.com/devcontainers/java:1-21` (includes Java 21 pre-installed)
- **Docker CLI**: Pre-installed with retry logic for package downloads
- **Build dependencies**: Pre-installed (git, python3, build-essential)
- **Fleet launcher**: Pre-downloaded with retry logic and IPv4 preference

## How to create a devcontainer with Workspace inside
- Create `devcontainer.json` with docker-compose setup (no features needed - everything is pre-installed): 
```json
{
  "name": "Java",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "remoteEnv": {
    "GRADLE_USER_HOME": "/workspace/.gradle",
    "DB_HOST": "postgres",
    "DB_PORT": "5432",
    "DB_NAME": "appdb",
    "DB_USER": "appuser",
    "DB_PASSWORD": "apppass",
    "SPRING_PROFILES_ACTIVE": "dev"
  },
  "forwardPorts": [8080, 5432]
}
```

- Add `Dockerfile` with optimized setup:
```dockerfile
# Use pre-built Java image instead of installing via SDKMAN (much faster and more stable)
FROM mcr.microsoft.com/devcontainers/java:1-21

# Install Docker-in-Docker support (pre-install to avoid runtime downloads)
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg lsb-release \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends git python3 python3-pip build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Pre-download Fleet launcher with retry logic
COPY --chmod=0755 ./workspace-install.sh /tmp/workspace-install.sh
RUN /tmp/workspace-install.sh
```

- Add `workspace-install.sh` with retry logic:
```shell
#!/usr/bin/env bash
set -euo pipefail

# Retry function for network operations
retry_with_backoff() {
    local max_attempts=5
    local delay=2
    local attempt=1
    local url="$1"
    local output="$2"
    
    while [ $attempt -le $max_attempts ]; do
        echo "Download attempt $attempt/$max_attempts: $url" >&2
        if curl -fLSS --ipv4 --connect-timeout 30 --max-time 300 "$url" -o "$output" 2>&1; then
            echo "Download successful" >&2
            return 0
        fi
        if [ $attempt -lt $max_attempts ]; then
            echo "Download failed, retrying in ${delay}s..." >&2
            sleep $delay
            delay=$((delay * 2))
        fi
        attempt=$((attempt + 1))
    done
    
    echo "Failed to download after $max_attempts attempts" >&2
    return 1
}

# Download Fleet launcher with retry logic and IPv4 preference
# ... (see workspace-install.sh for full implementation)
```

## How to check if everything works
- Build and run the devcontainer locally. Note: we use `--remove-existing-container --build-no-cache` to ensure that changes in the devcontainer.json are always
  applied on the container start. Otherwise, by default you will use the already built image. These flags are helpful during the 
  testing but are not required for the real usage.
```shell
cd /my/repository/root
devcontainer up --workspace-folder . --remove-existing-container --build-no-cache
```
- Check that the container is running
```shell
docker container ls
```
- Check that all necessary tools are present in the container by running the repository build. The needed secrets and exact 
build commands might differ from repo to repo. Here is an example:
```shell
devcontainer exec --workspace-folder . \
  --remote-env SPACE_USERNAME="<value>" \
  --remote-env SPACE_PASSWORD="<value>" \
  ./gradlew build
```
- Check that the Workspace is installed correctly. Note that the workspace version in the command should match the one from the image.
```shell
devcontainer exec --workspace-folder . \
  --remote-env SPACE_USERNAME="<value>" \
  --remote-env SPACE_PASSWORD="<value>" \
  /usr/local/bin/fleet-launcher --debug launch workspace --workspace-version 253.597 -- --auth=accept-everyone --publish --enableSmartMode
```
