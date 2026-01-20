# Linux Process Management

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Basic command line familiarity

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to view running processes, understand process information, manage process lifecycle (start, stop, kill), and work with foreground and background jobs. By the end of this exercise, you'll be able to monitor and control processes effectively.

## Instructions

### Part 1: Viewing Processes

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. View all currently running processes:
```bash
ps aux
```

3. View processes in a tree format to see parent-child relationships:
```bash
ps auxf
```

4. Use `top` to view processes in real-time (press 'q' to quit):
```bash
top
```

5. View processes for the current user only:
```bash
ps -u $(whoami)
```

6. Find specific processes by name using `grep`:
```bash
ps aux | grep bash
```

### Part 2: Process Information

7. View detailed information about your current shell process:
```bash
echo $$  # Shows your current shell's PID
ps -p $$ -f
```

8. View the process tree from your shell:
```bash
pstree -p $$
```

9. Check how long processes have been running:
```bash
ps -eo pid,etime,cmd | head -20
```

### Part 3: Managing Processes

10. Start a long-running process in the foreground:
```bash
sleep 100
```
(Press Ctrl+C to stop it)

11. Start a process in the background:
```bash
sleep 200 &
```

12. View background jobs:
```bash
jobs
```

13. Start another background process:
```bash
sleep 300 &
jobs
```

14. Bring a background job to the foreground:
```bash
fg %1
```
(Press Ctrl+Z to suspend it)

15. Resume the suspended job in the background:
```bash
bg %1
jobs
```

### Part 4: Killing Processes

16. Find the PID of one of your sleep processes:
```bash
ps aux | grep sleep
```

17. Kill a process using its PID (replace PID with actual number):
```bash
kill PID
```

18. Verify the process was terminated:
```bash
jobs
ps aux | grep sleep
```

19. Start a stubborn process and force kill it:
```bash
sleep 400 &
kill -9 $(pgrep -f "sleep 400")
```

20. Kill all sleep processes at once:
```bash
pkill sleep
jobs
```

## Expected Output

**After viewing processes (step 2):**
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4624  3456 ?        Ss   10:00   0:00 bash
root        45  0.0  0.0   7892  3328 ?        R+   10:15   0:00 ps aux
```

**After starting background job (step 11):**
```
[1] 123
```

**After viewing jobs (step 12):**
```
[1]+  Running                 sleep 200 &
```

**After killing process (step 17):**
```
[1]+  Terminated              sleep 200
```

## Verification Steps

Verify your work by checking:
- You can view all running processes: `ps aux`
- Background jobs appear in jobs list: `jobs`
- Killed processes no longer appear: `ps aux | grep sleep` returns nothing
- You understand the difference between foreground and background processes

## Hints

<details>
<summary>Hint 1: Understanding Process States</summary>

Common process states in `ps` output:
- R: Running
- S: Sleeping (waiting for an event)
- T: Stopped (suspended)
- Z: Zombie (terminated but not cleaned up)
- D: Uninterruptible sleep (usually I/O)
</details>

<details>
<summary>Hint 2: Kill Signals</summary>

Common kill signals:
- `kill PID` or `kill -15 PID`: SIGTERM (graceful termination)
- `kill -9 PID`: SIGKILL (force kill, cannot be caught)
- `kill -STOP PID`: Suspend process
- `kill -CONT PID`: Resume process

Always try SIGTERM before SIGKILL to allow graceful shutdown.
</details>

<details>
<summary>Hint 3: Job Control</summary>

Job control commands:
- `&` at end of command: start in background
- `Ctrl+Z`: suspend current foreground process
- `Ctrl+C`: terminate current foreground process
- `fg %N`: bring job N to foreground
- `bg %N`: resume job N in background
- `jobs`: list all jobs
</details>

<details>
<summary>Hint 4: Finding Processes</summary>

Useful commands for finding processes:
- `pgrep process_name`: find PID by name
- `pidof process_name`: find PID of running program
- `ps aux | grep pattern`: search for processes
- `top` or `htop`: interactive process viewer
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Complete solution with all commands:

```bash
# Access container
docker exec -it devops-ubuntu bash

# Part 1: Viewing Processes
ps aux
ps auxf
top  # Press 'q' to quit
ps -u $(whoami)
ps aux | grep bash

# Part 2: Process Information
echo $$
ps -p $$ -f
pstree -p $$
ps -eo pid,etime,cmd | head -20

# Part 3: Managing Processes
sleep 100  # Press Ctrl+C to stop
sleep 200 &
jobs
sleep 300 &
jobs
fg %1  # Press Ctrl+Z to suspend
bg %1
jobs

# Part 4: Killing Processes
ps aux | grep sleep
# Note the PID from output, then:
kill PID  # Replace PID with actual number
jobs
ps aux | grep sleep

# Force kill example
sleep 400 &
kill -9 $(pgrep -f "sleep 400")

# Kill all sleep processes
pkill sleep
jobs
```

**Explanation:**

- `ps aux`: shows all processes with detailed information
- `ps auxf`: shows process tree (forest view)
- `top`: real-time process monitoring
- `$$`: special variable containing current shell's PID
- `&`: runs command in background
- `jobs`: lists background jobs for current shell
- `fg`: brings job to foreground
- `bg`: resumes job in background
- `Ctrl+Z`: suspends current process
- `Ctrl+C`: terminates current process
- `kill PID`: sends SIGTERM to process
- `kill -9 PID`: sends SIGKILL (force kill)
- `pgrep`: finds process ID by name
- `pkill`: kills processes by name
</details>

## Additional Resources

- [Linux Process Management Guide](https://www.digitalocean.com/community/tutorials/process-management-in-linux)
- [Understanding Linux Processes](https://www.howtogeek.com/107217/how-to-manage-processes-from-the-linux-terminal-10-commands-you-need-to-know/)
- [Job Control in Bash](https://www.gnu.org/software/bash/manual/html_node/Job-Control.html)
