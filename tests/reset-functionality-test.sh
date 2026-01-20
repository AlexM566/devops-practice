#!/bin/bash
# Property Tests: Reset Functionality
# Validates: Requirements 4.2, 4.3, 4.4
#
# Property 5: Reset Full Restore
# Property 6: Reset Selective Restore
# Property 7: Reset Preserves External Files

set -e

EXERCISES_DIR="exercises"
RESET_SCRIPT="scripts/reset-exercises.sh"
TEST_DIR=".test-reset-temp"
FAILED=0
PASSED=0
TOTAL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "Property Tests: Reset Functionality"
echo "Validates: Requirements 4.2, 4.3, 4.4"
echo "=============================================="
echo ""

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    if [ ! -f "$RESET_SCRIPT" ]; then
        echo -e "${RED}ERROR${NC}: Reset script not found: $RESET_SCRIPT"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}ERROR${NC}: git is not installed"
        exit 1
    fi
    
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo -e "${RED}ERROR${NC}: Not inside a git repository"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites OK${NC}"
    echo ""
}

# Setup test environment
setup_test_env() {
    echo "Setting up test environment..."
    
    # Create temp directory for test artifacts
    mkdir -p "$TEST_DIR"
    
    # Check if there are any commits
    if ! git rev-parse HEAD &> /dev/null; then
        echo -e "${YELLOW}WARNING${NC}: No commits in repository."
        echo "Creating temporary baseline commit for testing..."
        
        # Stage and commit exercises for testing
        git add "$EXERCISES_DIR" 2>/dev/null || true
        git commit -m "Temporary baseline for reset testing" --quiet 2>/dev/null || true
        
        # Mark that we created a test commit
        touch "$TEST_DIR/.test-commit-created"
        echo "Created temporary baseline commit"
    fi
    
    # Store original state of a test file for comparison
    if [ -f "exercises/docker/docker-basics.md" ]; then
        cp "exercises/docker/docker-basics.md" "$TEST_DIR/original-docker-basics.md"
    fi
    
    echo "Test environment ready"
    echo ""
}

# Cleanup test environment
cleanup_test_env() {
    echo ""
    echo "Cleaning up test environment..."
    
    # Restore any modified files
    git checkout HEAD -- "$EXERCISES_DIR" 2>/dev/null || true
    
    # If we created a test commit, reset it
    if [ -f "$TEST_DIR/.test-commit-created" ]; then
        echo "Removing temporary test commit..."
        git reset --soft HEAD~1 2>/dev/null || true
        git reset HEAD -- "$EXERCISES_DIR" 2>/dev/null || true
    fi
    
    # Remove test directory
    rm -rf "$TEST_DIR"
    
    # Remove any test files created outside exercises
    rm -f "test-external-file.txt" 2>/dev/null || true
    
    echo "Cleanup complete"
}

# Trap to ensure cleanup on exit
trap cleanup_test_env EXIT

