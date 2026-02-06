#!/bin/bash
# Check script for Q20: SecurityContext

echo "=========================================="
echo "Checking Q20: SecurityContext"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'hotfix-deployment' exists in namespace 'quetzal': "
if kubectl get deploy hotfix-deployment -n quetzal &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: runAsUser is 30000
echo -n "[Check 2] Pod-level or container-level runAsUser is 30000: "
POD_RUN_AS=$(kubectl get deploy hotfix-deployment -n quetzal -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
CONTAINER_RUN_AS=$(kubectl get deploy hotfix-deployment -n quetzal -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
if [[ "$POD_RUN_AS" == "30000" || "$CONTAINER_RUN_AS" == "30000" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (pod: $POD_RUN_AS, container: $CONTAINER_RUN_AS)"
    ((FAIL++))
fi

# Check 3: allowPrivilegeEscalation is false
echo -n "[Check 3] allowPrivilegeEscalation is false: "
PRIV_ESC=$(kubectl get deploy hotfix-deployment -n quetzal -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
if [[ "$PRIV_ESC" == "false" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PRIV_ESC)"
    ((FAIL++))
fi

# Check 4: Pods are running
echo -n "[Check 4] Deployment pods are running: "
READY=$(kubectl get deploy hotfix-deployment -n quetzal -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ -n "$READY" && "$READY" -ge 1 ]]; then
    echo "✅ PASS ($READY ready)"
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
