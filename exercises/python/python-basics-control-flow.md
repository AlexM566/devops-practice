# Python Basics: Control Flow

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Python variables and data types

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Master Python's control flow statements including conditionals (if/elif/else) and loops (for/while). These are essential for writing automation scripts that make decisions and process collections of data.

## Instructions

### Part 1: Conditional Statements

Create a file called `control_flow.py` in the workspace directory.

1. Write a function `check_server_status(cpu_percent, memory_percent)` that:
   - Returns "CRITICAL" if CPU > 90 OR memory > 90
   - Returns "WARNING" if CPU > 70 OR memory > 70
   - Returns "HEALTHY" otherwise

2. Test your function with these values:
   - CPU: 95, Memory: 50 → should return "CRITICAL"
   - CPU: 75, Memory: 60 → should return "WARNING"
   - CPU: 45, Memory: 55 → should return "HEALTHY"

### Part 2: For Loops

3. Create a list of server dictionaries:
   ```python
   servers = [
       {"name": "web-01", "status": "running", "cpu": 45},
       {"name": "web-02", "status": "stopped", "cpu": 0},
       {"name": "db-01", "status": "running", "cpu": 78},
       {"name": "cache-01", "status": "running", "cpu": 92},
   ]
   ```

4. Write code to:
   - Print each server's name and status
   - Count how many servers are running
   - Find all servers with CPU > 70
   - Calculate the average CPU usage of running servers

### Part 3: While Loops

5. Write a function `retry_connection(max_attempts)` that:
   - Simulates connection attempts (use a counter)
   - Prints "Attempting connection... (attempt X of Y)"
   - Succeeds on the 3rd attempt (simulated)
   - Returns True if connected, False if max attempts exceeded
   - Uses `break` when connection succeeds

6. Write a function `process_queue(items)` that:
   - Processes items from a list until empty
   - Uses `continue` to skip items that start with "#" (comments)
   - Prints each processed item
   - Returns the count of processed items

### Part 4: Challenge - Log Level Filter

7. Create a log filtering system:
   ```python
   logs = [
       {"level": "INFO", "message": "Server started"},
       {"level": "DEBUG", "message": "Loading config"},
       {"level": "WARNING", "message": "High memory usage"},
       {"level": "ERROR", "message": "Connection failed"},
       {"level": "INFO", "message": "Request received"},
       {"level": "ERROR", "message": "Database timeout"},
       {"level": "DEBUG", "message": "Cache hit"},
   ]
   ```

8. Write a function `filter_logs(logs, min_level)` that:
   - Takes a list of logs and a minimum level
   - Level priority: DEBUG < INFO < WARNING < ERROR
   - Returns only logs at or above the minimum level
   - Example: `filter_logs(logs, "WARNING")` returns WARNING and ERROR logs

## Expected Output

```
=== Part 1: Conditional Statements ===
CPU: 95, Memory: 50 -> CRITICAL
CPU: 75, Memory: 60 -> WARNING
CPU: 45, Memory: 55 -> HEALTHY

=== Part 2: For Loops ===
Server: web-01, Status: running
Server: web-02, Status: stopped
Server: db-01, Status: running
Server: cache-01, Status: running
Running servers: 3
High CPU servers: ['db-01', 'cache-01']
Average CPU (running): 71.67%

=== Part 3: While Loops ===
Attempting connection... (attempt 1 of 5)
Attempting connection... (attempt 2 of 5)
Attempting connection... (attempt 3 of 5)
Connected successfully!
Processing: task1
Skipping comment: #comment
Processing: task2
Processing: task3
Processed 3 items

=== Part 4: Log Filter Challenge ===
Filtering logs at WARNING level and above:
[WARNING] High memory usage
[ERROR] Connection failed
[ERROR] Database timeout
```

## Verification Steps

Run your script:
```bash
cd /workspace
python control_flow.py
```

1. Server status function returns correct levels for all test cases
2. For loop correctly iterates and counts servers
3. While loop with retry stops at correct attempt
4. Continue statement properly skips comments
5. Log filter returns only logs at or above specified level

## Hints

<details>
<summary>Hint 1: Multiple Conditions</summary>

Use `or` and `and` for combining conditions:
```python
if cpu > 90 or memory > 90:
    return "CRITICAL"
elif cpu > 70 or memory > 70:
    return "WARNING"
```
</details>

