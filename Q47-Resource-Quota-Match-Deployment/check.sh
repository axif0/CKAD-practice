#!/bin/bash
# Check script for Q47: Resource Quota Match Deployment

echo "=========================================="
echo "Checking Q47: Resource Quota Match Deployment"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment resources updated correctly
echo -n "[Check 1] Deployment has correct requests/limits: "
REQ_CPU=$(kubectl get deploy nginx-resources -n resource-test -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
REQ_MEM=$(kubectl get deploy nginx-resources -n resource-test -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
LIM_CPU=$(kubectl get deploy nginx-resources -n resource-test -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
LIM_MEM=$(kubectl get deploy nginx-resources -n resource-test -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)

if [[ "$REQ_CPU" == "100m" && "$REQ_MEM" == "128Mi" && "$LIM_CPU" == "200m" && "$LIM_MEM" == "256Mi" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (Req: $REQ_CPU/$REQ_MEM, Lim: $LIM_CPU/$LIM_MEM)"
    ((FAIL++))
fi

# Check 2: Calculate total expected limits for Quota
REPLICAS=$(kubectl get deploy nginx-resources -n resource-test -o jsonpath='{.spec.replicas}' 2>/dev/null)
EXPECTED_REQ_CPU_M=$(echo "$REPLICAS * 100" | bc)
EXPECTED_REQ_MEM_MI=$(echo "$REPLICAS * 128" | bc)
EXPECTED_LIM_CPU_M=$(echo "$REPLICAS * 200" | bc)
EXPECTED_LIM_MEM_MI=$(echo "$REPLICAS * 256" | bc)

# Check 3: ResourceQuota updated correctly
echo -n "[Check 3] ResourceQuota matches total deployment resources: "
# Note: Values from quota might be formatted differently (e.g. 200m vs 0.2), this is a simplified check
QUOTA_REQ_CPU=$(kubectl get resourcequota compute-quota -n resource-test -o jsonpath='{.spec.hard.requests\.cpu}' 2>/dev/null)
QUOTA_REQ_MEM=$(kubectl get resourcequota compute-quota -n resource-test -o jsonpath='{.spec.hard.requests\.memory}' 2>/dev/null)
QUOTA_LIM_CPU=$(kubectl get resourcequota compute-quota -n resource-test -o jsonpath='{.spec.hard.limits\.cpu}' 2>/dev/null)
QUOTA_LIM_MEM=$(kubectl get resourcequota compute-quota -n resource-test -o jsonpath='{.spec.hard.limits\.memory}' 2>/dev/null)

if [[ "$QUOTA_REQ_CPU" == "${EXPECTED_REQ_CPU_M}m" && "$QUOTA_REQ_MEM" == "${EXPECTED_REQ_MEM_MI}Mi" && "$QUOTA_LIM_CPU" == "${EXPECTED_LIM_CPU_M}m" && "$QUOTA_LIM_MEM" == "${EXPECTED_LIM_MEM_MI}Mi" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (Quota: $QUOTA_REQ_CPU/$QUOTA_REQ_MEM, $QUOTA_LIM_CPU/$QUOTA_LIM_MEM, Expected: ${EXPECTED_REQ_CPU_M}m/${EXPECTED_REQ_MEM_MI}Mi, ${EXPECTED_LIM_CPU_M}m/${EXPECTED_LIM_MEM_MI}Mi)"
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
