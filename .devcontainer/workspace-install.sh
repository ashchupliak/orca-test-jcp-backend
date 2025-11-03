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
FLEET_VERSION="${FLEET_VERSION:-253.597}"
LAUNCHER_VERSION="${LAUNCHER_VERSION:-$FLEET_VERSION}"
LAUNCHER_LOCATION="${LAUNCHER_LOCATION:-/usr/local/bin/fleet-launcher}"

# Download launcher with retry logic and IPv4 preference
LAUNCHER_URL="https://plugins.jetbrains.com/fleet-parts/launcher/${FLEET_DOCKER_PLATFORM}/launcher-${LAUNCHER_VERSION}"
MAX_ATTEMPTS=5
DELAY=2
ATTEMPT=1
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    echo "Download attempt $ATTEMPT/$MAX_ATTEMPTS: $LAUNCHER_URL" >&2
    if curl -fLSS --ipv4 --connect-timeout 30 --max-time 300 "$LAUNCHER_URL" -o "${LAUNCHER_LOCATION}" 2>&1; then
        echo "Download successful" >&2
        break
    fi
    if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
        echo "Download failed, retrying in ${DELAY}s..." >&2
        sleep $DELAY
        DELAY=$((DELAY * 2))
    fi
    ATTEMPT=$((ATTEMPT + 1))
done

if [ ! -f "${LAUNCHER_LOCATION}" ]; then
    echo "ERROR: Failed to download Fleet launcher after multiple attempts" >&2
    exit 1
fi

chmod +x "${LAUNCHER_LOCATION}"

# Ensures SHIP, bundled plugins are downloaded to the image
# Fleet downloads artifacts BEFORE validating auth, it intentionally triggers an auth error to force artifact downloads.
# Temporarily disable errexit for this expected failure.
set +e
"${LAUNCHER_LOCATION}" --debug launch workspace --workspace-version $FLEET_VERSION -- --auth=dummy-argument-value-to-make-it-crash-but-we-only-care-about-artifacts-being-downloaded
set -e