<details>
<summary>Hint 2: Iterating with Enumerate</summary>

To get both index and value in a loop:
```python
for index, item in enumerate(items):
    print(f"Item {index}: {item}")
```
</details>

<details>
<summary>Hint 3: Break and Continue</summary>

- `break` exits the loop entirely
- `continue` skips to the next iteration
```python
while True:
    if success:
        break  # Exit loop
    if skip_condition:
        continue  # Skip rest of this iteration
```
</details>

<details>
<summary>Hint 4: Level Priority Mapping</summary>

Use a dictionary to map levels to numeric priorities:
```python
level_priority = {"DEBUG": 0, "INFO": 1, "WARNING": 2, "ERROR": 3}
```
</details>

---

## Solution

<details>
<summary>Click to reveal complete solution</summary>

### Complete Solution

```python
#!/usr/bin/env python3
"""
Python Basics: Control Flow
DevOps Interview Playground Exercise
"""

# === Part 1: Conditional Statements ===
print("=== Part 1: Conditional Statements ===")

def check_server_status(cpu_percent, memory_percent):
    """Check server health based on CPU and memory usage."""
    if cpu_percent > 90 or memory_percent > 90:
        return "CRITICAL"
    elif cpu_percent > 70 or memory_percent > 70:
        return "WARNING"
    else:
        return "HEALTHY"

# Test the function
test_cases = [
    (95, 50),  # CRITICAL
    (75, 60),  # WARNING
    (45, 55),  # HEALTHY
]

for cpu, memory in test_cases:
    status = check_server_status(cpu, memory)
    print(f"CPU: {cpu}, Memory: {memory} -> {status}")

# === Part 2: For Loops ===
print("\n=== Part 2: For Loops ===")

servers = [
    {"name": "web-01", "status": "running", "cpu": 45},
    {"name": "web-02", "status": "stopped", "cpu": 0},
    {"name": "db-01", "status": "running", "cpu": 78},
    {"name": "cache-01", "status": "running", "cpu": 92},
]

# Print each server's name and status
for server in servers:
    print(f"Server: {server['name']}, Status: {server['status']}")

# Count running servers
running_count = 0
for server in servers:
    if server["status"] == "running":
        running_count += 1
print(f"Running servers: {running_count}")

# Find servers with high CPU
high_cpu_servers = []
for server in servers:
    if server["cpu"] > 70:
        high_cpu_servers.append(server["name"])
print(f"High CPU servers: {high_cpu_servers}")

# Calculate average CPU of running servers
total_cpu = 0
running_servers = 0
for server in servers:
    if server["status"] == "running":
        total_cpu += server["cpu"]
        running_servers += 1

if running_servers > 0:
    avg_cpu = total_cpu / running_servers
    print(f"Average CPU (running): {avg_cpu:.2f}%")

# === Part 3: While Loops ===
print("\n=== Part 3: While Loops ===")

def retry_connection(max_attempts):
    """Simulate connection retry logic."""
    attempt = 0
    connected = False
    
    while attempt < max_attempts:
        attempt += 1
        print(f"Attempting connection... (attempt {attempt} of {max_attempts})")
        
        # Simulate: connection succeeds on 3rd attempt
        if attempt == 3:
            print("Connected successfully!")
            connected = True
            break
    
    if not connected:
        print("Failed to connect after all attempts")
    
    return connected

# Test retry function
retry_connection(5)

def process_queue(items):
    """Process items, skipping comments."""
    processed = 0
    index = 0
    
    while index < len(items):
        item = items[index]
        index += 1
        
        # Skip comments
        if item.startswith("#"):
            print(f"Skipping comment: {item}")
            continue
        
        print(f"Processing: {item}")
        processed += 1
    
    print(f"Processed {processed} items")
    return processed

# Test queue processing
queue = ["task1", "#comment", "task2", "task3"]
process_queue(queue)

# === Part 4: Log Filter Challenge ===
print("\n=== Part 4: Log Filter Challenge ===")

logs = [
    {"level": "INFO", "message": "Server started"},
    {"level": "DEBUG", "message": "Loading config"},
    {"level": "WARNING", "message": "High memory usage"},
    {"level": "ERROR", "message": "Connection failed"},
    {"level": "INFO", "message": "Request received"},
    {"level": "ERROR", "message": "Database timeout"},
    {"level": "DEBUG", "message": "Cache hit"},
]

def filter_logs(logs, min_level):
    """Filter logs by minimum level."""
    level_priority = {
        "DEBUG": 0,
        "INFO": 1,
        "WARNING": 2,
        "ERROR": 3
    }
    
    min_priority = level_priority.get(min_level, 0)
    filtered = []
    
    for log in logs:
        log_priority = level_priority.get(log["level"], 0)
        if log_priority >= min_priority:
            filtered.append(log)
    
    return filtered

# Test log filtering
print("Filtering logs at WARNING level and above:")
warning_logs = filter_logs(logs, "WARNING")
for log in warning_logs:
    print(f"[{log['level']}] {log['message']}")
```

