#!/bin/bash
set -e

echo "[+] Creating Deployment"

kubectl create deploy secure-app --image=nginx --replicas=1

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Add Pod securityContext.runAsUser: 1000"
echo "2. Add container capability NET_ADMIN"
echo "========================================"
