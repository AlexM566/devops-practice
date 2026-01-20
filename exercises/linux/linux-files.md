# Linux File Operations, Permissions, and Ownership

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Basic command line familiarity

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn essential Linux file operations including creating, moving, copying files and directories, as well as understanding and modifying file permissions and ownership. By the end of this exercise, you'll be comfortable navigating the filesystem and managing file access controls.

## Instructions

### Part 1: Basic File Operations

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. Create a new directory called `practice` in your home directory and navigate into it:
```bash
mkdir ~/practice
cd ~/practice
```

3. Create three empty files using different methods:
```bash
touch file1.txt
echo "Hello World" > file2.txt
cat > file3.txt
# Type some text, then press Ctrl+D to save
```

4. List all files with detailed information:
```bash
ls -lah
```

5. Copy `file1.txt` to `file1_backup.txt`:
```bash
cp file1.txt file1_backup.txt
```

6. Create a subdirectory called `archive` and move `file1_backup.txt` into it:
```bash
mkdir archive
mv file1_backup.txt archive/
```

7. Copy the entire `archive` directory to `archive_copy`:
```bash
cp -r archive archive_copy
```

### Part 2: File Permissions

8. View the permissions of `file2.txt`:
```bash
ls -l file2.txt
```

9. Change the permissions of `file2.txt` to read-only for everyone:
```bash
chmod 444 file2.txt
```

10. Try to write to the file (this should fail):
```bash
echo "test" >> file2.txt
```

11. Restore write permissions for the owner:
```bash
chmod 644 file2.txt
```

12. Create a script file and make it executable:
```bash
echo '#!/bin/bash' > script.sh
echo 'echo "Script executed!"' >> script.sh
chmod +x script.sh
./script.sh
```

### Part 3: File Ownership

13. Check the current owner and group of your files:
```bash
ls -l
```

14. View your current user and groups:
```bash
whoami
groups
id
```

15. Create a file and examine its default ownership:
```bash
touch ownership_test.txt
ls -l ownership_test.txt
```

## Expected Output

**After listing files (step 4):**
```
total 16K
drwxr-xr-x 3 root root 4.0K Jan 19 10:30 .
drwx------ 1 root root 4.0K Jan 19 10:25 ..
-rw-r--r-- 1 root root    0 Jan 19 10:30 file1.txt
-rw-r--r-- 1 root root   12 Jan 19 10:30 file2.txt
-rw-r--r-- 1 root root   15 Jan 19 10:30 file3.txt
```

**After changing permissions to read-only (step 9):**
```
-r--r--r-- 1 root root 12 Jan 19 10:30 file2.txt
```

**After making script executable (step 12):**
```
Script executed!
```

## Verification Steps

Verify your work by checking:
- All files and directories were created successfully: `ls -R`
- File permissions are correct: `ls -l file2.txt` should show `-rw-r--r--`
- Script is executable: `ls -l script.sh` should show `-rwxr-xr-x`
- Files exist in the archive directory: `ls archive/`

## Hints

<details>
<summary>Hint 1: Understanding Permission Numbers</summary>

Permissions use octal notation:
- 4 = read (r)
- 2 = write (w)
- 1 = execute (x)

So 644 means:
- 6 (4+2) = read+write for owner
- 4 = read for group
- 4 = read for others
</details>

<details>
<summary>Hint 2: Permission Format</summary>

When you see `-rw-r--r--`, it breaks down as:
- First character: file type (- for file, d for directory)
- Next 3 characters: owner permissions (rwx)
- Next 3 characters: group permissions (rwx)
- Last 3 characters: other permissions (rwx)
</details>

<details>
<summary>Hint 3: Common chmod Patterns</summary>

Common permission patterns:
- `chmod 755`: rwxr-xr-x (executable files, directories)
- `chmod 644`: rw-r--r-- (regular files)
- `chmod 600`: rw------- (private files)
- `chmod +x`: add execute permission
- `chmod -w`: remove write permission
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Complete solution with all commands:

```bash
# Access container
docker exec -it devops-ubuntu bash

# Part 1: File Operations
mkdir ~/practice
cd ~/practice
touch file1.txt
echo "Hello World" > file2.txt
cat > file3.txt
# Type text and press Ctrl+D

ls -lah
cp file1.txt file1_backup.txt
mkdir archive
mv file1_backup.txt archive/
cp -r archive archive_copy

# Part 2: Permissions
ls -l file2.txt
chmod 444 file2.txt
echo "test" >> file2.txt  # This will fail with "Permission denied"
chmod 644 file2.txt
echo '#!/bin/bash' > script.sh
echo 'echo "Script executed!"' >> script.sh
chmod +x script.sh
./script.sh

# Part 3: Ownership
ls -l
whoami
groups
id
touch ownership_test.txt
ls -l ownership_test.txt
```

**Explanation:**

- `mkdir` creates directories
- `touch` creates empty files
- `echo >` redirects output to a file (overwrites)
- `echo >>` appends to a file
- `cp` copies files, `cp -r` copies directories recursively
- `mv` moves/renames files
- `chmod` changes permissions using octal (644) or symbolic (+x) notation
- `ls -l` shows detailed file information including permissions and ownership
- Files are owned by the user who creates them (root in the container)
</details>

## Additional Resources

- [Linux File Permissions Explained](https://www.linux.com/training-tutorials/understanding-linux-file-permissions/)
- [chmod Command Tutorial](https://www.computerhope.com/unix/uchmod.htm)
- [Linux File System Hierarchy](https://www.pathname.com/fhs/)
# TEST MODIFICATION Tue Jan 20 10:17:06 EET 2026
