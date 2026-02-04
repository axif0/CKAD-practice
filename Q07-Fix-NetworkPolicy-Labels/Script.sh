#!/bin/bash
set -e

echo "[+] Creating namespace, pods, and NetworkPolicies"

kubectl create ns network-demo --dry-run=client -o yaml | kubectl apply -f -
kubectl run frontend --image=nginx -n network-demo --labels=role=wrong
kubectl run backend --image=nginx -n network-demo --labels=role=wrong
kubectl run database --image=nginx -n network-demo --labels=role=wrong

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: network-demo
spec:
  podSelector:
    matchLabels:
      role: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
  namespace: network-demo
spec:
  podSelector:
    matchLabels:
      role: db
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Fix Pod labels to match NetworkPolicy selectors"
echo "========================================"
