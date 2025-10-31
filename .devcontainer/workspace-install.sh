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

# Install curl if needed, then fetch launcher (with retry logic and IPv4 preference)
apt-get update -qq \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

LAUNCHER_URL="https://plugins.jetbrains.com/fleet-parts/launcher/${FLEET_DOCKER_PLATFORM}/launcher-${LAUNCHER_VERSION}"
if ! retry_with_backoff "$LAUNCHER_URL" "${LAUNCHER_LOCATION}"; then
    echo "ERROR: Failed to download Fleet launcher after multiple attempts" >&2
    exit 1
fi

chmod +x "${LAUNCHER_LOCATION}"

# Ensures SHIP, bundled plugins are downloaded to the image
# Fleet downloads artifacts before validating auth, so we can use dummy auth and ignore the validation error
# The error happens after artifacts are downloaded, so we treat it as success for our purposes
"${LAUNCHER_LOCATION}" --debug launch workspace --workspace-version $FLEET_VERSION -- --auth=dummy-argument-value-to-make-it-crash-but-we-only-care-about-artifacts-being-downloaded || true
