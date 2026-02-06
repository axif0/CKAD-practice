#!/bin/bash
# Check script for Q24: CronJob

echo "=========================================="
echo "Checking Q24: CronJob"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: CronJob exists
echo -n "[Check 1] CronJob 'log-cleaner' exists in namespace 'production': "
if kubectl get cronjob log-cleaner -n production &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Schedule is every 30 minutes
echo -n "[Check 2] Schedule is '*/30 * * * *': "
SCHEDULE=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ "$SCHEDULE" == "*/30 * * * *" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SCHEDULE)"
    ((FAIL++))
fi

# Check 3: Image is busybox
echo -n "[Check 3] Image is busybox: "
IMAGE=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == *"busybox"* ]]; then
    echo "✅ PASS ($IMAGE)"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 4: Container name is 'log'
echo -n "[Check 4] Container name is 'log': "
CONTAINER_NAME=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].name}' 2>/dev/null)
if [[ "$CONTAINER_NAME" == "log" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $CONTAINER_NAME)"
    ((FAIL++))
fi

# Check 5: completions is 2
echo -n "[Check 5] Completions is 2: "
COMPLETIONS=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.completions}' 2>/dev/null)
if [[ "$COMPLETIONS" == "2" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $COMPLETIONS)"
    ((FAIL++))
fi

# Check 6: backoffLimit is 3
echo -n "[Check 6] BackoffLimit is 3: "
BACKOFF=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.backoffLimit}' 2>/dev/null)
if [[ "$BACKOFF" == "3" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $BACKOFF)"
    ((FAIL++))
fi

# Check 7: activeDeadlineSeconds is 30
echo -n "[Check 7] activeDeadlineSeconds is 30: "
DEADLINE=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
if [[ "$DEADLINE" == "30" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DEADLINE)"
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
