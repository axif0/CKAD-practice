#!/bin/bash
set -e

echo "[+] Creating namespace, SAs, Role, RoleBinding, and Pod"

kubectl create ns monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create sa monitor-sa -n monitoring
kubectl create sa wrong-sa -n monitoring
kubectl create role metrics-reader --verb=list --resource=pods -n monitoring
kubectl create rolebinding monitor-binding --role=metrics-reader --serviceaccount=monitoring:monitor-sa -n monitoring
kubectl run metrics-pod --image=nginx --serviceaccount=wrong-sa -n monitoring

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Identify correct SA via rolebindings"
echo "2. Update Pod to use correct SA"
echo "========================================"
