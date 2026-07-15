#!/bin/bash

# Stop script on error
set -e

echo "🚀 Building web with commercial flavor..."
flutter build web --web-define=FLAVOR=commercial

echo "🌐 Starting local HTTP server on port 5050..."
python3 -m http.server 5050 --directory build/web &
SERVER_PID=$!

# Ensure python server is stopped when script exits (even on Ctrl+C)
trap "echo '🛑 Stopping local server...'; kill $SERVER_PID" EXIT

echo "🔗 Starting ngrok tunneling..."
ngrok http 5050 --host-header=rewrite
