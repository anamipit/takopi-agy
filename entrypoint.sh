#!/bin/bash
set -e

echo "🚀 Container Started..."

# Cek apakah Opencode terinstall
if ! command -v opencode &> /dev/null; then
    echo "❌ CRITICAL: Opencode CLI tidak ditemukan!"
    exit 1
fi

# Cek Plugin Auth
if [ ! -d "/opt/auth-plugin" ]; then
    echo "⚠️ Warning: Plugin folder not found."
fi

# Cek Status Login (Indikator kasar: folder antigravity-accounts)
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
    
    # Kita sleep infinity agar container tidak mati, memberi Anda waktu login
    # Setelah login sukses, Anda bisa restart container manual via Dokploy
    if [ "$1" != "force-start" ]; then
        echo "💤 Menunggu Anda login manual... (Container standby)"
        exec sleep infinity
    fi
else
    echo "✅ Auth data detected. Starting Takopi..."
fi

# Jalankan Takopi
# Pastikan token telegram ada di environment variable Dokploy
exec takopi -- opencode
