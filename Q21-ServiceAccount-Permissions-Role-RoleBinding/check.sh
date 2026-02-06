#!/bin/bash
# Check script for Q21: ServiceAccount Permissions Role RoleBinding

echo "=========================================="
echo "Checking Q21: ServiceAccount Permissions Role RoleBinding"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: ServiceAccount exists
echo -n "[Check 1] ServiceAccount 'dev-sa' exists in namespace 'meta': "
if kubectl get sa dev-sa -n meta &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Role exists
echo -n "[Check 2] Role 'dev-deploy-role' or 'deployment-reader' exists in namespace 'meta': "
if kubectl get role dev-deploy-role -n meta &>/dev/null || kubectl get role deployment-reader -n meta &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Role has correct permissions for deployments
echo -n "[Check 3] Role has get,list,watch on deployments: "
ROLE_NAME="dev-deploy-role"
kubectl get role $ROLE_NAME -n meta &>/dev/null || ROLE_NAME="deployment-reader"
VERBS=$(kubectl get role $ROLE_NAME -n meta -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)
RESOURCES=$(kubectl get role $ROLE_NAME -n meta -o jsonpath='{.rules[0].resources[*]}' 2>/dev/null)
API_GROUP=$(kubectl get role $ROLE_NAME -n meta -o jsonpath='{.rules[0].apiGroups[*]}' 2>/dev/null)
if [[ "$VERBS" == *"get"* && "$VERBS" == *"list"* && "$VERBS" == *"watch"* && "$RESOURCES" == *"deployments"* ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (verbs: $VERBS, resources: $RESOURCES)"
    ((FAIL++))
fi

# Check 4: RoleBinding exists
echo -n "[Check 4] RoleBinding 'dev-deploy-rb' exists in namespace 'meta': "
if kubectl get rolebinding dev-deploy-rb -n meta &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 5: RoleBinding binds correct SA
echo -n "[Check 5] RoleBinding binds 'dev-sa': "
SA_NAME=$(kubectl get rolebinding dev-deploy-rb -n meta -o jsonpath='{.subjects[0].name}' 2>/dev/null)
if [[ "$SA_NAME" == "dev-sa" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SA_NAME)"
    ((FAIL++))
fi

# Check 6: Deployment uses correct ServiceAccount
echo -n "[Check 6] Deployment 'dev-deployment' uses 'dev-sa': "
SA=$(kubectl get deploy dev-deployment -n meta -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
if [[ "$SA" == "dev-sa" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SA)"
    ((FAIL++))
fi

# Check 7: ServiceAccount can list deployments
echo -n "[Check 7] ServiceAccount can list deployments: "
if kubectl auth can-i list deployments --as=system:serviceaccount:meta:dev-sa -n meta &>/dev/null; then
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
