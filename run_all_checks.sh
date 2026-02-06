#!/bin/bash
# Master script to run all check.sh scripts

BASE_DIR="/home/asif/Downloads/CKAD-2025-normalized"
LOG_FILE="$BASE_DIR/check_results.log"

echo "=========================================="
echo "CKAD Verification Suite"
echo "Running checks for all questions..."
echo "=========================================="
echo "Detailed logs will be saved to $LOG_FILE"
echo "" > "$LOG_FILE"

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

# Find all Q* directories
DIRS=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Q*" | sort)

for dir in $DIRS; do
    QUESTION=$(basename "$dir1")
    CHECK_SCRIPT="$dir/check.sh"
    
    if [[ -f "$CHECK_SCRIPT" ]]; then
        echo -n "Checking $QUESTION... "
        chmod +x "$CHECK_SCRIPT"
        if "$CHECK_SCRIPT" >> "$LOG_FILE" 2>&1; then
            echo "✅ PASS"
            ((TOTAL_PASSED++))
        else
            echo "❌ FAIL"
            ((TOTAL_FAILED++))
        fi
    else
        echo "⚠️  SKIP (No check.sh found for $QUESTION)"
        ((TOTAL_SKIPPED++))
    fi
done

echo ""
echo "=========================================="
echo "Summary:"
echo "✅ Passed:  $TOTAL_PASSED"
echo "❌ Failed:  $TOTAL_FAILED"
echo "⚠️  Skipped: $TOTAL_SKIPPED"
echo "=========================================="
echo "See $LOG_FILE for details."
