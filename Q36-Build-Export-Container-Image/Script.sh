#!/bin/bash
set -e

echo "[+] Creating Dockerfile"

mkdir -p /home/candidate/build

cat <<EOF > /home/candidate/build/Dockerfile
FROM alpine:latest
RUN apk add --no-cache curl
CMD ["echo", "Hello from macaque"]
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Build image macaque:1.2 using podman/docker/buildah"
echo "2. Export to /home/candidate/macaque-1.2.tar"
echo "========================================"
