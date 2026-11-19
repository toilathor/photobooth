#!/bin/bash
# Serve a live preview page of assets/frames (personal + commercial).
# Only the frames folder is exposed, never the rest of the project.
#
#   bash scripts/frame_preview.sh            # http://localhost:8000 + LAN address
#   bash scripts/frame_preview.sh --tunnel   # also opens a public https link (cloudflared)
#
# The page refreshes by itself when a frame file changes.
set -e
cd "$(dirname "$0")/.."

PORT="${PORT:-8000}"
DIR="build/frame_preview"

rm -rf "$DIR"
mkdir -p "$DIR"
ln -s "$(pwd)/assets/frames" "$DIR/frames"
cp scripts/frame_preview/index.html "$DIR/index.html"

python3 -m http.server "$PORT" --directory "$DIR" >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null' EXIT

echo "Local:   http://localhost:$PORT"
LAN_IP="$(ipconfig getifaddr en0 2>/dev/null || true)"
[ -n "$LAN_IP" ] && echo "Cùng Wi-Fi: http://$LAN_IP:$PORT"

if [ "${1:-}" = "--tunnel" ]; then
    echo "Public link (Ctrl+C để tắt, ai có link đều xem được):"
    cloudflared tunnel --url "http://localhost:$PORT"
else
    wait $SERVER_PID
fi
