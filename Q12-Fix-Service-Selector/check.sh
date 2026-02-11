#!/bin/bash
# Check script for Q12: Fix Service Selector

echo "=========================================="
echo "Checking Q12: Fix Service Selector"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Service exists
echo -n "[Check 1] Service 'web-svc' exists: "
if kubectl get svc web-svc &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Service selector is correct
echo -n "[Check 2] Service selector is 'app=web-app': "
SELECTOR=$(kubectl get svc web-svc -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$SELECTOR" == "web-app" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: app=$SELECTOR)"
    ((FAIL++))
fi

# Check 3: Service has endpoints
echo -n "[Check 3] Service has endpoints: "
EP=$(kubectl get endpoints web-svc -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
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
