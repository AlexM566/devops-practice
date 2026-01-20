# Linux Bash Scripting Fundamentals

**Difficulty:** Intermediate
**Estimated Time:** 45 minutes
**Prerequisites:** Basic Linux commands, file operations, understanding of processes

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to write bash scripts with variables, conditionals, loops, and functions. By the end of this exercise, you'll be able to automate common tasks and create reusable scripts for system administration.

## Instructions

### Part 1: Basic Script Structure

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. Create a directory for your scripts:
```bash
mkdir ~/scripts
cd ~/scripts
```

3. Create your first script:
```bash
cat > hello.sh << 'EOF'
#!/bin/bash
# My first bash script

echo "Hello, World!"
echo "Current date: $(date)"
echo "Current user: $(whoami)"
EOF
```

4. Make the script executable and run it:
```bash
chmod +x hello.sh
./hello.sh
```

### Part 2: Variables

5. Create a script with variables:
```bash
cat > variables.sh << 'EOF'
#!/bin/bash

# Variable assignment
NAME="DevOps Engineer"
COUNT=42
VERSION="1.0"

# Using variables
echo "Name: $NAME"
echo "Count: $COUNT"
echo "Version: ${VERSION}"

# Command substitution
CURRENT_DIR=$(pwd)
FILE_COUNT=$(ls -1 | wc -l)

echo "Current directory: $CURRENT_DIR"
echo "Files in directory: $FILE_COUNT"

# Read user input
echo -n "Enter your name: "
read USER_NAME
echo "Hello, $USER_NAME!"
EOF

chmod +x variables.sh
./variables.sh
```

6. Create a script with command-line arguments:
```bash
cat > arguments.sh << 'EOF'
#!/bin/bash

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"

# Check if arguments provided
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    echo "Usage: $0 <arg1> <arg2> ..."
    exit 1
fi
EOF

chmod +x arguments.sh
./arguments.sh hello world test
```

### Part 3: Conditionals

7. Create a script with if-else statements:
```bash
cat > conditionals.sh << 'EOF'
#!/bin/bash

# Check if argument provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a number"
    exit 1
fi

NUMBER=$1

# Numeric comparisons
if [ $NUMBER -gt 10 ]; then
    echo "$NUMBER is greater than 10"
elif [ $NUMBER -eq 10 ]; then
    echo "$NUMBER is equal to 10"
else
    echo "$NUMBER is less than 10"
fi

# Check if file exists
FILE="test.txt"
if [ -f "$FILE" ]; then
    echo "$FILE exists"
else
    echo "$FILE does not exist"
    touch "$FILE"
    echo "Created $FILE"
fi

# Check if directory exists
DIR="testdir"
if [ -d "$DIR" ]; then
    echo "$DIR directory exists"
else
    echo "$DIR directory does not exist"
    mkdir "$DIR"
    echo "Created $DIR directory"
fi
EOF

chmod +x conditionals.sh
./conditionals.sh 15
```

8. Create a script with case statements:
```bash
cat > case_example.sh << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <start|stop|restart|status>"
    exit 1
fi

ACTION=$1

case $ACTION in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking service status..."
        ;;
    *)
        echo "Unknown action: $ACTION"
        echo "Valid actions: start, stop, restart, status"
        exit 1
        ;;
esac
EOF

chmod +x case_example.sh
./case_example.sh start
./case_example.sh status
```

### Part 4: Loops

9. Create a script with for loops:
```bash
cat > for_loops.sh << 'EOF'
#!/bin/bash

# Simple for loop
echo "Counting 1 to 5:"
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# For loop with range
echo -e "\nCounting 1 to 10:"
for i in {1..10}; do
    echo -n "$i "
done
echo

# For loop with C-style syntax
echo -e "\nEven numbers 0 to 10:"
for ((i=0; i<=10; i+=2)); do
    echo -n "$i "
done
echo

# Loop through files
echo -e "\nFiles in current directory:"
for file in *; do
    if [ -f "$file" ]; then
        echo "File: $file"
    fi
done

# Loop through command output
echo -e "\nProcessing lines:"
for line in $(cat /etc/hostname); do
    echo "Line: $line"
done
EOF

chmod +x for_loops.sh
./for_loops.sh
```

10. Create a script with while loops:
```bash
cat > while_loops.sh << 'EOF'
#!/bin/bash

# Simple while loop
echo "Countdown from 5:"
COUNT=5
while [ $COUNT -gt 0 ]; do
    echo $COUNT
    COUNT=$((COUNT - 1))
    sleep 1
done
echo "Blast off!"

# Read file line by line
echo -e "\nReading /etc/hostname:"
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hostname

# Infinite loop with break
echo -e "\nLoop with break:"
COUNTER=0
while true; do
    COUNTER=$((COUNTER + 1))
    echo "Iteration: $COUNTER"
    
    if [ $COUNTER -eq 3 ]; then
        echo "Breaking loop"
        break
    fi
done
EOF

chmod +x while_loops.sh
./while_loops.sh
```

### Part 5: Functions

11. Create a script with functions:
```bash
cat > functions.sh << 'EOF'
#!/bin/bash

# Simple function
greet() {
    echo "Hello from function!"
}

# Function with parameters
greet_user() {
    local name=$1
    echo "Hello, $name!"
}

# Function with return value
add_numbers() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result
}

# Function that returns status
check_file() {
    local filename=$1
    if [ -f "$filename" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Call functions
greet
greet_user "DevOps Engineer"

SUM=$(add_numbers 10 20)
echo "Sum: $SUM"

if check_file "test.txt"; then
    echo "test.txt exists"
else
    echo "test.txt does not exist"
fi
EOF

chmod +x functions.sh
./functions.sh
```

