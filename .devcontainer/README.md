# Devcontainers

## Prerequisites for local development
- Docker
- https://github.com/devcontainers/cli

## How to create a devcontainer with Workspace inside
- Create `devcontainer.json` with necessary JDK, docker, claude code. In this example we use features to install necessary 
tools to the image. 
```json
{
  "name": "Java",
  "dockerFile": "./Dockerfile",
  "features": {
    "ghcr.io/devcontainers/features/java:1": {
      "version": "21-oracle",
      "jdkDistro": "oracle"
    },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/anthropics/devcontainer-features/claude-code:1.0": {}
  },

  "remoteUser": "vscode"
}
```
- Add `Dockerfile` and install the Workspace there
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

COPY --chmod=0755 ./workspace-install.sh /tmp/workspace-install.sh
RUN /tmp/workspace-install.sh
```
```shell
#!/usr/bin/env bash
set -euo pipefail

# Config (use bash assignments; allow env overrides)
FLEET_DOCKER_PLATFORM="${FLEET_DOCKER_PLATFORM:-linux_x64}"
FLEET_VERSION="${FLEET_VERSION:-253.597}"
LAUNCHER_VERSION="${LAUNCHER_VERSION:-$FLEET_VERSION}"
LAUNCHER_LOCATION="${LAUNCHER_LOCATION:-/usr/local/bin/fleet-launcher}"

# Install curl if needed, then fetch launcher
apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && curl -fLSS "https://plugins.jetbrains.com/fleet-parts/launcher/${FLEET_DOCKER_PLATFORM}/launcher-${LAUNCHER_VERSION}" \
       -o "${LAUNCHER_LOCATION}" \
  && chmod +x "${LAUNCHER_LOCATION}" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Ensures SHIP, bundled plugins are downloaded to the image
"${LAUNCHER_LOCATION}" --debug launch workspace --workspace-version $FLEET_VERSION -- --auth=dummy-argument-value-to-make-it-crash-but-we-only-care-about-artifacts-being-downloaded
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
