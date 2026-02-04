#!/bin/bash
set -e

echo "[+] Creating namespace, Roles, and Deployment"

kubectl create ns cute-panda --dry-run=client -o yaml | kubectl apply -f -

# Create multiple roles - one suitable, others not
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n cute-panda
kubectl create role secret-admin --verb=get,list,create,delete --resource=secrets -n cute-panda
kubectl create role config-viewer --verb=get,list --resource=configmaps -n cute-panda

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scraper
  namespace: cute-panda
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scraper
  template:
    metadata:
      labels:
        app: scraper
    spec:
      containers:
      - name: scraper
        image: bitnami/kubectl:latest
        command: ["/bin/sh", "-c"]
        args: ["while true; do kubectl get pods -n cute-panda; sleep 10; done"]
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Create SA scraper"
echo "2. Review Roles: kubectl get roles -n cute-panda"
echo "3. Bind best-fitting Role to scraper SA"
echo "4. Update scraper Deployment to use SA scraper"
echo "========================================"
