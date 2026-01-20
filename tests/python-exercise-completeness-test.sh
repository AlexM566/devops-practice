#!/bin/bash
# Property Test: Python Exercise Completeness
# Validates: Requirements 2.6, 2.7
#
# Property 2: Python Exercise Completeness
# For any Python exercise markdown file, the file SHALL contain:
# - A coding challenge section with clear requirements
# - Test cases or verification commands

set -e

PYTHON_EXERCISES_DIR="exercises/python"
FAILED=0
PASSED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "Property Test: Python Exercise Completeness"
echo "Validates: Requirements 2.6, 2.7"
echo "=============================================="
echo ""

# Function to check if a Python exercise has required sections
check_python_exercise() {
    local file="$1"
    local errors=""
    
    # Check 1: Has Instructions/Challenge section
    if ! grep -q "^## Instructions" "$file"; then
        errors="${errors}\n  - Missing '## Instructions' section (coding challenge)"
    fi
    
    # Check 2: Has clear requirements (numbered list or bullet points in Instructions)
    local instructions_section=$(sed -n '/^## Instructions/,/^## /p' "$file" | head -50)
    if ! echo "$instructions_section" | grep -qE "^[0-9]+\.|^\*|^-"; then
        errors="${errors}\n  - Instructions section should have numbered steps or bullet points"
    fi
    
    # Check 3: Has Test Cases section
    if ! grep -q "^## Test Cases" "$file"; then
        errors="${errors}\n  - Missing '## Test Cases' section"
    fi
    
    # Check 4: Has test code block (Python test file)
    if ! grep -q "test_" "$file"; then
        errors="${errors}\n  - Missing test functions (test_*)"
    fi
    
    # Check 5: Has Verification Steps section
    if ! grep -q "^## Verification Steps" "$file"; then
        errors="${errors}\n  - Missing '## Verification Steps' section"
    fi
    
    # Check 6: Has Expected Output section
    if ! grep -q "^## Expected Output" "$file"; then
        errors="${errors}\n  - Missing '## Expected Output' section"
    fi
    
    # Check 7: Has Python code blocks
    if ! grep -q '```python' "$file"; then
        errors="${errors}\n  - Missing Python code blocks"
    fi
    
    # Check 8: Has Solution section with complete code
    if ! grep -q "^## Solution" "$file"; then
        errors="${errors}\n  - Missing '## Solution' section"
    fi
    
    # Check 9: Solution contains Python code
    local solution_section=$(sed -n '/^## Solution/,/^## /p' "$file")
    if ! echo "$solution_section" | grep -q '```python'; then
        errors="${errors}\n  - Solution section should contain Python code"
    fi
    
    # Check 10: Has Objective section explaining what will be learned
    if ! grep -q "^## Objective" "$file"; then
        errors="${errors}\n  - Missing '## Objective' section"
    fi
    
    # Check 11: Has difficulty and time estimate
    if ! grep -q "Difficulty:" "$file"; then
        errors="${errors}\n  - Missing 'Difficulty:' metadata"
    fi
    
    if ! grep -q "Estimated Time:" "$file"; then
        errors="${errors}\n  - Missing 'Estimated Time:' metadata"
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

# Check if Python exercises directory exists
if [ ! -d "$PYTHON_EXERCISES_DIR" ]; then
    echo -e "${RED}ERROR${NC}: Python exercises directory not found: $PYTHON_EXERCISES_DIR"
    exit 1
fi

# Find all Python exercise markdown files
echo "Scanning Python exercise files..."
echo ""

for file in $(find "$PYTHON_EXERCISES_DIR" -name "*.md" -type f); do
    # Skip non-exercise files (like README)
    if [[ "$file" == *"README"* ]]; then
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    
    if check_python_exercise "$file"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=============================================="
echo "Test Results Summary"
echo "=============================================="
echo "Total Python exercises tested: $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

# Check minimum exercise count (Requirement 2.5: at least 10 exercises)
MIN_EXERCISES=10
if [ $TOTAL -lt $MIN_EXERCISES ]; then
    echo -e "${YELLOW}WARNING${NC}: Only $TOTAL Python exercises found."
    echo "Requirement 2.5 specifies at least $MIN_EXERCISES exercises."
    echo ""
fi

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Property test FAILED${NC}"
    echo "Some Python exercise files do not meet completeness requirements."
    exit 1
else
    echo -e "${GREEN}Property test PASSED${NC}"
    echo "All Python exercise files contain required challenge and test sections."
    exit 0
fi
