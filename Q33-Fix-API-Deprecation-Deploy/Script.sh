#!/bin/bash
set -e

echo "[+] Creating namespace and broken manifest"

kubectl create ns garfish --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /home/candidate/credible-mite

cat <<EOF > /home/candidate/credible-mite/web.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
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
echo "1. Fix API deprecation in /home/candidate/credible-mite/web.yaml"
echo "2. Deploy to namespace garfish"
echo "========================================"
