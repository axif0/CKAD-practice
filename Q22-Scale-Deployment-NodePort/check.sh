#!/bin/bash
# Check script for Q22: Scale Deployment NodePort

echo "=========================================="
echo "Checking Q22: Scale Deployment NodePort"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment has 4 replicas
echo -n "[Check 1] Deployment 'nov2025-deployment' has 4 replicas: "
REPLICAS=$(kubectl get deploy nov2025-deployment -n nov2025 -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$REPLICAS" == "4" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $REPLICAS)"
    ((FAIL++))
fi

# Check 2: Pod template has func=webFrontend label
echo -n "[Check 2] Pod template has label 'func=webFrontend': "
LABEL=$(kubectl get deploy nov2025-deployment -n nov2025 -o jsonpath='{.spec.template.metadata.labels.func}' 2>/dev/null)
if [[ "$LABEL" == "webFrontend" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
    ((FAIL++))
fi

# Check 3: Service 'berry' exists
echo -n "[Check 3] Service 'berry' exists in namespace 'nov2025': "
if kubectl get svc berry -n nov2025 &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: Service type is NodePort
echo -n "[Check 4] Service type is 'NodePort': "
TYPE=$(kubectl get svc berry -n nov2025 -o jsonpath='{.spec.type}' 2>/dev/null)
if [[ "$TYPE" == "NodePort" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $TYPE)"
    ((FAIL++))
fi

# Check 5: Service port is 8080
echo -n "[Check 5] Service port is 8080: "
PORT=$(kubectl get svc berry -n nov2025 -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [[ "$PORT" == "8080" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PORT)"
    ((FAIL++))
fi

# Check 6: Service has correct selector
echo -n "[Check 6] Service selector matches pod labels: "
SELECTOR=$(kubectl get svc berry -n nov2025 -o jsonpath='{.spec.selector.func}' 2>/dev/null)
if [[ "$SELECTOR" == "webFrontend" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: func=$SELECTOR)"
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
