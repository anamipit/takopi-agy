#!/bin/bash
set -e

echo "🚀 Container Started..."

# --- [UPDATE] Start Cron Service ---
# Menyalakan cron daemon di background
echo "⏰ Starting Cron Service..."
service cron start
# -----------------------------------

# Cek apakah Opencode terinstall
if ! command -v opencode &> /dev/null; then
    echo "❌ CRITICAL: Opencode CLI tidak ditemukan!"
    exit 1
fi

# Cek Plugin Auth
if [ ! -d "/opt/auth-plugin" ]; then
    echo "⚠️ Warning: Plugin folder not found."
fi

# Cek Status Login
AUTH_FILE="$XDG_DATA_HOME/opencode/antigravity-accounts.json"
if [ ! -f "$AUTH_FILE" ]; then
    echo "=========================================================="
    echo "⚠️  AUTHENTICATION REQUIRED"
    echo "⚠️  Anda belum login ke Google Antigravity."
    echo "⚠️  Silakan masuk ke terminal container ini:"
    echo "    docker exec -it takopi-agent bash"
    echo "⚠️  Lalu jalankan command:"
    echo "    opencode auth login"
    echo "=========================================================="
    
    if [ "$1" != "force-start" ]; then
        echo "💤 Menunggu Anda login manual... (Container standby)"
        exec sleep infinity
    fi
else
    echo "✅ Auth data detected. Starting Takopi..."
fi

# Jalankan Takopi
exec takopi -- opencode
