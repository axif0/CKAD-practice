#!/bin/bash
# Check script for Q26: Pod Logs Metrics Troubleshooting

echo "=========================================="
echo "Checking Q26: Pod Logs Metrics Troubleshooting"
echo "=========================================="

PASS=0
FAIL=0

# Check 1: Pod 'winter' exists or was deployed
echo -n "[Check 1] Pod 'winter' was deployed: "
if kubectl get pod winter &>/dev/null; then
    echo "✅ PASS"
    ((PASS++))
else
    echo "❌ FAIL"
    ((FAIL++))
fi

# Check 2: Log output file exists and has content
echo -n "[Check 2] Log output file exists at '/opt/ckadnov2025/log_Output.txt': "
if [[ -f /opt/ckadnov2025/log_Output.txt ]]; then
    SIZE=$(stat -c%s /opt/ckadnov2025/log_Output.txt 2>/dev/null)
    if [[ $SIZE -gt 0 ]]; then
        echo "✅ PASS (size: $SIZE bytes)"
        ((PASS++))
    else
        echo "❌ FAIL (file is empty)"
        ((FAIL++))
    fi
else
    echo "❌ FAIL (file not found)"
    ((FAIL++))
fi

# Check 3: Pod.txt file exists
echo -n "[Check 3] Pod file exists at '/opt/ckadnov2025/pod.txt': "
if [[ -f /opt/ckadnov2025/pod.txt ]]; then
    SIZE=$(stat -c%s /opt/ckadnov2025/pod.txt 2>/dev/null)
    if [[ $SIZE -gt 0 ]]; then
        echo "✅ PASS (size: $SIZE bytes)"
        ((PASS++))
        
        # Check 4: Pod.txt contains a pod name
        echo -n "[Check 4] Pod.txt contains a valid pod name: "
        POD_NAME=$(cat /opt/ckadnov2025/pod.txt 2>/dev/null | tr -d ' \n')
        if [[ -n "$POD_NAME" ]]; then
            echo "✅ PASS ($POD_NAME)"
            ((PASS++))
        else
            echo "❌ FAIL (empty content)"
            ((FAIL++))
        fi
    else
        echo "❌ FAIL (file is empty)"
        ((FAIL++))
        echo "[Check 4] Skipped"
        ((FAIL++))
    fi
else
    echo "❌ FAIL (file not found)"
    ((FAIL++))
    echo "[Check 4] Skipped"
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
