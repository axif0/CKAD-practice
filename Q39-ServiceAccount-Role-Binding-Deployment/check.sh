#!/bin/bash
# Check script for Q39: ServiceAccount Role Binding Deployment

echo "=========================================="
echo "Checking Q39: ServiceAccount Role Binding Deployment"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: ServiceAccount exists
echo -n "[Check 1] ServiceAccount 'scraper' exists in namespace 'cute-panda': "
if kubectl get sa scraper -n cute-panda &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: RoleBinding exists
echo -n "[Check 2] RoleBinding for 'scraper' exists: "
BINDINGS=$(kubectl get rolebindings -n cute-panda -o jsonpath='{.items[*].subjects[*].name}' 2>/dev/null)
if [[ "$BINDINGS" == *"scraper"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Deployment uses scraper ServiceAccount
echo -n "[Check 3] Deployment 'scraper' uses ServiceAccount 'scraper': "
SA=$(kubectl get deploy scraper -n cute-panda -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
if [[ "$SA" == "scraper" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SA)"
    ((FAIL++))
fi

# Check 4: Pods are running
echo -n "[Check 4] Deployment pods are running: "
READY=$(kubectl get deploy scraper -n cute-panda -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
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
