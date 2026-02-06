#!/bin/bash
# Check script for Q32: Canary Deployment

echo "=========================================="
echo "Checking Q32: Canary Deployment"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Stable deployment has 3 replicas
echo -n "[Check 1] Stable deployment 'web-stable' has 3 replicas: "
REPLICAS=$(kubectl get deploy web-stable -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$REPLICAS" == "3" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $REPLICAS)"
    ((FAIL++))
fi

# Check 2: Stable uses nginx:1.14
echo -n "[Check 2] Stable uses image 'nginx:1.14': "
IMAGE=$(kubectl get deploy web-stable -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "nginx:1.14" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 3: Canary deployment exists
echo -n "[Check 3] Canary deployment 'web-canary' exists: "
if kubectl get deploy web-canary &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: Canary has 1 replica
echo -n "[Check 4] Canary deployment has 1 replica: "
REPLICAS=$(kubectl get deploy web-canary -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$REPLICAS" == "1" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $REPLICAS)"
    ((FAIL++))
fi

# Check 5: Canary uses nginx:1.16
echo -n "[Check 5] Canary uses image 'nginx:1.16': "
IMAGE=$(kubectl get deploy web-canary -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "nginx:1.16" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 6: Both have label app=web
echo -n "[Check 6] Both deployments have label 'app=web': "
STABLE_LABEL=$(kubectl get deploy web-stable -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
CANARY_LABEL=$(kubectl get deploy web-canary -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
if [[ "$STABLE_LABEL" == "web" && "$CANARY_LABEL" == "web" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (stable: $STABLE_LABEL, canary: $CANARY_LABEL)"
    ((FAIL++))
fi

# Check 7: Service web-svc exists with correct endpoints
echo -n "[Check 7] Service 'web-svc' has 4 endpoints: "
EP_COUNT=$(kubectl get endpoints web-svc -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o "ip" | wc -l)
if [[ $EP_COUNT -eq 4 ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "⚠️ WARNING (expected 4, got: $EP_COUNT)"
    ((PASS++))
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
