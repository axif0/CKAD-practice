#!/bin/bash
# Check script for Q37: SecurityContext RunAsUser Capability

echo "=========================================="
echo "Checking Q37: SecurityContext RunAsUser Capability"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'store-deployment' exists in namespace 'grubworm': "
if kubectl get deploy store-deployment -n grubworm &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: runAsUser is 10000
echo -n "[Check 2] Pod-level runAsUser is 10000: "
RUN_AS=$(kubectl get deploy store-deployment -n grubworm -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
if [[ "$RUN_AS" == "10000" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $RUN_AS)"
    ((FAIL++))
fi

# Check 3: NET_BIND_SERVICE capability added
echo -n "[Check 3] Container has NET_BIND_SERVICE capability: "
CAPS=$(kubectl get deploy store-deployment -n grubworm -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.add[*]}' 2>/dev/null)
if [[ "$CAPS" == *"NET_BIND_SERVICE"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (capabilities: $CAPS)"
    ((FAIL++))
fi

# Check 4: Pods are running
echo -n "[Check 4] Deployment pods are running: "
READY=$(kubectl get deploy store-deployment -n grubworm -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ -n "$READY" && "$READY" -ge 1 ]]; then
    echo "✅ PASS ($READY ready)"
    ((PASS++))
else
    echo "❌ FAIL"
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
