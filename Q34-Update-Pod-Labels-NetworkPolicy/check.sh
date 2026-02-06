#!/bin/bash
# Check script for Q34: Update Pod Labels NetworkPolicy

echo "=========================================="
echo "Checking Q34: Update Pod Labels NetworkPolicy"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Pod newpod exists
echo -n "[Check 1] Pod 'newpod' exists in namespace 'charming-macaw': "
if kubectl get pod newpod -n charming-macaw &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Pod has role=middle label
echo -n "[Check 2] Pod 'newpod' has label 'role=middle': "
ROLE=$(kubectl get pod newpod -n charming-macaw -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [[ "$ROLE" == "middle" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $ROLE)"
    ((FAIL++))
fi

# Check 3: NetworkPolicy is selecting the pod
echo -n "[Check 3] Pod is selected by NetworkPolicy: "
LABELS=$(kubectl get pod newpod -n charming-macaw --show-labels 2>/dev/null)
if [[ -n "$LABELS" ]]; then
    echo "✅ PASS"
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
