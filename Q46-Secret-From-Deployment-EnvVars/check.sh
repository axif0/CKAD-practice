#!/bin/bash
# Check script for Q46: Secret From Deployment EnvVars

echo "=========================================="
echo "Checking Q46: Secret From Deployment EnvVars"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Secret exists
echo -n "[Check 1] Secret 'postgres' exists in namespace 'relaxed-shark': "
if kubectl get secret postgres -n relaxed-shark &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Secret has correct keys
echo -n "[Check 2] Secret has keys username, database, password: "
KEYS=$(kubectl get secret postgres -n relaxed-shark -o jsonpath='{.data}' 2>/dev/null)
if [[ "$KEYS" == *"username"* && "$KEYS" == *"database"* && "$KEYS" == *"password"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (keys missing)"
    ((FAIL++))
fi

# Check 3: Deployment uses Secret for env vars
echo -n "[Check 3] Deployment uses Secret for environment variables: "
ENV_FROM=$(kubectl get deploy postgres -n relaxed-shark -o jsonpath='{.spec.template.spec.containers[0].env[*].valueFrom.secretKeyRef.name}' 2>/dev/null)
if [[ "$ENV_FROM" == *"postgres"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (not using secretKeyRef)"
    ((FAIL++))
fi

# Check 4: Pods are running
echo -n "[Check 4] Deployment pods are running: "
READY=$(kubectl get deploy postgres -n relaxed-shark -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ -n "$READY" && "$READY" -ge 1 ]]; then
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
