#!/bin/bash
# Check script for Q40: Scale Labels NodePort Service

echo "=========================================="
echo "Checking Q40: Scale Labels NodePort Service"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment has 2 replicas
echo -n "[Check 1] Deployment 'nginx-deployment' has 2 replicas: "
REPLICAS=$(kubectl get deploy nginx-deployment -n prod -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [[ "$REPLICAS" == "2" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $REPLICAS)"
    ((FAIL++))
fi

# Check 2: Pod template has role=webFrontEnd label
echo -n "[Check 2] Pod template has label 'role=webFrontEnd': "
LABEL=$(kubectl get deploy nginx-deployment -n prod -o jsonpath='{.spec.template.metadata.labels.role}' 2>/dev/null)
if [[ "$LABEL" == "webFrontEnd" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $LABEL)"
    ((FAIL++))
fi

# Check 3: Service 'rover' exists
echo -n "[Check 3] Service 'rover' exists in namespace 'prod': "
if kubectl get svc rover -n prod &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 4: Service type is NodePort
echo -n "[Check 4] Service type is 'NodePort': "
TYPE=$(kubectl get svc rover -n prod -o jsonpath='{.spec.type}' 2>/dev/null)
if [[ "$TYPE" == "NodePort" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $TYPE)"
    ((FAIL++))
fi

# Check 5: Service has endpoints
echo -n "[Check 5] Service has endpoints: "
EP=$(kubectl get endpoints rover -n prod -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
if [[ -n "$EP" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (no endpoints)"
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
