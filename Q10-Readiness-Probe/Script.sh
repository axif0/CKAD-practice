#!/bin/bash
set -e

echo "[+] Creating Deployment"

kubectl create deploy api-deploy --image=nginx --replicas=2

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Add readiness probe to api-deploy"
echo "========================================"
