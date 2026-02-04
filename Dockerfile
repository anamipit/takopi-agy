# Gunakan Python 3.11 Slim (Debian-based, jadi ada bash)
FROM python:3.11-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    # Lokasi data Opencode agar persist di volume
    XDG_CONFIG_HOME=/app/config \
    XDG_DATA_HOME=/app/data \
    XDG_CACHE_HOME=/app/cache

WORKDIR /app

# 1. Install dependencies sistem
# curl & git: untuk download resource
# unzip: kadang dibutuhkan bun/npm
# build-essential: untuk compile native modules jika ada
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js & NPM (Wajib untuk Opencode)
# Kita pakai versi LTS terbaru (v20)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# 3. Install Bun (Opsional tapi recommended untuk plugin shekohex)
# Plugin shekohex dikembangkan dengan Bun, build-nya lebih stabil pakai Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# 4. Install Takopi (Bridge)
# Install langsung dari git master agar dapat fitur terbaru
RUN pip install --no-cache-dir git+https://github.com/banteg/takopi.git

# 5. Install Opencode (The Agent)
RUN npm install -g opencode-ai@latest

# 6. Install Plugin Auth Antigravity (The Key)
# Kita clone manual dan build agar dapat versi "bleeding edge"
RUN git clone https://github.com/shekohex/opencode-google-antigravity-auth.git /opt/auth-plugin \
    && cd /opt/auth-plugin \
    && bun install \
    && bun run build

# 7. Pre-configure Opencode untuk load plugin
# Kita buat file config awal yang menunjuk ke folder plugin yang baru kita build
RUN mkdir -p /app/config/opencode && \
    echo '{ "plugin": ["/opt/auth-plugin"] }' > /app/config/opencode/config.json

# 8. Script Entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose volumes untuk data login (PENTING)
VOLUME ["/app/config", "/app/data"]

# Gunakan bash sebagai shell default entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
