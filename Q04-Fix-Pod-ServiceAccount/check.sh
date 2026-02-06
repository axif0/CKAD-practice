#!/bin/bash
# Check script for Q04: Fix Pod ServiceAccount

echo "=========================================="
echo "Checking Q04: Fix Pod ServiceAccount"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Pod exists
echo -n "[Check 1] Pod exists and is running: "
POD_STATUS=$(kubectl get pod metrics-pod -n monitoring -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" == "Running" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (status: $POD_STATUS)"
    ((FAIL++))
fi

# Check 2: Pod uses correct ServiceAccount
echo -n "[Check 2] Pod uses the correct ServiceAccount: "
SA_NAME=$(kubectl get pod metrics-pod -n monitoring -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [[ -n "$SA_NAME" && "$SA_NAME" != "default" ]]; then
    echo "✅ PASS (using: $SA_NAME)"
    ((PASS++))
else
    echo "❌ FAIL (got: $SA_NAME)"
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
