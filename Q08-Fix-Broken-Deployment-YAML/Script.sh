#!/bin/bash
set -e

echo "[+] Creating broken Deployment YAML"

cat <<EOF > /root/broken-deploy.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: broken-app
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: web
          image: nginx
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Tasks:"
echo "1. Fix apiVersion to apps/v1"
echo "2. Add selector.matchLabels"
echo "3. Apply the manifest"
echo "========================================"