### Part 6: Practical Script

12. Create a comprehensive backup script:
```bash
cat > backup.sh << 'EOF'
#!/bin/bash

# Backup script with error handling

# Configuration
SOURCE_DIR="$HOME/scripts"
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

# Function to print messages
log_message() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1"
}

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        log_message "Error: Directory $1 does not exist"
        return 1
    fi
    return 0
}

# Main backup function
perform_backup() {
    log_message "Starting backup..."
    
    # Check source directory
    if ! check_directory "$SOURCE_DIR"; then
        exit 1
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then
        log_message "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Perform backup
    log_message "Backing up $SOURCE_DIR to $BACKUP_DIR/$BACKUP_FILE"
    tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$(dirname $SOURCE_DIR)" "$(basename $SOURCE_DIR)" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_message "Backup completed successfully"
        log_message "Backup file: $BACKUP_DIR/$BACKUP_FILE"
        
        # Show backup size
        SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
        log_message "Backup size: $SIZE"
    else
        log_message "Error: Backup failed"
        exit 1
    fi
    
    # Clean up old backups (keep last 5)
    log_message "Cleaning up old backups..."
    cd "$BACKUP_DIR"
    ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm
    log_message "Cleanup completed"
}

# Run backup
perform_backup
EOF

chmod +x backup.sh
./backup.sh
```

13. Verify the backup was created:
```bash
ls -lh ~/backups/
```

## Expected Output

**After running hello.sh (step 4):**
```
Hello, World!
Current date: Mon Jan 19 10:30:45 UTC 2026
Current user: root
```

**After running arguments.sh (step 6):**
```
Script name: ./arguments.sh
First argument: hello
Second argument: world
All arguments: hello world test
Number of arguments: 3
```

**After running backup.sh (step 12):**
```
[2026-01-19 10:35:22] Starting backup...
[2026-01-19 10:35:22] Backing up /root/scripts to /root/backups/backup_20260119_103522.tar.gz
[2026-01-19 10:35:22] Backup completed successfully
[2026-01-19 10:35:22] Backup file: /root/backups/backup_20260119_103522.tar.gz
[2026-01-19 10:35:22] Backup size: 4.0K
[2026-01-19 10:35:22] Cleaning up old backups...
[2026-01-19 10:35:22] Cleanup completed
```

## Verification Steps

Verify your work by checking:
- All scripts are executable: `ls -l ~/scripts/*.sh`
- Scripts run without errors
- Backup directory was created: `ls ~/backups/`
- Backup file exists and contains your scripts: `tar -tzf ~/backups/backup_*.tar.gz`

## Hints

<details>
<summary>Hint 1: Shebang Line</summary>

The `#!/bin/bash` line (shebang) must be the first line of your script. It tells the system which interpreter to use. Common shebangs:
- `#!/bin/bash`: Bash shell
- `#!/bin/sh`: POSIX shell
- `#!/usr/bin/env python3`: Python 3
</details>

<details>
<summary>Hint 2: Variable Syntax</summary>

Variable usage:
- Assignment: `VAR=value` (no spaces around =)
- Access: `$VAR` or `${VAR}`
- Command substitution: `$(command)` or `` `command` ``
- Arithmetic: `$((expression))`
</details>

<details>
<summary>Hint 3: Test Operators</summary>

Common test operators:
- Numeric: `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge`
- String: `=`, `!=`, `-z` (empty), `-n` (not empty)
- File: `-f` (file), `-d` (directory), `-e` (exists), `-r` (readable), `-w` (writable), `-x` (executable)
</details>

<details>
<summary>Hint 4: Exit Codes</summary>

- `exit 0`: Success
- `exit 1` (or any non-zero): Failure
- `$?`: Contains exit code of last command
- Use exit codes to indicate script success/failure
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

All commands are provided in the instructions above. Key concepts:

**Script Structure:**
- Start with shebang: `#!/bin/bash`
- Add comments with `#`
- Make executable with `chmod +x`
- Run with `./script.sh`

**Variables:**
- Assign: `VAR=value`
- Use: `$VAR` or `${VAR}`
- Command substitution: `$(command)`
- Read input: `read VAR`

**Conditionals:**
- if-else: `if [ condition ]; then ... elif [ condition ]; then ... else ... fi`
- case: `case $VAR in pattern) commands ;; esac`

**Loops:**
- for: `for var in list; do commands; done`
- while: `while [ condition ]; do commands; done`
- C-style: `for ((i=0; i<10; i++)); do commands; done`

**Functions:**
- Define: `function_name() { commands; }`
- Call: `function_name arg1 arg2`
- Local variables: `local var=value`
- Return: `return 0` (status) or `echo value` (output)

**Best Practices:**
- Use meaningful variable names
- Quote variables: `"$VAR"`
- Check for errors: `if [ $? -ne 0 ]; then`
- Use functions for reusable code
- Add comments and logging
- Handle edge cases
</details>

## Additional Resources

- [Bash Scripting Tutorial](https://www.shellscript.sh/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)
- [ShellCheck - Script Analysis Tool](https://www.shellcheck.net/)
