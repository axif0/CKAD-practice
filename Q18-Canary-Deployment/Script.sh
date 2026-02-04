#!/bin/bash
set -e

echo "[+] Creating stable Deployment and Service"

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-stable
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
      version: stable
  template:
    metadata:
      labels:
        app: web
        version: stable
    spec:
      containers:
      - name: nginx
        image: nginx:1.14
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Scale web-stable to 3 replicas"
echo "2. Create web-canary with nginx:1.16, 1 replica"
echo "3. Ensure both have label app=web"
echo "========================================"
