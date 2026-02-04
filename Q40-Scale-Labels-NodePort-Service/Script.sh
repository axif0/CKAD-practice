#!/bin/bash
set -e

echo "[+] Creating namespace and Deployment"

kubectl create ns prod --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: prod
spec:
  replicas: 1
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
        ports:
        - containerPort: 80
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Scale nginx-deployment to 2 replicas"
echo "2. Add label role=webFrontEnd to Pod template"
echo "3. Create NodePort Service rover exposing the deployment"
echo "========================================"
