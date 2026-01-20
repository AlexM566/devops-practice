#!/bin/bash
# Property Test: CI/CD Exercise YAML Content
# Validates: Requirements 3.3
#
# Property 3: CI/CD Exercise YAML Content
# For any CI/CD exercise markdown file, the file SHALL contain:
# - At least one YAML code block with pipeline configuration syntax

set -e

CICD_EXERCISES_DIR="exercises/cicd"
FAILED=0
PASSED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "Property Test: CI/CD Exercise YAML Content"
echo "Validates: Requirements 3.3"
echo "=============================================="
echo ""

# Function to check if a CI/CD exercise has required YAML content
check_cicd_exercise() {
    local file="$1"
    local errors=""
    
    # Check 1: Has YAML code blocks
    if ! grep -q '```yaml' "$file"; then
        errors="${errors}\n  - Missing YAML code blocks"
    fi
    
    # Check 2: YAML contains pipeline-related keywords
    # For GitHub Actions: jobs, steps, run, on, name
    # For Azure Pipelines: stages, jobs, steps, script, trigger
    local has_pipeline_syntax=0
    
    # Check for GitHub Actions syntax
    if grep -q "jobs:" "$file" && grep -q "steps:" "$file"; then
        has_pipeline_syntax=1
    fi
    
    # Check for Azure Pipelines syntax
    if grep -q "stages:" "$file" || grep -q "trigger:" "$file"; then
        has_pipeline_syntax=1
    fi
    
    if [ $has_pipeline_syntax -eq 0 ]; then
        errors="${errors}\n  - YAML blocks should contain pipeline syntax like jobs, steps, stages, or trigger"
    fi
    
    # Check 3: Has Instructions section
    if ! grep -q "^## Instructions" "$file"; then
        errors="${errors}\n  - Missing '## Instructions' section"
    fi
    
    # Check 4: Has Solution section with YAML
    if ! grep -q "^## Solution" "$file"; then
        errors="${errors}\n  - Missing '## Solution' section"
    fi
    
    # Check 5: Solution contains YAML code
    local solution_section=$(sed -n '/^## Solution/,/^## /p' "$file")
    if ! echo "$solution_section" | grep -q '```yaml'; then
        errors="${errors}\n  - Solution section should contain YAML code"
    fi
    
    # Check 6: Has Verification Steps section
    if ! grep -q "^## Verification Steps" "$file"; then
        errors="${errors}\n  - Missing '## Verification Steps' section"
    fi
    
    # Check 7: Has Hints section
    if ! grep -q "^## Hints" "$file"; then
        errors="${errors}\n  - Missing '## Hints' section"
    fi
    
    # Check 8: Has Objective section
    if ! grep -q "^## Objective" "$file"; then
        errors="${errors}\n  - Missing '## Objective' section"
    fi
    
    # Check 9: Has difficulty and time estimate
    if ! grep -q "Difficulty:" "$file"; then
        errors="${errors}\n  - Missing 'Difficulty:' metadata"
    fi
    
    if ! grep -q "Estimated Time:" "$file"; then
        errors="${errors}\n  - Missing 'Estimated Time:' metadata"
    fi
    
    # Check 10: Has Quick Navigation section
    if ! grep -q "Quick Navigation:" "$file"; then
        errors="${errors}\n  - Missing 'Quick Navigation:' section"
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

# Check if CI/CD exercises directory exists
if [ ! -d "$CICD_EXERCISES_DIR" ]; then
    echo -e "${RED}ERROR${NC}: CI/CD exercises directory not found: $CICD_EXERCISES_DIR"
    exit 1
fi

# Find all CI/CD exercise markdown files
echo "Scanning CI/CD exercise files..."
echo ""

for file in $(find "$CICD_EXERCISES_DIR" -name "*.md" -type f); do
    # Skip non-exercise files (like README)
    if [[ "$file" == *"README"* ]]; then
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    
    if check_cicd_exercise "$file"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=============================================="
echo "Test Results Summary"
echo "=============================================="
echo "Total CI/CD exercises tested: $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

# Check minimum exercise count
# Requirement 3.1: at least 3 GitHub Actions exercises
# Requirement 3.2: at least 2 Azure Pipelines exercises
GITHUB_COUNT=$(find "$CICD_EXERCISES_DIR" -name "github-*.md" -type f | wc -l | tr -d ' ')
AZURE_COUNT=$(find "$CICD_EXERCISES_DIR" -name "azure-*.md" -type f | wc -l | tr -d ' ')

echo "GitHub Actions exercises: $GITHUB_COUNT (minimum: 3)"
echo "Azure Pipelines exercises: $AZURE_COUNT (minimum: 2)"
echo ""

if [ "$GITHUB_COUNT" -lt 3 ]; then
    echo -e "${YELLOW}WARNING${NC}: Only $GITHUB_COUNT GitHub Actions exercises found."
    echo "Requirement 3.1 specifies at least 3 GitHub Actions exercises."
fi

if [ "$AZURE_COUNT" -lt 2 ]; then
    echo -e "${YELLOW}WARNING${NC}: Only $AZURE_COUNT Azure Pipelines exercises found."
    echo "Requirement 3.2 specifies at least 2 Azure Pipelines exercises."
fi

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Property test FAILED${NC}"
    echo "Some CI/CD exercise files do not contain required YAML content."
    exit 1
else
    echo -e "${GREEN}Property test PASSED${NC}"
    echo "All CI/CD exercise files contain required YAML code blocks."
    exit 0
fi
