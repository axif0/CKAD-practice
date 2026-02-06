#!/bin/bash
# Check script for Q30: Service Selector Fix

echo "=========================================="
echo "Checking Q30: Service Selector Fix"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Service exists
echo -n "[Check 1] Service 'store-svc' exists: "
if kubectl get svc store-svc &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Service has correct selector
echo -n "[Check 2] Service selector matches pod labels: "
SELECTOR=$(kubectl get svc store-svc -o jsonpath='{.spec.selector}' 2>/dev/null)
if [[ "$SELECTOR" == *"app"*"store"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (selector: $SELECTOR)"
    ((FAIL++))
fi

# Check 3: Service has endpoints
echo -n "[Check 3] Service has endpoints: "
EP=$(kubectl get endpoints store-svc -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
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
