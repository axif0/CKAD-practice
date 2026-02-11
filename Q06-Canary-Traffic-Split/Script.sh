#!/bin/bash
set -e

echo "[+] Creating Deployment and Service"

kubectl create deploy web-app --image=nginx:latest --replicas=5
kubectl label deploy web-app app=webapp version=v1 --overwrite
kubectl create svc clusterip web-service --tcp=80:80
kubectl patch svc web-service -p '{"spec":{"selector":{"app":"webapp"}}}'

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Scale web-app to 8 replicas"
echo "2. Create web-app-canary with 2 replicas"
echo "3. Verify both are in Service endpoints"
echo "========================================"
