#!/bin/bash
set -e

echo "[+] Creating namespace, ResourceQuota, and Deployment"

kubectl create ns resource-test --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: resource-test
spec:
  hard:
    requests.cpu: "500m"
    requests.memory: "500Mi"
    limits.cpu: "1"
    limits.memory: "1Gi"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-resources
  namespace: resource-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "100m"
            memory: "128Mi"
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Update nginx-resources with requests 100m/128Mi"
echo "2. Set limits to double (200m/256Mi)"
echo "3. Adjust ResourceQuota to match deployment max capacity"
echo "========================================"
