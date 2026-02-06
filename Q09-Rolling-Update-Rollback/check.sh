#!/bin/bash
# Check script for Q09: Rolling Update Rollback

echo "=========================================="
echo "Checking Q09: Rolling Update Rollback"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'app-v1' exists: "
if kubectl get deploy app-v1 &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Rollout history has at least 2 revisions
echo -n "[Check 2] Rollout history has multiple revisions: "
REVISIONS=$(kubectl rollout history deploy/app-v1 2>/dev/null | grep -c "^[0-9]")
if [[ $REVISIONS -ge 2 ]]; then
    echo "✅ PASS ($REVISIONS revisions)"
    ((PASS++))
else
    echo "❌ FAIL (only $REVISIONS revision(s))"
    ((FAIL++))
fi

# Check 3: Current image is nginx:1.20 (rolled back)
echo -n "[Check 3] Image rolled back to 'nginx:1.20': "
IMAGE=$(kubectl get deploy app-v1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "nginx:1.20" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (current image: $IMAGE)"
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
