#!/bin/bash
set -e

echo "[+] Creating Dockerfile"

mkdir -p /root/app-source
cat <<EOF > /root/app-source/Dockerfile
FROM alpine
RUN echo "Hello from my-app"
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Build image my-app:1.0 using podman"
echo "2. Save to /root/my-app.tar"
echo "========================================"
