#!/bin/bash
set -e

echo "[+] Creating namespace and ResourceQuota"

kubectl create ns prod --dry-run=client -o yaml | kubectl apply -f -
kubectl create quota prod-quota --hard=limits.cpu=2,limits.memory=4Gi -n prod

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Check quota: kubectl describe quota -n prod"
echo "2. Create Pod with half the quota limits"
echo "========================================"
