#!/bin/bash
set -e

echo "[+] Creating namespace and Deployment"

kubectl create ns prod --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /home/candidate/spicy-pikachu

cat <<EOF > /home/candidate/spicy-pikachu/app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  namespace: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 8081
EOF

kubectl apply -f /home/candidate/spicy-pikachu/app-deployment.yaml

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Add readiness probe with path /healthz on port 8081"
echo "  - initialDelaySeconds: 6"
echo "  - periodSeconds: 3"
echo "========================================"