### Explanation

**Conditional Statements:**
- `if/elif/else` chain evaluates conditions in order
- First matching condition executes, rest are skipped
- Use `or` when any condition being true should trigger
- Use `and` when all conditions must be true

**For Loops:**
- Iterate over any iterable (list, dict, string, etc.)
- Access dictionary values with `dict["key"]`
- Use list comprehension for concise filtering: `[x for x in list if condition]`

**While Loops:**
- Continue until condition becomes False
- `break` exits immediately
- `continue` skips to next iteration
- Always ensure loop will eventually terminate

**Level Priority Pattern:**
- Map string levels to numeric values
- Compare numbers for ordering
- Common pattern in logging and alerting systems

</details>

## Test Cases

Save this as `test_control_flow.py`:

```python
#!/usr/bin/env python3
"""Test cases for control flow exercise"""

def check_server_status(cpu_percent, memory_percent):
    if cpu_percent > 90 or memory_percent > 90:
        return "CRITICAL"
    elif cpu_percent > 70 or memory_percent > 70:
        return "WARNING"
    else:
        return "HEALTHY"

def filter_logs(logs, min_level):
    level_priority = {"DEBUG": 0, "INFO": 1, "WARNING": 2, "ERROR": 3}
    min_priority = level_priority.get(min_level, 0)
    return [log for log in logs if level_priority.get(log["level"], 0) >= min_priority]

def test_server_status():
    """Test server status function"""
    assert check_server_status(95, 50) == "CRITICAL"
    assert check_server_status(50, 95) == "CRITICAL"
    assert check_server_status(75, 60) == "WARNING"
    assert check_server_status(60, 75) == "WARNING"
    assert check_server_status(45, 55) == "HEALTHY"
    assert check_server_status(70, 70) == "HEALTHY"  # Boundary case
    print("✓ Server status tests passed")

def test_for_loop_counting():
    """Test for loop counting logic"""
    servers = [
        {"name": "web-01", "status": "running", "cpu": 45},
        {"name": "web-02", "status": "stopped", "cpu": 0},
        {"name": "db-01", "status": "running", "cpu": 78},
    ]
    
    running = sum(1 for s in servers if s["status"] == "running")
    assert running == 2
    
    high_cpu = [s["name"] for s in servers if s["cpu"] > 70]
    assert high_cpu == ["db-01"]
    print("✓ For loop counting tests passed")

def test_log_filter():
    """Test log filtering function"""
    logs = [
        {"level": "DEBUG", "message": "debug"},
        {"level": "INFO", "message": "info"},
        {"level": "WARNING", "message": "warning"},
        {"level": "ERROR", "message": "error"},
    ]
    
    # Filter at WARNING level
    filtered = filter_logs(logs, "WARNING")
    assert len(filtered) == 2
    assert all(log["level"] in ["WARNING", "ERROR"] for log in filtered)
    
    # Filter at DEBUG level (all logs)
    filtered = filter_logs(logs, "DEBUG")
    assert len(filtered) == 4
    
    # Filter at ERROR level
    filtered = filter_logs(logs, "ERROR")
    assert len(filtered) == 1
    assert filtered[0]["level"] == "ERROR"
    print("✓ Log filter tests passed")

if __name__ == "__main__":
    test_server_status()
    test_for_loop_counting()
    test_log_filter()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_control_flow.py
```

## Additional Resources

- [Python Control Flow Documentation](https://docs.python.org/3/tutorial/controlflow.html)
- [Python For Loops](https://docs.python.org/3/tutorial/controlflow.html#for-statements)
- [Python While Loops](https://docs.python.org/3/reference/compound_stmts.html#while)
