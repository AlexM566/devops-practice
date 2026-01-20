#!/bin/bash
# Exercise Reset Script
# Restores exercise files to their initial state using git

set -e

EXERCISES_DIR="exercises"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    echo "Exercise Reset Script"
    echo ""
    echo "Restores exercise files to their initial state using git."
    echo ""
    echo "Usage: ./reset-exercises.sh [OPTIONS] [PATH]"
    echo ""
    echo "Options:"
    echo "  -a, --all      Reset all exercises to initial state"
    echo "  -l, --list     List modified exercise files"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Arguments:"
    echo "  PATH           Specific exercise file or directory to reset"
    echo ""
    echo "Examples:"
    echo "  ./reset-exercises.sh -l                              # List modified files"
    echo "  ./reset-exercises.sh -a                              # Reset all exercises"
    echo "  ./reset-exercises.sh exercises/docker/               # Reset docker exercises"
    echo "  ./reset-exercises.sh exercises/docker/docker-basics.md  # Reset one file"
    echo ""
    echo "Note: This script uses git to restore files. Make sure you've committed"
    echo "      any work you want to keep before running reset."
}

check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed or not in PATH${NC}"
        echo ""
        echo "This script requires git to restore exercise files."
        echo "Please install git or manually restore files from a backup."
        exit 1
    fi

    cd "$PROJECT_ROOT"
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo -e "${RED}Error: Not inside a git repository${NC}"
        echo ""
        echo "This script requires the project to be a git repository."
        echo "Alternative: Manually restore files from your backup."
        exit 1
    fi
}

list_modified() {
    cd "$PROJECT_ROOT"
    
    echo "Modified exercise files:"
    echo ""
    
    # Get modified files (both staged and unstaged)
    local modified_files=$(git diff --name-only HEAD -- "$EXERCISES_DIR" 2>/dev/null)
    local untracked_files=$(git ls-files --others --exclude-standard -- "$EXERCISES_DIR" 2>/dev/null)
    
    if [ -z "$modified_files" ] && [ -z "$untracked_files" ]; then
        echo -e "${GREEN}No modified exercise files found.${NC}"
        return 0
    fi
    
    if [ -n "$modified_files" ]; then
        echo -e "${YELLOW}Modified files:${NC}"
        echo "$modified_files" | while read -r file; do
            if [ -n "$file" ]; then
                echo "  $file"
            fi
        done
        echo ""
    fi
    
    if [ -n "$untracked_files" ]; then
        echo -e "${YELLOW}New files (will be deleted on reset):${NC}"
        echo "$untracked_files" | while read -r file; do
            if [ -n "$file" ]; then
                echo "  $file"
            fi
        done
        echo ""
    fi
}

reset_path() {
    local path=$1
    cd "$PROJECT_ROOT"
    
    # Validate path is within exercises directory
    if [[ ! "$path" == "$EXERCISES_DIR"* ]] && [[ ! "$path" == "./$EXERCISES_DIR"* ]]; then
        echo -e "${RED}Error: Path must be within the exercises directory${NC}"
        echo "Provided path: $path"
        exit 1
    fi
    
    # Check if path exists in git
    if ! git ls-files --error-unmatch "$path" &> /dev/null && \
       ! git ls-tree -d HEAD "$path" &> /dev/null; then
        # Check if it's a new file that should be deleted
        if [ -e "$path" ]; then
            echo -e "${YELLOW}Warning: $path is not tracked by git${NC}"
            read -p "Delete this file? (y/N) " confirm
            if [[ $confirm == [yY] ]]; then
                rm -rf "$path"
                echo -e "${GREEN}✓ Deleted: $path${NC}"
            else
                echo "Skipped."
            fi
            return 0
        else
            echo -e "${RED}Error: Path does not exist: $path${NC}"
            exit 1
        fi
    fi
    
    echo "Resetting: $path"
    read -p "Are you sure? (y/N) " confirm
    if [[ $confirm == [yY] ]]; then
        git checkout HEAD -- "$path"
        echo -e "${GREEN}✓ Reset complete: $path${NC}"
        
        # Show summary
        echo ""
        echo "Summary:"
        echo "  Restored: $path"
    else
        echo "Cancelled."
    fi
}

reset_all() {
    cd "$PROJECT_ROOT"
    
    echo -e "${YELLOW}WARNING: This will reset ALL exercises to their initial state.${NC}"
    echo ""
    
    # Show what will be affected
    local modified_count=$(git diff --name-only HEAD -- "$EXERCISES_DIR" 2>/dev/null | wc -l | tr -d ' ')
    local untracked_files=$(git ls-files --others --exclude-standard -- "$EXERCISES_DIR" 2>/dev/null)
    local untracked_count=$(echo "$untracked_files" | grep -c . 2>/dev/null || echo "0")
    
    echo "This will:"
    echo "  - Restore $modified_count modified file(s)"
    if [ "$untracked_count" -gt 0 ]; then
        echo "  - Delete $untracked_count new file(s) in exercises/"
    fi
    echo ""
    
    read -p "Are you sure you want to continue? (y/N) " confirm
    if [[ $confirm == [yY] ]]; then
        # Restore modified files
        git checkout HEAD -- "$EXERCISES_DIR"
        
        # Remove untracked files in exercises directory
        if [ -n "$untracked_files" ]; then
            echo "$untracked_files" | while read -r file; do
                if [ -n "$file" ] && [ -e "$file" ]; then
                    rm -f "$file"
                fi
            done
        fi
        
        echo ""
        echo -e "${GREEN}✓ All exercises reset to initial state${NC}"
        echo ""
        echo "Summary:"
        echo "  Restored: $modified_count file(s)"
        if [ "$untracked_count" -gt 0 ]; then
            echo "  Deleted: $untracked_count new file(s)"
        fi
    else
        echo "Cancelled."
    fi
}

# Main script logic
main() {
    # Check for git availability
    check_git
    
    # Parse arguments
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            list_modified
            exit 0
            ;;
        -a|--all)
            reset_all
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
        *)
            # Treat as path argument
            reset_path "$1"
            exit 0
            ;;
    esac
}

main "$@"
