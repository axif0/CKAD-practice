#!/bin/bash
# Check script for Q11: Security Context

echo "=========================================="
echo "Checking Q11: Security Context"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'secure-app' exists: "
if kubectl get deploy secure-app &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Pod-level runAsUser is 1000
echo -n "[Check 2] Pod-level runAsUser is 1000: "
RUN_AS_USER=$(kubectl get deploy secure-app -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
if [[ "$RUN_AS_USER" == "1000" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $RUN_AS_USER)"
    ((FAIL++))
fi

# Check 3: Container has NET_ADMIN capability
echo -n "[Check 3] Container has NET_ADMIN capability: "
CAPS=$(kubectl get deploy secure-app -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.add[*]}' 2>/dev/null)
if [[ "$CAPS" == *"NET_ADMIN"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (capabilities: $CAPS)"
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
