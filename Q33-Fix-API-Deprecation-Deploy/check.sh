#!/bin/bash
# Check script for Q33: Fix API Deprecation Deploy

echo "=========================================="
echo "Checking Q33: Fix API Deprecation Deploy"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists in garfish namespace
echo -n "[Check 1] Deployment 'web' exists in namespace 'garfish': "
if kubectl get deploy web -n garfish &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: YAML has correct apiVersion
echo -n "[Check 2] YAML uses apiVersion 'apps/v1': "
if grep -q "apiVersion: apps/v1" /home/candidate/credible-mite/web.yaml 2>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: YAML has selector field
echo -n "[Check 3] YAML has selector field: "
if grep -q "selector:" /home/candidate/credible-mite/web.yaml 2>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: Deployment is ready
echo -n "[Check 4] Deployment is ready: "
READY=$(kubectl get deploy web -n garfish -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deploy web -n garfish -o jsonpath='{.spec.replicas}' 2>/dev/null)
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
