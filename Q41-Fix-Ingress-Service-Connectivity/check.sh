#!/bin/bash
# Check script for Q41: Fix Ingress Service Connectivity

echo "=========================================="
echo "Checking Q41: Fix Ingress Service Connectivity"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'content-marlin-deployment' exists: "
if kubectl get deploy content-marlin-deployment -n content-marlin &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Service has endpoints
echo -n "[Check 2] Service 'content-marlin-svc' has endpoints: "
EP=$(kubectl get endpoints content-marlin-svc -n content-marlin -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
if [[ -n "$EP" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (no endpoints - check selector)"
    ((FAIL++))
fi

# Check 3: Ingress exists and configured
echo -n "[Check 3] Ingress 'content-marlin-ingress' exists: "
if kubectl get ingress content-marlin-ingress -n content-marlin &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: Ingress has correct host
echo -n "[Check 4] Ingress host is 'content-marlin.local': "
HOST=$(kubectl get ingress content-marlin-ingress -n content-marlin -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [[ "$HOST" == "content-marlin.local" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $HOST)"
    ((FAIL++))
fi

# Check 5: Ingress path is correct
echo -n "[Check 5] Ingress path is '/content-marlin': "
PATH_VAL=$(kubectl get ingress content-marlin-ingress -n content-marlin -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
if [[ "$PATH_VAL" == "/content-marlin" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_VAL)"
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
