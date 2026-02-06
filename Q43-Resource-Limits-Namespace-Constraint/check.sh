#!/bin/bash
# Check script for Q43: Resource Limits Namespace Constraint

echo "=========================================="
echo "Checking Q43: Resource Limits Namespace Constraint"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'nosql' exists in namespace 'haddock': "
if kubectl get deploy nosql -n haddock &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Memory request is 128Mi
echo -n "[Check 2] Memory request is 128Mi: "
MEM_REQ=$(kubectl get deploy nosql -n haddock -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [[ "$MEM_REQ" == "128Mi" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $MEM_REQ)"
    ((FAIL++))
fi

# Check 3: Memory limit is 256Mi (half of max 512Mi constraint)
echo -n "[Check 3] Memory limit is 256Mi: "
MEM_LIM=$(kubectl get deploy nosql -n haddock -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [[ "$MEM_LIM" == "256Mi" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $MEM_LIM)"
    ((FAIL++))
fi

# Check 4: Pod is running
echo -n "[Check 4] Pod is running: "
POD_STATUS=$(kubectl get pods -n haddock -l app=nosql -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" == "Running" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (status: $POD_STATUS)"
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
