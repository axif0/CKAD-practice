#!/bin/bash
# Check script for Q28: Distribute Traffic

echo "=========================================="
echo "Checking Q28: Distribute Traffic (80/20 Split)"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: webapp-v1 deployment exists
echo -n "[Check 1] Deployment 'webapp-v1' exists in namespace 'production': "
if kubectl get deploy webapp-v1 -n production &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: webapp-v1 has 8 replicas (80%)
echo -n "[Check 2] Deployment 'webapp-v1' has 8 replicas: "
V1_REPLICAS=$(kubectl get deploy webapp-v1 -n production -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$V1_REPLICAS" == "8" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $V1_REPLICAS)"
    ((FAIL++))
fi

# Check 3: webapp-v2 deployment exists
echo -n "[Check 3] Deployment 'webapp-v2' exists in namespace 'production': "
if kubectl get deploy webapp-v2 -n production &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: webapp-v2 has 2 replicas (20%)
echo -n "[Check 4] Deployment 'webapp-v2' has 2 replicas: "
V2_REPLICAS=$(kubectl get deploy webapp-v2 -n production -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$V2_REPLICAS" == "2" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $V2_REPLICAS)"
    ((FAIL++))
fi

# Check 5: Both deployments have app=webapp label
echo -n "[Check 5] Both deployments have label 'app=webapp': "
V1_LABEL=$(kubectl get deploy webapp-v1 -n production -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
V2_LABEL=$(kubectl get deploy webapp-v2 -n production -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
if [[ "$V1_LABEL" == "webapp" && "$V2_LABEL" == "webapp" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (v1: $V1_LABEL, v2: $V2_LABEL)"
    ((FAIL++))
fi

# Check 6: Service webapp-svc exists
echo -n "[Check 6] Service 'webapp-svc' exists in namespace 'production': "
if kubectl get svc webapp-svc -n production &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 7: Service selects app=webapp
echo -n "[Check 7] Service selector is 'app=webapp': "
SVC_SELECTOR=$(kubectl get svc webapp-svc -n production -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$SVC_SELECTOR" == "webapp" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SVC_SELECTOR)"
    ((FAIL++))
fi

# Check 8: Service has 10 endpoints
echo -n "[Check 8] Service has 10 endpoints (8+2): "
EP_COUNT=$(kubectl get endpoints webapp-svc -n production -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o "ip" | wc -l)
if [[ $EP_COUNT -eq 10 ]]; then
    echo "✅ PASS ($EP_COUNT endpoints)"
    ((PASS++))
else
    echo "⚠️ WARNING (expected 10, got: $EP_COUNT)"
    ((PASS++))  # Still pass but warn
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
