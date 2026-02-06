#!/bin/bash
# Check script for Q31: Fix Labels NetworkPolicies

echo "=========================================="
echo "Checking Q31: Fix Labels NetworkPolicies"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: db-pod has correct labels
echo -n "[Check 1] Pod 'db-pod' has labels 'app=db' and 'tier=backend': "
APP=$(kubectl get pod db-pod -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
TIER=$(kubectl get pod db-pod -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
if [[ "$APP" == "db" && "$TIER" == "backend" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (app=$APP, tier=$TIER)"
    ((FAIL++))
fi

# Check 2: api-pod has correct labels
echo -n "[Check 2] Pod 'api-pod' has labels 'app=api' and 'tier=frontend': "
APP=$(kubectl get pod api-pod -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
TIER=$(kubectl get pod api-pod -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
if [[ "$APP" == "api" && "$TIER" == "frontend" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (app=$APP, tier=$TIER)"
    ((FAIL++))
fi

# Check 3: monitor-pod has correct label
echo -n "[Check 3] Pod 'monitor-pod' has label 'role=monitor': "
ROLE=$(kubectl get pod monitor-pod -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [[ "$ROLE" == "monitor" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (role=$ROLE)"
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
