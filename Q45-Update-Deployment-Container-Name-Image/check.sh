#!/bin/bash
# Check script for Q45: Update Deployment Container Name Image

echo "=========================================="
echo "Checking Q45: Update Deployment Container Name Image"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'busybox' exists in namespace 'rapid-goat': "
if kubectl get deploy busybox -n rapid-goat &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Container name changed to 'musl'
echo -n "[Check 2] Container name is 'musl': "
NAME=$(kubectl get deploy busybox -n rapid-goat -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
if [[ "$NAME" == "musl" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $NAME)"
    ((FAIL++))
fi

# Check 3: Container image changed to 'busybox:musl'
echo -n "[Check 3] Container image is 'busybox:musl': "
IMAGE=$(kubectl get deploy busybox -n rapid-goat -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "busybox:musl" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 4: Rollout is complete
echo -n "[Check 4] Rollout is complete: "
ROLLOUT_STATUS=$(kubectl rollout status deploy busybox -n rapid-goat --timeout=5s 2>/dev/null)
if [[ $? -eq 0 ]]; then
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
