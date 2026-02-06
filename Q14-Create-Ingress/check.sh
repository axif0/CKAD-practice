#!/bin/bash
# Check script for Q14: Create Ingress

echo "=========================================="
echo "Checking Q14: Create Ingress"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Ingress exists
echo -n "[Check 1] Ingress 'web-ingress' exists: "
if kubectl get ingress web-ingress &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Host is correct
echo -n "[Check 2] Host is 'web.example.com': "
HOST=$(kubectl get ingress web-ingress -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [[ "$HOST" == "web.example.com" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $HOST)"
    ((FAIL++))
fi

# Check 3: Path is /
echo -n "[Check 3] Path is '/': "
PATH_VAL=$(kubectl get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
if [[ "$PATH_VAL" == "/" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_VAL)"
    ((FAIL++))
fi

# Check 4: PathType is Prefix
echo -n "[Check 4] PathType is 'Prefix': "
PATH_TYPE=$(kubectl get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
if [[ "$PATH_TYPE" == "Prefix" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $PATH_TYPE)"
    ((FAIL++))
fi

# Check 5: Backend service is web-svc
echo -n "[Check 5] Backend service is 'web-svc': "
BACKEND=$(kubectl get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [[ "$BACKEND" == "web-svc" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $BACKEND)"
    ((FAIL++))
fi

# Check 6: Backend port is 8080
echo -n "[Check 6] Backend port is 8080: "
BACKEND_PORT=$(kubectl get ingress web-ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
if [[ "$BACKEND_PORT" == "8080" ]]; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL (got: $BACKEND_PORT)"
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
