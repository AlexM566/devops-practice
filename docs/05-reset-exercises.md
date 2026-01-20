# Exercise Reset Guide

## Overview

The DevOps Playground includes a reset mechanism to restore exercise files to their initial state. This is useful when you want to:
- Start an exercise over from scratch
- Undo changes made during practice
- Reset all exercises after completing them

## How It Works

The reset script uses **git** to restore exercise files. Since all exercises are tracked in the git repository, the script simply checks out the original versions from the last commit.

### Prerequisites

- Git must be installed and available in your PATH
- The project must be a git repository (it is by default when cloned)
- You should commit any work you want to keep before resetting

## Usage

### View Modified Files

See which exercise files have been modified:

```bash
./scripts/reset-exercises.sh --list
# or
./scripts/reset-exercises.sh -l
```

### Reset All Exercises

Restore all exercises to their initial state:

```bash
./scripts/reset-exercises.sh --all
# or
./scripts/reset-exercises.sh -a
```

You'll be prompted to confirm before any changes are made.

### Reset Specific Exercise

Restore a single exercise file:

```bash
./scripts/reset-exercises.sh exercises/docker/docker-basics.md
```

### Reset Exercise Category

Restore all exercises in a category:

```bash
./scripts/reset-exercises.sh exercises/docker/
./scripts/reset-exercises.sh exercises/python/
./scripts/reset-exercises.sh exercises/cicd/
```

### Show Help

```bash
./scripts/reset-exercises.sh --help
# or
./scripts/reset-exercises.sh -h
```

## Important Notes

1. **Commit Your Work First**: The reset script uses `git checkout` to restore files. Any uncommitted changes to exercise files will be lost.

2. **New Files**: If you created new files in the exercises directory, the reset script will offer to delete them.

3. **Files Outside Exercises**: The reset script only affects files in the `exercises/` directory. Your work in other directories is safe.

4. **Workspace Files**: Files in workspace directories (like `exercises/python/workspace/`) that you created will be deleted on full reset.

## Fallback: Manual Reset Without Git

If you're not using git or prefer a manual approach, you can reset exercises by:

### Option 1: Re-clone the Repository

```bash
# Backup your work first
cp -r exercises/ ~/my-exercise-backup/

# Remove and re-clone
cd ..
rm -rf devops-playground
git clone <repository-url>
```

### Option 2: Download Fresh Copies

1. Go to the repository on GitHub
2. Navigate to the exercise file you want to reset
3. Click "Raw" to view the original content
4. Copy and paste into your local file

### Option 3: Create Your Own Backup

Before starting exercises, create a backup:

```bash
# Create backup directory
mkdir -p .exercise-backup

# Copy all exercises
cp -r exercises/* .exercise-backup/

# Later, to restore:
cp -r .exercise-backup/* exercises/
```

## Troubleshooting

### "git is not installed"

Install git for your operating system:
- **macOS**: `brew install git` or download from https://git-scm.com
- **Ubuntu/Debian**: `sudo apt install git`
- **Windows**: Download from https://git-scm.com

### "Not inside a git repository"

The project directory must be a git repository. If you downloaded as a ZIP file instead of cloning:

```bash
# Initialize git in the project
git init
git add .
git commit -m "Initial state"
```

Now the reset script will work using this commit as the baseline.

### "Path must be within exercises directory"

The reset script only works with files in the `exercises/` directory. This is a safety feature to prevent accidentally resetting other project files.

### Permission Denied

Make sure the script is executable:

```bash
chmod +x scripts/reset-exercises.sh
```

## Best Practices

1. **Commit Before Reset**: Always commit your work before resetting if you want to keep it
2. **Use Branches**: Consider creating a branch for your exercise work
   ```bash
   git checkout -b my-practice
   # Do exercises...
   git add .
   git commit -m "My exercise solutions"
   # Reset to try again
   ./scripts/reset-exercises.sh -a
   ```
3. **Selective Reset**: Use specific paths to reset only what you need
4. **Review Changes**: Use `--list` to see what will be affected before resetting
