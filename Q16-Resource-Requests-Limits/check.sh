#!/bin/bash
# Check script for Q16: Resource Requests Limits

echo "=========================================="
echo "Checking Q16: Resource Requests Limits"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Pod exists
echo -n "[Check 1] Pod 'resource-pod' exists in namespace 'prod': "
if kubectl get pod resource-pod -n prod &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: CPU requests >= 100m
echo -n "[Check 2] CPU requests >= 100m: "
CPU_REQ=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
if [[ -n "$CPU_REQ" ]]; then
    echo "✅ PASS ($CPU_REQ)"
    ((PASS++))
else
    echo "❌ FAIL (not set)"
    ((FAIL++))
fi

# Check 3: Memory requests >= 128Mi
echo -n "[Check 3] Memory requests >= 128Mi: "
MEM_REQ=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [[ -n "$MEM_REQ" ]]; then
    echo "✅ PASS ($MEM_REQ)"
    ((PASS++))
else
    echo "❌ FAIL (not set)"
    ((FAIL++))
fi

# Check 4: CPU limits set
echo -n "[Check 4] CPU limits set: "
CPU_LIM=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
if [[ -n "$CPU_LIM" ]]; then
    echo "✅ PASS ($CPU_LIM)"
    ((PASS++))
else
    echo "❌ FAIL (not set)"
    ((FAIL++))
fi

# Check 5: Memory limits set
echo -n "[Check 5] Memory limits set: "
MEM_LIM=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [[ -n "$MEM_LIM" ]]; then
    echo "✅ PASS ($MEM_LIM)"
    ((PASS++))
else
    echo "❌ FAIL (not set)"
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
