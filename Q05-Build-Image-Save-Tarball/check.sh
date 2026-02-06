#!/bin/bash
# Check script for Q05: Build Image Save Tarball

echo "=========================================="
echo "Checking Q05: Build Image Save Tarball"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Image exists
echo -n "[Check 1] Image 'my-app:1.0' exists: "
if podman images 2>/dev/null | grep -q "my-app.*1.0" || docker images 2>/dev/null | grep -q "my-app.*1.0"; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Tarball exists
echo -n "[Check 2] Tarball exists at '/root/my-app.tar': "
if [[ -f /root/my-app.tar ]]; then
    echo "✅ PASS"
    ((PASS++))
    
    # Check 3: Tarball is not empty
    echo -n "[Check 3] Tarball is not empty: "
    SIZE=$(stat -c%s /root/my-app.tar 2>/dev/null)
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
