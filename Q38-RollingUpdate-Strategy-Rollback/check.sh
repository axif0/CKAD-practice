#!/bin/bash
# Check script for Q38: RollingUpdate Strategy Rollback

echo "=========================================="
echo "Checking Q38: RollingUpdate Strategy Rollback"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'webapp' exists in namespace 'prod': "
if kubectl get deploy webapp -n prod &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: maxSurge is 5%
echo -n "[Check 2] maxSurge is 5%: "
MAX_SURGE=$(kubectl get deploy webapp -n prod -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
if [[ "$MAX_SURGE" == "5%" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $MAX_SURGE)"
    ((FAIL++))
fi

# Check 3: maxUnavailable is 5%
echo -n "[Check 3] maxUnavailable is 5%: "
MAX_UNAVAIL=$(kubectl get deploy webapp -n prod -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
if [[ "$MAX_UNAVAIL" == "5%" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $MAX_UNAVAIL)"
    ((FAIL++))
fi

# Check 4: Rollout history has multiple revisions
echo -n "[Check 4] Rollout history has multiple revisions (rollback done): "
REVISIONS=$(kubectl rollout history deploy/webapp -n prod 2>/dev/null | grep -c "^[0-9]")
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
