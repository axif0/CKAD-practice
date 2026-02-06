#!/bin/bash
# Check script for Q02: CronJob with History Limits

echo "=========================================="
echo "Checking Q02: CronJob with History Limits"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: CronJob exists
echo -n "[Check 1] CronJob 'backup-job' exists: "
if kubectl get cronjob backup-job -n default &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Schedule is correct
echo -n "[Check 2] Schedule is '*/30 * * * *': "
SCHEDULE=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ "$SCHEDULE" == "*/30 * * * *" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SCHEDULE)"
    ((FAIL++))
fi

# Check 3: Image is busybox:latest
echo -n "[Check 3] Image is 'busybox:latest': "
IMAGE=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "busybox:latest" || "$IMAGE" == "busybox" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $IMAGE)"
    ((FAIL++))
fi

# Check 4: successfulJobsHistoryLimit is 3
echo -n "[Check 4] successfulJobsHistoryLimit is 3: "
SUCCESS_LIMIT=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
if [[ "$SUCCESS_LIMIT" == "3" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SUCCESS_LIMIT)"
    ((FAIL++))
fi

# Check 5: failedJobsHistoryLimit is 2
echo -n "[Check 5] failedJobsHistoryLimit is 2: "
FAILED_LIMIT=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
if [[ "$FAILED_LIMIT" == "2" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $FAILED_LIMIT)"
    ((FAIL++))
fi

# Check 6: activeDeadlineSeconds is 300
echo -n "[Check 6] activeDeadlineSeconds is 300: "
DEADLINE=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
if [[ "$DEADLINE" == "300" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DEADLINE)"
    ((FAIL++))
fi

# Check 7: restartPolicy is Never
echo -n "[Check 7] restartPolicy is 'Never': "
RESTART=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.jobTemplate.spec.template.spec.restartPolicy}' 2>/dev/null)
if [[ "$RESTART" == "Never" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $RESTART)"
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
