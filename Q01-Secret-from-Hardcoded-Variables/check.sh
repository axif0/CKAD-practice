#!/bin/bash
# Check script for Q01: Secret from Hardcoded Variables

echo "=========================================="
echo "Checking Q01: Secret from Hardcoded Variables"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Secret exists
echo -n "[Check 1] Secret 'db-credentials' exists: "
if kubectl get secret db-credentials -n default &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Secret contains DB_USER
echo -n "[Check 2] Secret contains DB_USER=admin: "
DB_USER=$(kubectl get secret db-credentials -n default -o jsonpath='{.data.DB_USER}' 2>/dev/null | base64 -d 2>/dev/null)
if [[ "$DB_USER" == "admin" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DB_USER)"
    ((FAIL++))
fi

# Check 3: Secret contains DB_PASS
echo -n "[Check 3] Secret contains DB_PASS=Secret123!: "
DB_PASS=$(kubectl get secret db-credentials -n default -o jsonpath='{.data.DB_PASS}' 2>/dev/null | base64 -d 2>/dev/null)
if [[ "$DB_PASS" == "Secret123!" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DB_PASS)"
    ((FAIL++))
fi

# Check 4: Deployment uses secretKeyRef
echo -n "[Check 4] Deployment uses secretKeyRef: "
if kubectl get deploy api-server -n default -o yaml 2>/dev/null | grep -q "secretKeyRef"; then
    echo "✅ PASS"
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
