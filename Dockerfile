# Pastikan tetap pakai 3.14 atau image yang support Takopi terbaru
FROM python:3.14-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    XDG_CONFIG_HOME=/app/config \
    XDG_DATA_HOME=/app/data \
    XDG_CACHE_HOME=/app/cache

WORKDIR /app

# 1. Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js (Versi 22.x)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# 3. Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# 4. Install Takopi (Suppress warning root user dengan flag env pip)
ENV PIP_ROOT_USER_ACTION=ignore
RUN pip install --no-cache-dir git+https://github.com/banteg/takopi.git

# 5. Install Opencode CLI
RUN npm install -g opencode-ai@latest
# 5a. Install PI coding agent
RUN npm install -g @mariozechner/pi-coding-agent


# 6. Install Plugin Auth Antigravity (FIXED)
# Kita HAPUS "bun run build" karena script itu tidak ada di repo plugin.
# Cukup install dependencies saja.
RUN git clone https://github.com/shekohex/opencode-google-antigravity-auth.git /opt/auth-plugin \
    && cd /opt/auth-plugin \
    && bun install

# 7. Config Opencode
RUN mkdir -p /app/config/opencode && \
    echo '{ "plugin": ["/opt/auth-plugin"] }' > /app/config/opencode/config.json

# 8. Entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

VOLUME ["/app/config", "/app/data"]

ENTRYPOINT ["/app/entrypoint.sh"]
