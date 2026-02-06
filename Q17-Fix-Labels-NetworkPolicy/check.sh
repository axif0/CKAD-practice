#!/bin/bash
# Check script for Q17: Fix Labels NetworkPolicy

echo "=========================================="
echo "Checking Q17: Fix Labels NetworkPolicy"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: db-pod has correct label
echo -n "[Check 1] Pod 'db-pod' has label 'app=db': "
LABEL=$(kubectl get pod db-pod -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
if [[ "$LABEL" == "db" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
    ((FAIL++))
fi

# Check 2: api-pod has correct label
echo -n "[Check 2] Pod 'api-pod' has label 'app=api': "
LABEL=$(kubectl get pod api-pod -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
if [[ "$LABEL" == "api" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
    ((FAIL++))
fi

# Check 3: monitor-pod has correct label
echo -n "[Check 3] Pod 'monitor-pod' has label 'role=monitor': "
LABEL=$(kubectl get pod monitor-pod -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [[ "$LABEL" == "monitor" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
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
