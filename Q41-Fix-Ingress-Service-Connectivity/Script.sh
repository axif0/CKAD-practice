#!/bin/bash
set -e

echo "[+] Creating namespace, Deployment, Service, and Ingress with errors"

kubectl create ns content-marlin --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /home/candidate/content-marlin

# Deployment
cat <<EOF > /home/candidate/content-marlin/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: content-marlin-deployment
  namespace: content-marlin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: content-marlin
  template:
    metadata:
      labels:
        app: content-marlin
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

# Service with WRONG selector
cat <<EOF > /home/candidate/content-marlin/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: content-marlin-svc
  namespace: content-marlin
spec:
  selector:
    app: wrong-app
  ports:
  - port: 8080
    targetPort: 80
EOF

# Ingress with WRONG service port
cat <<EOF > /home/candidate/content-marlin/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: content-marlin-ingress
  namespace: content-marlin
spec:
  rules:
  - host: content-marlin.local
    http:
      paths:
      - path: /content-marlin
        pathType: Prefix
        backend:
          service:
            name: content-marlin-svc
            port:
              number: 9999
EOF

kubectl apply -f /home/candidate/content-marlin/

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Check endpoints: kubectl get ep -n content-marlin"
echo "2. Fix Service selector and/or port"
echo "3. Fix Ingress backend port"
echo "========================================"
