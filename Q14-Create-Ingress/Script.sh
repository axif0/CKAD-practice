#!/bin/bash
set -e

echo "[+] Cleaning up existing resources (if any)"
 
kubectl delete svc web-svc --ignore-not-found=true


echo "[+] Creating Service"

kubectl create svc clusterip web-svc --tcp=8080:80

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Create Ingress web-ingress for web.example.com"
echo "========================================"
