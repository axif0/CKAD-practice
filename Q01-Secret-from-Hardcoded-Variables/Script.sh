#!/bin/bash
set -e

echo "[+] Creating Deployment with hardcoded env vars"

kubectl create deploy api-server --image=nginx --replicas=1
kubectl set env deploy/api-server DB_USER=admin DB_PASS=Secret123!

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Create Secret db-credentials with DB_USER and DB_PASS"
echo "2. Update Deployment to use secretKeyRef"
echo "========================================"
