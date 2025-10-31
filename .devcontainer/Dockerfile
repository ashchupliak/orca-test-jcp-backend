# Use pre-built Java image instead of installing via SDKMAN (much faster and more stable)
# This avoids SDKMAN 503 errors and reduces build time from 10+ minutes to ~2-3 minutes
FROM mcr.microsoft.com/devcontainers/java:1-21

# Install Docker-in-Docker support (pre-install to avoid runtime downloads)
# Detect OS type (Debian vs Ubuntu) and use appropriate Docker repository
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
    && DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') \
    && CODENAME=$(lsb_release -cs) \
    && if [ "$DISTRO" = "debian" ]; then \
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $CODENAME stable" > /etc/apt/sources.list.d/docker.list; \
    else \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" > /etc/apt/sources.list.d/docker.list; \
    fi \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code dependencies (pre-install to avoid runtime downloads)
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        git \
        python3 \
        python3-pip \
        build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Pre-download Fleet launcher and dependencies (with retry logic and IPv4 preference)
COPY --chmod=0755 ./workspace-install.sh /tmp/workspace-install.sh
RUN /tmp/workspace-install.sh
