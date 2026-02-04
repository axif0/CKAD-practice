#!/bin/bash
set -e

echo "[+] Creating broken Ingress YAML"

cat <<EOF > /root/fix-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: broken-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Invalid
        backend:
          service:
            name: svc
            port:
              number: 80
EOF

echo "========================================"
echo "[✓] Environment READY"
echo ""
echo "Task: Fix pathType and apply"
echo "========================================"
