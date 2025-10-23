#!/usr/bin/env bash
set -euo pipefail

# Detect platform architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)
    DEFAULT_PLATFORM="linux_x64"
    ;;
  aarch64|arm64)
    DEFAULT_PLATFORM="linux_aarch64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

# Config (use bash assignments; allow env overrides)
FLEET_DOCKER_PLATFORM="${FLEET_DOCKER_PLATFORM:-$DEFAULT_PLATFORM}"
FLEET_VERSION="${FLEET_VERSION:-253.588}"
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
