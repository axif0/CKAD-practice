#!/bin/bash
set -e

echo "[+] Creating Deployment and Service with wrong selector"

kubectl create deploy web-app --image=nginx --replicas=1
kubectl label deploy web-app app=webapp --overwrite
kubectl create svc clusterip web-svc --tcp=80:80
kubectl patch svc web-svc -p '{"spec":{"selector":{"app":"wrong"}}}'

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Fix web-svc selector to match web-app pods"
echo "========================================"
