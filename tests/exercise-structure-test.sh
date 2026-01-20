#!/bin/bash
# Property Test: Exercise Structure Validation
# Validates: Requirements 1.1, 1.2, 1.3, 1.4
#
# Property 1: Exercise Structure Validation
# For any exercise markdown file in the exercises directory, the file SHALL have:
# - Questions/instructions appearing before the solution section
# - A navigation link at the top pointing to a valid solution anchor
# - The solution section clearly marked at the end of the file

set -e

EXERCISES_DIR="exercises"
FAILED=0
PASSED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "Property Test: Exercise Structure Validation"
echo "Validates: Requirements 1.1, 1.2, 1.3, 1.4"
echo "=============================================="
echo ""

# Function to check if a file has the required structure
check_exercise_structure() {
    local file="$1"
    local errors=""
    
    # Check 1: Quick Navigation section exists at the top
    if ! grep -q "Quick Navigation:" "$file"; then
        errors="${errors}\n  - Missing 'Quick Navigation:' section"
    fi
    
    # Check 2: Navigation link to Solution exists
    if ! grep -q "\[Solution\](#solution)" "$file"; then
        errors="${errors}\n  - Missing navigation link to Solution section"
    fi
    
    # Check 3: Navigation link to Instructions exists
    if ! grep -q "\[Instructions\](#instructions)" "$file"; then
        errors="${errors}\n  - Missing navigation link to Instructions section"
    fi
    
    # Check 4: Navigation link to Hints exists
    if ! grep -q "\[Hints\](#hints)" "$file"; then
        errors="${errors}\n  - Missing navigation link to Hints section"
    fi
    
    # Check 5: Solution section exists
    if ! grep -q "^## Solution" "$file"; then
        errors="${errors}\n  - Missing '## Solution' section"
    fi
    
    # Check 6: Instructions section exists
    if ! grep -q "^## Instructions" "$file"; then
        errors="${errors}\n  - Missing '## Instructions' section"
    fi
    
    # Check 7: Hints section exists
    if ! grep -q "^## Hints" "$file"; then
        errors="${errors}\n  - Missing '## Hints' section"
    fi
    
    # Check 8: Horizontal rule before Solution section
    if ! grep -q "^---$" "$file"; then
        errors="${errors}\n  - Missing horizontal rule (---) separator before Solution"
    fi
    
    # Check 9: Instructions appear before Solution
    local instructions_line=$(grep -n "^## Instructions" "$file" | head -1 | cut -d: -f1)
    local solution_line=$(grep -n "^## Solution" "$file" | head -1 | cut -d: -f1)
    
    if [ -n "$instructions_line" ] && [ -n "$solution_line" ]; then
        if [ "$instructions_line" -gt "$solution_line" ]; then
            errors="${errors}\n  - Instructions section appears after Solution section"
        fi
    fi
    
    # Check 10: Solution is in a collapsible details section
    if ! grep -q "<details>" "$file"; then
        errors="${errors}\n  - Solution should be in a collapsible <details> section"
    fi
    
    if [ -n "$errors" ]; then
        echo -e "${RED}FAIL${NC}: $file"
        echo -e "$errors"
        return 1
    else
        echo -e "${GREEN}PASS${NC}: $file"
        return 0
    fi
}

# Find all exercise markdown files
echo "Scanning exercise files..."
echo ""

for file in $(find "$EXERCISES_DIR" -name "*.md" -type f); do
    TOTAL=$((TOTAL + 1))
    
    if check_exercise_structure "$file"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=============================================="
echo "Test Results Summary"
echo "=============================================="
echo "Total files tested: $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Property test FAILED${NC}"
    echo "Some exercise files do not conform to the required structure."
    exit 1
else
    echo -e "${GREEN}Property test PASSED${NC}"
    echo "All exercise files conform to the required structure."
    exit 0
fi