# Property 5: Reset Full Restore
# For any set of modifications to exercise files, executing the reset script
# with the all flag SHALL restore all exercise files to match their original content exactly.
test_property_5_full_restore() {
    echo "----------------------------------------------"
    echo "Property 5: Reset Full Restore"
    echo "Validates: Requirement 4.2"
    echo "----------------------------------------------"
    
    TOTAL=$((TOTAL + 1))
    local test_passed=1
    
    # Step 1: Modify multiple exercise files
    echo "Step 1: Modifying exercise files..."
    
    local test_files=(
        "exercises/docker/docker-basics.md"
        "exercises/kubernetes/k8s-pods.md"
        "exercises/linux/linux-files.md"
    )
    
    for file in "${test_files[@]}"; do
        if [ -f "$file" ]; then
            # Store original content hash
            local original_hash=$(git show HEAD:"$file" 2>/dev/null | md5sum | cut -d' ' -f1)
            echo "  Original hash for $file: $original_hash"
            
            # Modify the file
            echo "# TEST MODIFICATION $(date)" >> "$file"
            
            # Verify modification
            local modified_hash=$(md5sum "$file" | cut -d' ' -f1)
            if [ "$original_hash" == "$modified_hash" ]; then
                echo -e "  ${RED}Failed to modify $file${NC}"
                test_passed=0
            else
                echo "  Modified $file (new hash: $modified_hash)"
            fi
        fi
    done
    
    # Step 2: Run reset --all (with auto-confirm using yes)
    echo ""
    echo "Step 2: Running reset --all..."
    echo "y" | ./$RESET_SCRIPT --all > /dev/null 2>&1
    
    # Step 3: Verify all files are restored
    echo ""
    echo "Step 3: Verifying files are restored..."
    
    for file in "${test_files[@]}"; do
        if [ -f "$file" ]; then
            local original_hash=$(git show HEAD:"$file" 2>/dev/null | md5sum | cut -d' ' -f1)
            local current_hash=$(md5sum "$file" | cut -d' ' -f1)
            
            if [ "$original_hash" == "$current_hash" ]; then
                echo -e "  ${GREEN}✓${NC} $file restored correctly"
            else
                echo -e "  ${RED}✗${NC} $file NOT restored (expected: $original_hash, got: $current_hash)"
                test_passed=0
            fi
        fi
    done
    
    echo ""
    if [ $test_passed -eq 1 ]; then
        echo -e "${GREEN}PASS${NC}: Property 5 - Reset Full Restore"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}: Property 5 - Reset Full Restore"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Property 6: Reset Selective Restore
# For any specific exercise file path provided to the reset script,
# only that file SHALL be restored while all other modified exercise files remain unchanged.
test_property_6_selective_restore() {
    echo ""
    echo "----------------------------------------------"
    echo "Property 6: Reset Selective Restore"
    echo "Validates: Requirement 4.3"
    echo "----------------------------------------------"
    
    TOTAL=$((TOTAL + 1))
    local test_passed=1
    
    # Step 1: Modify two exercise files
    echo "Step 1: Modifying two exercise files..."
    
    local file_to_reset="exercises/docker/docker-basics.md"
    local file_to_keep_modified="exercises/kubernetes/k8s-pods.md"
    
    # Store original hashes
    local original_hash_reset=$(git show HEAD:"$file_to_reset" 2>/dev/null | md5sum | cut -d' ' -f1)
    local original_hash_keep=$(git show HEAD:"$file_to_keep_modified" 2>/dev/null | md5sum | cut -d' ' -f1)
    
    # Modify both files
    echo "# SELECTIVE TEST MODIFICATION $(date)" >> "$file_to_reset"
    echo "# SELECTIVE TEST MODIFICATION $(date)" >> "$file_to_keep_modified"
    
    local modified_hash_keep=$(md5sum "$file_to_keep_modified" | cut -d' ' -f1)
    echo "  Modified $file_to_reset"
    echo "  Modified $file_to_keep_modified (hash: $modified_hash_keep)"
    
    # Step 2: Reset only one file
    echo ""
    echo "Step 2: Running selective reset on $file_to_reset..."
    echo "y" | ./$RESET_SCRIPT "$file_to_reset" > /dev/null 2>&1
    
    # Step 3: Verify only the specified file is restored
    echo ""
    echo "Step 3: Verifying selective restore..."
    
    # Check reset file is restored
    local current_hash_reset=$(md5sum "$file_to_reset" | cut -d' ' -f1)
    if [ "$original_hash_reset" == "$current_hash_reset" ]; then
        echo -e "  ${GREEN}✓${NC} $file_to_reset was restored"
    else
        echo -e "  ${RED}✗${NC} $file_to_reset was NOT restored"
        test_passed=0
    fi
    
    # Check other file is still modified
    local current_hash_keep=$(md5sum "$file_to_keep_modified" | cut -d' ' -f1)
    if [ "$modified_hash_keep" == "$current_hash_keep" ]; then
        echo -e "  ${GREEN}✓${NC} $file_to_keep_modified remains modified"
    else
        echo -e "  ${RED}✗${NC} $file_to_keep_modified was unexpectedly changed"
        test_passed=0
    fi
    
    # Cleanup: restore the other file too
    git checkout HEAD -- "$file_to_keep_modified" 2>/dev/null || true
    
    echo ""
    if [ $test_passed -eq 1 ]; then
        echo -e "${GREEN}PASS${NC}: Property 6 - Reset Selective Restore"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}: Property 6 - Reset Selective Restore"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Property 7: Reset Preserves External Files
