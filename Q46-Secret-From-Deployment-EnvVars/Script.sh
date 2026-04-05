#!/bin/bash
set -e

echo "[+] Creating namespace and Deployment with hardcoded env vars"

kubectl create ns relaxed-shark --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: relaxed-shark
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        env:
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_DB
          value: "mydb"
        - name: POSTGRES_PASSWORD
          value: "secretpass123"
        ports:
        - containerPort: 5432
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Find hardcoded env values in Deployment"
echo "2. Create Secret postgres with keys: username, database, password"
echo "3. Update Deployment to use secretKeyRef"
echo "========================================"
