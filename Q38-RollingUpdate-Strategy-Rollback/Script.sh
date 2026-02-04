#!/bin/bash
set -e

echo "[+] Creating namespace and Deployment"

kubectl create ns prod --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: prod
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: lfccncf/nginx:1.12
        ports:
        - containerPort: 80
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Update maxSurge and maxUnavailable to 5%"
echo "2. Update image to lfccncf/nginx:1.13"
echo "3. Rollback to previous version"
echo "========================================"
