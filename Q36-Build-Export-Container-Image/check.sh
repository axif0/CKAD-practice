#!/bin/bash
# Check script for Q36: Build Export Container Image

echo "=========================================="
echo "Checking Q36: Build Export Container Image"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Image exists
echo -n "[Check 1] Image 'macaque:1.2' exists: "
if podman images 2>/dev/null | grep -q "macaque.*1.2" || docker images 2>/dev/null | grep -q "macaque.*1.2"; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Tarball exists
echo -n "[Check 2] Tarball exists at '/home/candidate/macaque-1.2.tar': "
if [[ -f /home/candidate/macaque-1.2.tar ]]; then
    echo "✅ PASS"
    ((PASS++))
    
    # Check 3: Tarball is not empty
    echo -n "[Check 3] Tarball is not empty: "
    SIZE=$(stat -c%s /home/candidate/macaque-1.2.tar 2>/dev/null)
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
