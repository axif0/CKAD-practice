#!/bin/bash
set -e

echo "[+] Creating namespace and Deployment"

kubectl create ns grubworm --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /home/candidate/daring-moccasin

cat <<EOF > /home/candidate/daring-moccasin/store-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: store-deployment
  namespace: grubworm
spec:
  replicas: 1
  selector:
    matchLabels:
      app: store
  template:
    metadata:
      labels:
        app: store
    spec:
      containers:
      - name: store
        image: nginx
        ports:
        - containerPort: 80
EOF

kubectl apply -f /home/candidate/daring-moccasin/store-deployment.yaml

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Add securityContext with runAsUser: 10000"
echo "2. Add capability NET_BIND_SERVICE"
echo "========================================"
