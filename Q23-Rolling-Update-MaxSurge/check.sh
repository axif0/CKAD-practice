#!/bin/bash
# Check script for Q23: Rolling Update MaxSurge

echo "=========================================="
echo "Checking Q23: Rolling Update MaxSurge"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment 'app' has maxSurge of 5%
echo -n "[Check 1] Deployment 'app' has maxSurge of 5%: "
MAX_SURGE=$(kubectl get deploy app -n nov2025 -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
if [[ "$MAX_SURGE" == "5%" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $MAX_SURGE)"
    ((FAIL++))
fi

# Check 2: Deployment 'app' has maxUnavailable of 2%
echo -n "[Check 2] Deployment 'app' has maxUnavailable of 2%: "
MAX_UNAVAIL=$(kubectl get deploy app -n nov2025 -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
if [[ "$MAX_UNAVAIL" == "2%" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $MAX_UNAVAIL)"
    ((FAIL++))
fi

# Check 3: Deployment 'web1' uses nginx:1.13
echo -n "[Check 3] Deployment 'web1' uses nginx:1.13 image: "
IMAGE=$(kubectl get deploy web1 -n nov2025 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == *"nginx:1.13"* || "$IMAGE" == "nginx:1.13" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 4: Deployment 'app' has rollout history
echo -n "[Check 4] Deployment 'app' has rollout history (rollback done): "
REVISIONS=$(kubectl rollout history deploy/app -n nov2025 2>/dev/null | grep -c "^[0-9]")
if [[ $REVISIONS -ge 2 ]]; then
    echo "✅ PASS ($REVISIONS revisions)"
    ((PASS++))
else
    echo "❌ FAIL (only $REVISIONS revision(s))"
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
