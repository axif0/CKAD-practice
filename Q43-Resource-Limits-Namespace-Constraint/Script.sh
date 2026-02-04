#!/bin/bash
set -e

echo "[+] Creating namespace with LimitRange and Deployment"

kubectl create ns haddock --dry-run=client -o yaml | kubectl apply -f -

# Create LimitRange with max memory 512Mi
kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
  namespace: haddock
spec:
  limits:
  - max:
      memory: 512Mi
    type: Container
EOF

mkdir -p /home/candidate/chief-cardinal

cat <<EOF > /home/candidate/chief-cardinal/nosql.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nosql
  namespace: haddock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nosql
  template:
    metadata:
      labels:
        app: nosql
    spec:
      containers:
      - name: redis
        image: redis
        ports:
        - containerPort: 6379
EOF

kubectl apply -f /home/candidate/chief-cardinal/nosql.yaml

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Check LimitRange: kubectl describe limitrange -n haddock"
echo "2. Update nosql Deployment with memory request 128Mi"
echo "3. Set memory limit to half of max (256Mi)"
echo "========================================"
