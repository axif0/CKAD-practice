#!/bin/bash
# Check script for Q35: Fix Deployment RBAC Error

echo "=========================================="
echo "Checking Q35: Fix Deployment RBAC Error"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'honeybee-deployment' exists in namespace 'gorilla': "
if kubectl get deploy honeybee-deployment -n gorilla &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Deployment uses honeybee-sa
echo -n "[Check 2] Deployment uses ServiceAccount 'honeybee-sa': "
SA=$(kubectl get deploy honeybee-deployment -n gorilla -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
if [[ "$SA" == "honeybee-sa" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SA)"
    ((FAIL++))
fi

# Check 3: Pod is running
echo -n "[Check 3] Pod is running: "
POD_STATUS=$(kubectl get pods -n gorilla -l app=honeybee -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" == "Running" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (status: $POD_STATUS)"
    ((FAIL++))
fi

# Check 4: No RBAC errors in logs
echo -n "[Check 4] No RBAC errors in logs: "
LOGS=$(kubectl logs -n gorilla -l app=honeybee --tail=10 2>/dev/null)
if [[ "$LOGS" != *"cannot list"* && "$LOGS" != *"forbidden"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (RBAC errors found)"
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
