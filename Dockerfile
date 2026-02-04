# UPDATE: Menggunakan Python 3.14 sesuai requirement Takopi terbaru
FROM python:3.14-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    XDG_CONFIG_HOME=/app/config \
    XDG_DATA_HOME=/app/data \
    XDG_CACHE_HOME=/app/cache

WORKDIR /app

# 1. Install dependencies sistem dasar
# Kita perlu 'git' dan 'build-essential' untuk compile library Python jika perlu
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js & NPM (Versi LTS 22.x - Standard 2026)
# Opencode membutuhkan environment Node.js yang stabil
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# 3. Install Bun (Wajib untuk plugin auth shekohex)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# 4. Install Takopi (Bridge)
# Sekarang menggunakan Python 3.14 environment, error pip seharusnya hilang
RUN pip install --no-cache-dir git+https://github.com/banteg/takopi.git

# 5. Install Opencode (The Agent)
RUN npm install -g opencode-ai@latest

# 6. Install Plugin Auth Antigravity (The Key)
# Clone manual dan build dengan Bun
RUN git clone https://github.com/shekohex/opencode-google-antigravity-auth.git /opt/auth-plugin \
    && cd /opt/auth-plugin \
    && bun install \
    && bun run build

# 7. Pre-configure Opencode
# Buat folder config agar plugin terdeteksi
RUN mkdir -p /app/config/opencode && \
    echo '{ "plugin": ["/opt/auth-plugin"] }' > /app/config/opencode/config.json

# 8. Script Entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose volumes
VOLUME ["/app/config", "/app/data"]

ENTRYPOINT ["/app/entrypoint.sh"]
