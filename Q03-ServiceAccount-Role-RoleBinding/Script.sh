#!/bin/bash
set -e

echo "[+] Creating namespace and pod"

kubectl create ns audit --dry-run=client -o yaml | kubectl apply -f -
kubectl run log-collector --image=nginx -n audit

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Create SA log-sa"
echo "2. Create Role log-role (get,list,watch pods)"
echo "3. Create RoleBinding log-rb"
echo "4. Update Pod to use log-sa"
echo "========================================"
