#!/bin/bash
set -e

echo "[+] Creating namespace, ServiceAccount, Role, RoleBinding, and Deployment"

kubectl create ns gorilla --dry-run=client -o yaml | kubectl apply -f -

# Create a ServiceAccount with proper permissions
kubectl create sa honeybee-sa -n gorilla

kubectl create role pod-reader --verb=get,list,watch --resource=pods -n gorilla
kubectl create rolebinding honeybee-binding --role=pod-reader --serviceaccount=gorilla:honeybee-sa -n gorilla

mkdir -p /home/candidate/prompt-escargot

# Create deployment using default SA (which lacks permissions)
cat <<EOF > /home/candidate/prompt-escargot/honeybee-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: honeybee-deployment
  namespace: gorilla
spec:
  replicas: 1
  selector:
    matchLabels:
      app: honeybee
  template:
    metadata:
      labels:
        app: honeybee
    spec:
      containers:
      - name: kubectl
        image: bitnami/kubectl:latest
        command: ["/bin/sh", "-c"]
        args: ["while true; do kubectl get pods -n gorilla; sleep 10; done"]
EOF

kubectl apply -f /home/candidate/prompt-escargot/honeybee-deployment.yaml

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Check logs: kubectl logs -n gorilla -l app=honeybee"
echo "2. Find the ServiceAccount with proper permissions"
echo "3. Update Deployment to use correct ServiceAccount"
echo "========================================"
