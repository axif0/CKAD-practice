#!/bin/bash
# Check script for Q44: Readiness Probe Healthz

echo "=========================================="
echo "Checking Q44: Readiness Probe Healthz"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'app-deployment' exists in namespace 'prod': "
if kubectl get deploy app-deployment -n prod &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Readiness probe uses httpGet
echo -n "[Check 2] Readiness probe uses httpGet: "
PROBE=$(kubectl get deploy app-deployment -n prod -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet}' 2>/dev/null)
if [[ -n "$PROBE" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Path is /healthz
echo -n "[Check 3] Probe path is '/healthz': "
PATH_VAL=$(kubectl get deploy app-deployment -n prod -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
if [[ "$PATH_VAL" == "/healthz" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_VAL)"
    ((FAIL++))
fi

# Check 4: Port is 8081
echo -n "[Check 4] Probe port is 8081: "
PORT=$(kubectl get deploy app-deployment -n prod -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
if [[ "$PORT" == "8081" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PORT)"
    ((FAIL++))
fi

# Check 5: initialDelaySeconds is 6
echo -n "[Check 5] initialDelaySeconds is 6: "
DELAY=$(kubectl get deploy app-deployment -n prod -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
if [[ "$DELAY" == "6" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DELAY)"
    ((FAIL++))
fi

# Check 6: periodSeconds is 3
echo -n "[Check 6] periodSeconds is 3: "
PERIOD=$(kubectl get deploy app-deployment -n prod -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
if [[ "$PERIOD" == "3" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PERIOD)"
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
