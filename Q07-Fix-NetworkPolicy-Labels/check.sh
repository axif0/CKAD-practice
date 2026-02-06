#!/bin/bash
# Check script for Q07: Fix NetworkPolicy Labels

echo "=========================================="
echo "Checking Q07: Fix NetworkPolicy Labels"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: frontend pod has correct label
echo -n "[Check 1] Pod 'frontend' has label 'role=frontend': "
LABEL=$(kubectl get pod frontend -n network-demo -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [[ "$LABEL" == "frontend" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
    ((FAIL++))
fi

# Check 2: backend pod has correct label
echo -n "[Check 2] Pod 'backend' has label 'role=backend': "
LABEL=$(kubectl get pod backend -n network-demo -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [[ "$LABEL" == "backend" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
    ((FAIL++))
fi

# Check 3: database pod has correct label
echo -n "[Check 3] Pod 'database' has label 'role=db': "
LABEL=$(kubectl get pod database -n network-demo -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [[ "$LABEL" == "db" ]]; then
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
