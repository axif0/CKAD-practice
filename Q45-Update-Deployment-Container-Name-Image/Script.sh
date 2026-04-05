#!/bin/bash
set -e

echo "[+] Creating namespace and Deployment"

kubectl create ns rapid-goat --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox
  namespace: rapid-goat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: box
        image: busybox:latest
        command: ["sleep", "3600"]
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Change container name to musl"
echo "2. Change image to busybox:musl"
echo "3. Ensure changes are rolled out"
echo "WARNING: Do NOT delete the Deployment!"
echo "========================================"
