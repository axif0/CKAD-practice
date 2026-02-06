#!/bin/bash
# Check script for Q27: Kubernetes API Deprecation

echo "=========================================="
echo "Checking Q27: Kubernetes API Deprecation"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: HPA exists
echo -n "[Check 1] HPA 'web-hpa' exists: "
if kubectl get hpa web-hpa &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: HPA uses correct apiVersion
echo -n "[Check 2] YAML uses apiVersion 'autoscaling/v2': "
if grep -q "apiVersion: autoscaling/v2" ~/ckad-hpa.yaml 2>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: HPA targets web-app deployment
echo -n "[Check 3] HPA targets deployment 'web-app': "
TARGET=$(kubectl get hpa web-hpa -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
if [[ "$TARGET" == "web-app" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $TARGET)"
    ((FAIL++))
fi

# Check 4: HPA has correct min/max replicas
echo -n "[Check 4] HPA has minReplicas=1 and maxReplicas=5: "
MIN=$(kubectl get hpa web-hpa -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
MAX=$(kubectl get hpa web-hpa -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
if [[ "$MIN" == "1" && "$MAX" == "5" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (min: $MIN, max: $MAX)"
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
