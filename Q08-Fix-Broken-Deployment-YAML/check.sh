#!/bin/bash
# Check script for Q08: Fix Broken Deployment YAML

echo "=========================================="
echo "Checking Q08: Fix Broken Deployment YAML"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists and is running
echo -n "[Check 1] Deployment 'broken-app' exists: "
if kubectl get deploy broken-app &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Deployment has correct apiVersion
echo -n "[Check 2] YAML has apiVersion 'apps/v1': "
if grep -q "apiVersion: apps/v1" /home/asif/Downloads/CKAD-2025-normalized/Q08-Fix-Broken-Deployment-YAML/mama.yaml 2>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Deployment has selector
echo -n "[Check 3] YAML has selector field: "
if grep -q "selector:" /home/asif/Downloads/CKAD-2025-normalized/Q08-Fix-Broken-Deployment-YAML/mama.yaml 2>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: Deployment is ready
echo -n "[Check 4] Deployment is ready: "
READY=$(kubectl get deploy broken-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deploy broken-app -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$READY" == "$DESIRED" && -n "$READY" ]]; then
    echo "✅ PASS ($READY/$DESIRED ready)"
    ((PASS++))
else
    echo "❌ FAIL ($READY/$DESIRED ready)"
    ((FAIL++))
fi

# Summary
echo ""
echo "=========================================="
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -eq 0 ]]; then
    echo "✅ ALL CHECKS PASSED!"
    exit 0
else
    echo "❌ SOME CHECKS FAILED"
    exit 1
fi
