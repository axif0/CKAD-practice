#!/bin/bash
set -e

echo "[+] Creating namespace, pods, and NetworkPolicies"

kubectl create ns charming-macaw --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: front
  namespace: charming-macaw
  labels:
    role: frontend
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: charming-macaw
  labels:
    role: database
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: v1
kind: Pod
metadata:
  name: newpod
  namespace: charming-macaw
  labels:
    wrong: label
spec:
  containers:
  - name: nginx
    image: nginx
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-middle-traffic
  namespace: charming-macaw
spec:
  podSelector:
    matchLabels:
      role: middle
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    - podSelector:
        matchLabels:
          role: database
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: frontend
    - podSelector:
        matchLabels:
          role: database
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. kubectl get netpol -n charming-macaw -o yaml"
echo "2. Update newpod labels to match NetworkPolicy"
echo "========================================"
