#!/bin/bash
# Check script for Q15: Fix Ingress PathType

echo "=========================================="
echo "Checking Q15: Fix Ingress PathType"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Ingress exists
echo -n "[Check 1] Ingress 'broken-ingress' exists: "
if kubectl get ingress broken-ingress &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: PathType is valid
echo -n "[Check 2] PathType is valid (Prefix, Exact, or ImplementationSpecific): "
PATH_TYPE=$(kubectl get ingress broken-ingress -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
if [[ "$PATH_TYPE" == "Prefix" || "$PATH_TYPE" == "Exact" || "$PATH_TYPE" == "ImplementationSpecific" ]]; then
    echo "✅ PASS ($PATH_TYPE)"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_TYPE)"
    ((FAIL++))
fi

# Check 3: YAML file is fixed
echo -n "[Check 3] YAML file has valid pathType: "
if grep -qE "pathType: (Prefix|Exact|ImplementationSpecific)" mama.yaml 2>/dev/null; then
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
