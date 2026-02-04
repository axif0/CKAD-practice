#!/bin/bash
set -e

echo "[+] Creating Deployment"

kubectl create deploy app-v1 --image=nginx:1.20 --replicas=2

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Update image to nginx:1.25"
echo "2. Rollback to previous version"
echo "========================================"
