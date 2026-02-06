#!/bin/bash
# Check script for Q03: ServiceAccount Role RoleBinding

echo "=========================================="
echo "Checking Q03: ServiceAccount Role RoleBinding"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: ServiceAccount exists
echo -n "[Check 1] ServiceAccount 'log-sa' exists in namespace 'audit': "
if kubectl get sa log-sa -n audit &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Role exists
echo -n "[Check 2] Role 'log-role' exists in namespace 'audit': "
if kubectl get role log-role -n audit &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Role has correct permissions
echo -n "[Check 3] Role has get,list,watch on pods: "
VERBS=$(kubectl get role log-role -n audit -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)
RESOURCES=$(kubectl get role log-role -n audit -o jsonpath='{.rules[0].resources[*]}' 2>/dev/null)
if [[ "$VERBS" == *"get"* && "$VERBS" == *"list"* && "$VERBS" == *"watch"* && "$RESOURCES" == *"pods"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (verbs: $VERBS, resources: $RESOURCES)"
    ((FAIL++))
fi

# Check 4: RoleBinding exists
echo -n "[Check 4] RoleBinding 'log-rb' exists in namespace 'audit': "
if kubectl get rolebinding log-rb -n audit &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 5: RoleBinding binds correct role
echo -n "[Check 5] RoleBinding references 'log-role': "
ROLE_REF=$(kubectl get rolebinding log-rb -n audit -o jsonpath='{.roleRef.name}' 2>/dev/null)
if [[ "$ROLE_REF" == "log-role" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $ROLE_REF)"
    ((FAIL++))
fi

# Check 6: Pod uses correct ServiceAccount
echo -n "[Check 6] Pod 'log-collector' uses 'log-sa': "
SA_NAME=$(kubectl get pod log-collector -n audit -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [[ "$SA_NAME" == "log-sa" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SA_NAME)"
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
