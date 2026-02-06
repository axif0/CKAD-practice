#!/bin/bash
# Check script for Q25: Pod Expose Port

echo "=========================================="
echo "Checking Q25: Pod Expose Port"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Pod exists
echo -n "[Check 1] Pod 'cache' exists in namespace 'web': "
if kubectl get pod cache -n web &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Image is redis:3.2
echo -n "[Check 2] Image is 'redis:3.2': "
IMAGE=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "redis:3.2" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 3: Port 6379 is exposed
echo -n "[Check 3] Port 6379 is exposed: "
PORT=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].ports[0].containerPort}' 2>/dev/null)
if [[ "$PORT" == "6379" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PORT)"
    ((FAIL++))
fi

# Check 4: Pod is running
echo -n "[Check 4] Pod is running: "
STATUS=$(kubectl get pod cache -n web -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$STATUS" == "Running" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (status: $STATUS)"
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
