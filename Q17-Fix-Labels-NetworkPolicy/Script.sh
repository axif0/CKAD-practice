#!/bin/bash
set -e

echo "[+] Creating Pods with wrong labels and NetworkPolicies"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  labels: {wrong: label}
spec:
  containers: [{name: db, image: nginx}]
---
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  labels: {wrong: label}
spec:
  containers: [{name: api, image: nginx}]
---
apiVersion: v1
kind: Pod
metadata:
  name: monitor-pod
  labels: {wrong: label}
spec:
  containers: [{name: monitor, image: nginx}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels: {app: db}
  ingress:
  - from: [{podSelector: {matchLabels: {app: api}}}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitor-to-backend
spec:
  podSelector:
    matchLabels: {app: db}
  ingress:
  - from: [{podSelector: {matchLabels: {role: monitor}}}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-backend
spec:
  podSelector: {matchLabels: {app: db}}
  policyTypes: [Ingress]
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. kubectl get netpol -o yaml"
echo "2. Fix Pod labels to enable communication"
echo "========================================"
