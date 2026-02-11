#!/bin/bash
set -e
echo "[+] Cleaning up existing resources (if any)"
kubectl delete deployment api-server --ignore-not-found=true
 
echo "[+] Creating Deployment"

kubectl create deploy api-server --image=nginx --replicas=1
kubectl label deploy api-server app=api --overwrite

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Create NodePort Service api-nodeport"
echo "========================================"
