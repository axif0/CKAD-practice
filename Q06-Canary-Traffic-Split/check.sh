#!/bin/bash
# Check script for Q06: Canary Traffic Split

echo "=========================================="
echo "Checking Q06: Canary Traffic Split"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: web-app has 8 replicas
echo -n "[Check 1] Deployment 'web-app' has 8 replicas: "
REPLICAS=$(kubectl get deploy web-app -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$REPLICAS" == "8" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $REPLICAS)"
    ((FAIL++))
fi

# Check 2: web-app-canary exists
echo -n "[Check 2] Deployment 'web-app-canary' exists: "
if kubectl get deploy web-app-canary -n default &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: web-app-canary has 2 replicas
echo -n "[Check 3] Deployment 'web-app-canary' has 2 replicas: "
CANARY_REPLICAS=$(kubectl get deploy web-app-canary -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$CANARY_REPLICAS" == "2" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $CANARY_REPLICAS)"
    ((FAIL++))
fi

# Check 4: Service has endpoints from both deployments
echo -n "[Check 4] Service 'web-service' has endpoints: "
EP_COUNT=$(kubectl get endpoints web-service -n default -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o "ip" | wc -l)
if [[ $EP_COUNT -ge 10 ]]; then
    echo "✅ PASS ($EP_COUNT endpoints)"
    ((PASS++))
else
    echo "❌ FAIL (expected 10, got: $EP_COUNT)"
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
