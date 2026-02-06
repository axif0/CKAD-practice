#!/bin/bash
# Check script for Q19: Docker Image

echo "=========================================="
echo "Checking Q19: Docker Image"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Image exists
echo -n "[Check 1] Image 'devmaq:3.0' exists: "
if podman images 2>/dev/null | grep -q "devmaq.*3.0" || docker images 2>/dev/null | grep -q "devmaq.*3.0"; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Tarball exists
echo -n "[Check 2] Tarball exists at '~/human-stork/devmac-3.0.tar': "
if [[ -f ~/human-stork/devmac-3.0.tar ]]; then
    echo "✅ PASS"
    ((PASS++))
    
    # Check 3: Tarball is not empty
    echo -n "[Check 3] Tarball is not empty: "
    SIZE=$(stat -c%s ~/human-stork/devmac-3.0.tar 2>/dev/null)
    if [[ $SIZE -gt 0 ]]; then
        echo "✅ PASS (size: $SIZE bytes)"
        ((PASS++))
    else
        echo "❌ FAIL (empty file)"
        ((FAIL++))
    fi
else
    echo "❌ FAIL"
    ((FAIL++))
    echo "[Check 3] Skipped (tarball not found)"
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
