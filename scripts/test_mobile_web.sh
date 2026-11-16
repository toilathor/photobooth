#!/bin/bash

# Stop script on error
set -e

FLUTTER_CMD="fvm flutter"
if ! command -v fvm &> /dev/null; then
    FLUTTER_CMD="flutter"
fi

echo "🚀 Building web with commercial flavor (WASM)..."
$FLUTTER_CMD build web --wasm --web-define=FLAVOR=commercial

echo "🌐 Starting local HTTP server on port 5050..."
python3 -m http.server 5050 --directory build/web &
SERVER_PID=$!

# Ensure python server is stopped when script exits (even on Ctrl+C)
trap "echo '🛑 Stopping local server...'; kill $SERVER_PID" EXIT

echo "🔗 Starting ngrok tunneling..."
ngrok http 5050 --host-header=rewrite
