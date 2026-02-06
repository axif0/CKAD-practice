#!/bin/bash
# Check script for Q29: ReadinessProbe

echo "=========================================="
echo "Checking Q29: ReadinessProbe"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment nginx exists
echo -n "[Check 1] Deployment 'nginx' exists: "
if kubectl get deploy nginx &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Readiness probe uses httpGet
echo -n "[Check 2] Readiness probe uses httpGet: "
PROBE=$(kubectl get deploy nginx -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet}' 2>/dev/null)
if [[ -n "$PROBE" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Path is /ready
echo -n "[Check 3] Probe path is '/ready': "
PATH_VAL=$(kubectl get deploy nginx -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
if [[ "$PATH_VAL" == "/ready" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_VAL)"
    ((FAIL++))
fi

# Check 4: Port is 80
echo -n "[Check 4] Probe port is 80: "
PORT=$(kubectl get deploy nginx -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
if [[ "$PORT" == "80" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PORT)"
    ((FAIL++))
fi

# Check 5: initialDelaySeconds is 5
echo -n "[Check 5] initialDelaySeconds is 5: "
DELAY=$(kubectl get deploy nginx -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
if [[ "$DELAY" == "5" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DELAY)"
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
