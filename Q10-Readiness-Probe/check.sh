#!/bin/bash
# Check script for Q10: Readiness Probe

echo "=========================================="
echo "Checking Q10: Readiness Probe"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Deployment exists
echo -n "[Check 1] Deployment 'api-deploy' exists: "
if kubectl get deploy api-deploy &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Readiness probe exists with httpGet
echo -n "[Check 2] Readiness probe uses httpGet: "
PROBE_TYPE=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet}' 2>/dev/null)
if [[ -n "$PROBE_TYPE" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 3: Path is /ready
echo -n "[Check 3] Probe path is '/ready': "
PATH_VAL=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
if [[ "$PATH_VAL" == "/ready" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_VAL)"
    ((FAIL++))
fi

# Check 4: Port is 8080
echo -n "[Check 4] Probe port is 8080: "
PORT=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
if [[ "$PORT" == "8080" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PORT)"
    ((FAIL++))
fi

# Check 5: initialDelaySeconds is 5
echo -n "[Check 5] initialDelaySeconds is 5: "
DELAY=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
if [[ "$DELAY" == "5" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $DELAY)"
    ((FAIL++))
fi

# Check 6: periodSeconds is 10
echo -n "[Check 6] periodSeconds is 10: "
PERIOD=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
if [[ "$PERIOD" == "10" ]]; then
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
