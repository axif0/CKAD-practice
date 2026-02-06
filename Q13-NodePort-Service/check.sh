#!/bin/bash
# Check script for Q13: NodePort Service

echo "=========================================="
echo "Checking Q13: NodePort Service"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Service exists
echo -n "[Check 1] Service 'api-nodeport' exists: "
if kubectl get svc api-nodeport &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Service type is NodePort
echo -n "[Check 2] Service type is 'NodePort': "
TYPE=$(kubectl get svc api-nodeport -o jsonpath='{.spec.type}' 2>/dev/null)
if [[ "$TYPE" == "NodePort" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $TYPE)"
    ((FAIL++))
fi

# Check 3: Selector is correct
echo -n "[Check 3] Service selector is 'app=api': "
SELECTOR=$(kubectl get svc api-nodeport -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$SELECTOR" == "api" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: app=$SELECTOR)"
    ((FAIL++))
fi

# Check 4: Service port is 80
echo -n "[Check 4] Service port is 80: "
PORT=$(kubectl get svc api-nodeport -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [[ "$PORT" == "80" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PORT)"
    ((FAIL++))
fi

# Check 5: Target port is 9090
echo -n "[Check 5] Target port is 9090: "
TARGET_PORT=$(kubectl get svc api-nodeport -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
if [[ "$TARGET_PORT" == "9090" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $TARGET_PORT)"
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
