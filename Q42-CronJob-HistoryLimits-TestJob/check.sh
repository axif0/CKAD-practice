#!/bin/bash
# Check script for Q42: CronJob HistoryLimits TestJob

echo "=========================================="
echo "Checking Q42: CronJob HistoryLimits TestJob"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: CronJob exists
echo -n "[Check 1] CronJob 'grep' exists: "
if kubectl get cronjob grep &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Schedule is every 30 minutes
echo -n "[Check 2] Schedule is '*/30 * * * *': "
SCHEDULE=$(kubectl get cronjob grep -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ "$SCHEDULE" == "*/30 * * * *" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SCHEDULE)"
    ((FAIL++))
fi

# Check 3: successfulJobsHistoryLimit is 96
echo -n "[Check 3] successfulJobsHistoryLimit is 96: "
SUCCESS_LIMIT=$(kubectl get cronjob grep -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
if [[ "$SUCCESS_LIMIT" == "96" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $SUCCESS_LIMIT)"
    ((FAIL++))
fi

# Check 4: failedJobsHistoryLimit is 192
echo -n "[Check 4] failedJobsHistoryLimit is 192: "
FAILED_LIMIT=$(kubectl get cronjob grep -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
if [[ "$FAILED_LIMIT" == "192" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $FAILED_LIMIT)"
    ((FAIL++))
fi

# Check 5: restartPolicy is Never
echo -n "[Check 5] restartPolicy is 'Never': "
RESTART=$(kubectl get cronjob grep -o jsonpath='{.spec.jobTemplate.spec.template.spec.restartPolicy}' 2>/dev/null)
if [[ "$RESTART" == "Never" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $RESTART)"
    ((FAIL++))
fi

# Check 6: activeDeadlineSeconds is 8
echo -n "[Check 6] activeDeadlineSeconds is 8: "
DEADLINE=$(kubectl get cronjob grep -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
if [[ "$DEADLINE" == "8" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DEADLINE)"
    ((FAIL++))
fi

# Check 7: Test job exists
echo -n "[Check 7] Test job 'grep-test' exists: "
if kubectl get job grep-test &>/dev/null; then
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