# For any files created outside the exercises directory,
# executing the reset script SHALL not delete or modify those files.
test_property_7_preserves_external() {
    echo ""
    echo "----------------------------------------------"
    echo "Property 7: Reset Preserves External Files"
    echo "Validates: Requirement 4.4"
    echo "----------------------------------------------"
    
    TOTAL=$((TOTAL + 1))
    local test_passed=1
    
    # Step 1: Create files outside exercises directory
    echo "Step 1: Creating external test files..."
    
    local external_file="test-external-file.txt"
    local external_content="This is a test file created outside exercises directory - $(date)"
    echo "$external_content" > "$external_file"
    
    local external_hash=$(md5sum "$external_file" | cut -d' ' -f1)
    echo "  Created $external_file (hash: $external_hash)"
    
    # Also create a file in a subdirectory
    mkdir -p "$TEST_DIR/external"
    local external_subdir_file="$TEST_DIR/external/test-file.txt"
    echo "$external_content" > "$external_subdir_file"
    echo "  Created $external_subdir_file"
    
    # Step 2: Modify an exercise file and run reset
    echo ""
    echo "Step 2: Modifying exercise and running reset..."
    
    local exercise_file="exercises/docker/docker-basics.md"
    echo "# EXTERNAL TEST MODIFICATION $(date)" >> "$exercise_file"
    
    echo "y" | ./$RESET_SCRIPT --all > /dev/null 2>&1
    
    # Step 3: Verify external files are unchanged
    echo ""
    echo "Step 3: Verifying external files are preserved..."
    
    # Check root-level external file
    if [ -f "$external_file" ]; then
        local current_hash=$(md5sum "$external_file" | cut -d' ' -f1)
        if [ "$external_hash" == "$current_hash" ]; then
            echo -e "  ${GREEN}✓${NC} $external_file preserved and unchanged"
        else
            echo -e "  ${RED}✗${NC} $external_file was modified"
            test_passed=0
        fi
    else
        echo -e "  ${RED}✗${NC} $external_file was deleted"
        test_passed=0
    fi
    
    # Check subdirectory external file
    if [ -f "$external_subdir_file" ]; then
        echo -e "  ${GREEN}✓${NC} $external_subdir_file preserved"
    else
        echo -e "  ${RED}✗${NC} $external_subdir_file was deleted"
        test_passed=0
    fi
    
    # Cleanup external file
    rm -f "$external_file"
    
    echo ""
    if [ $test_passed -eq 1 ]; then
        echo -e "${GREEN}PASS${NC}: Property 7 - Reset Preserves External Files"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}: Property 7 - Reset Preserves External Files"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Main test execution
main() {
    check_prerequisites
    setup_test_env
    
    # Run all property tests
    test_property_5_full_restore || true
    test_property_6_selective_restore || true
    test_property_7_preserves_external || true
    
    # Print summary
    echo ""
    echo "=============================================="
    echo "Test Results Summary"
    echo "=============================================="
    echo "Total property tests: $TOTAL"
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    echo -e "Failed: ${RED}$FAILED${NC}"
    echo ""
    
    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}Property tests FAILED${NC}"
        echo "Some reset functionality properties do not hold."
        exit 1
    else
        echo -e "${GREEN}All property tests PASSED${NC}"
        echo "Reset functionality conforms to requirements."
        exit 0
    fi
}

main "$@"
