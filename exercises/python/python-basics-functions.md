# Python Basics: Functions

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Python variables, data types, and control flow

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to write reusable Python functions with parameters, return values, and proper scope management. Functions are the building blocks of maintainable DevOps scripts and automation tools.

## Instructions

### Part 1: Basic Functions

Create a file called `functions.py` in the workspace directory.

1. Write a function `format_bytes(bytes_value)` that:
   - Takes a number of bytes as input
   - Returns a human-readable string (KB, MB, GB)
   - Example: `format_bytes(1536)` returns "1.50 KB"
   - Example: `format_bytes(1048576)` returns "1.00 MB"

2. Write a function `validate_port(port)` that:
   - Returns True if port is between 1 and 65535
   - Returns False otherwise
   - Handle non-integer inputs gracefully

### Part 2: Functions with Multiple Parameters

3. Write a function `create_connection_string(host, port, database, user=None, password=None)` that:
   - Takes required parameters: host, port, database
   - Takes optional parameters: user, password (default to None)
   - Returns a connection string in format: `host:port/database`
   - If user is provided: `user@host:port/database`
   - If both user and password: `user:password@host:port/database`

4. Write a function `calculate_resource_usage(*values, operation="average")` that:
   - Accepts any number of numeric values using *args
   - Supports operations: "average", "sum", "max", "min"
   - Returns the calculated result

### Part 3: Functions Returning Multiple Values

5. Write a function `parse_log_line(log_line)` that:
   - Takes a log line in format: `"2024-01-15 10:30:45 ERROR Database connection failed"`
   - Returns a tuple: (timestamp, level, message)
   - Example return: `("2024-01-15 10:30:45", "ERROR", "Database connection failed")`

6. Write a function `analyze_servers(servers)` that:
   - Takes a list of server dictionaries with "name", "status", "cpu" keys
   - Returns a dictionary with:
     - "total": total server count
     - "running": count of running servers
     - "avg_cpu": average CPU of running servers
     - "high_cpu": list of server names with CPU > 80

### Part 4: Challenge - Decorator Function

7. Write a decorator function `log_execution(func)` that:
   - Prints when a function starts executing
   - Prints when a function finishes
   - Prints the return value
   - Works with any function

8. Apply the decorator to a function `deploy_service(service_name, version)` that:
   - Simulates a deployment (just returns a status message)
   - Returns: `"Deployed {service_name} v{version} successfully"`

## Expected Output

```
=== Part 1: Basic Functions ===
1536 bytes = 1.50 KB
1048576 bytes = 1.00 MB
1073741824 bytes = 1.00 GB
Port 8080 valid: True
Port 70000 valid: False
Port 'abc' valid: False

=== Part 2: Multiple Parameters ===
Basic: localhost:5432/mydb
With user: admin@localhost:5432/mydb
With credentials: admin:secret@localhost:5432/mydb
Average of [10, 20, 30, 40]: 25.0
Sum of [10, 20, 30, 40]: 100
Max of [10, 20, 30, 40]: 40

=== Part 3: Multiple Return Values ===
Timestamp: 2024-01-15 10:30:45
Level: ERROR
Message: Database connection failed
Server Analysis:
  Total: 4
  Running: 3
  Avg CPU: 65.00%
  High CPU: ['cache-01']

=== Part 4: Decorator Challenge ===
[LOG] Starting: deploy_service
[LOG] Finished: deploy_service
[LOG] Result: Deployed nginx v2.0.1 successfully
Deployment result: Deployed nginx v2.0.1 successfully
```

## Verification Steps

Run your script:
```bash
cd /workspace
python functions.py
```

1. Byte formatting handles KB, MB, GB correctly
2. Port validation handles edge cases and invalid input
3. Connection string builds correctly with optional parameters
4. Variable arguments function works with different operations
5. Log parsing extracts all three components
6. Server analysis returns correct statistics
7. Decorator logs function execution properly

## Hints

<details>
<summary>Hint 1: Byte Conversion</summary>

Use division and thresholds:
```python
if bytes_value >= 1024**3:
    return f"{bytes_value / 1024**3:.2f} GB"
elif bytes_value >= 1024**2:
    return f"{bytes_value / 1024**2:.2f} MB"
# etc.
```
</details>

<details>
<summary>Hint 2: Default Parameters</summary>

Default parameters must come after required ones:
```python
def func(required1, required2, optional1=None, optional2="default"):
    pass
```
</details>

<details>
<summary>Hint 3: Variable Arguments</summary>

Use `*args` to accept any number of positional arguments:
```python
def my_func(*values):
    for value in values:
        print(value)
```
</details>

<details>
<summary>Hint 4: Decorators</summary>

A decorator wraps a function:
```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        # Before function
        result = func(*args, **kwargs)
        # After function
        return result
    return wrapper

@my_decorator
def my_function():
    pass
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
Python Basics: Functions
DevOps Interview Playground Exercise
"""

# === Part 1: Basic Functions ===
print("=== Part 1: Basic Functions ===")

def format_bytes(bytes_value):
    """Convert bytes to human-readable format."""
    if bytes_value >= 1024**3:
        return f"{bytes_value / 1024**3:.2f} GB"
    elif bytes_value >= 1024**2:
        return f"{bytes_value / 1024**2:.2f} MB"
    elif bytes_value >= 1024:
        return f"{bytes_value / 1024:.2f} KB"
    else:
        return f"{bytes_value} B"

def validate_port(port):
    """Validate if port number is valid."""
    try:
        port_num = int(port)
        return 1 <= port_num <= 65535
    except (ValueError, TypeError):
        return False

# Test basic functions
print(f"1536 bytes = {format_bytes(1536)}")
print(f"1048576 bytes = {format_bytes(1048576)}")
print(f"1073741824 bytes = {format_bytes(1073741824)}")
print(f"Port 8080 valid: {validate_port(8080)}")
print(f"Port 70000 valid: {validate_port(70000)}")
print(f"Port 'abc' valid: {validate_port('abc')}")

# === Part 2: Multiple Parameters ===
print("\n=== Part 2: Multiple Parameters ===")

def create_connection_string(host, port, database, user=None, password=None):
    """Create a database connection string."""
    base = f"{host}:{port}/{database}"
    
    if user and password:
        return f"{user}:{password}@{base}"
    elif user:
        return f"{user}@{base}"
    else:
        return base

def calculate_resource_usage(*values, operation="average"):
    """Calculate statistics on resource values."""
    if not values:
        return 0
    
    if operation == "average":
        return sum(values) / len(values)
    elif operation == "sum":
        return sum(values)
    elif operation == "max":
        return max(values)
    elif operation == "min":
        return min(values)
    else:
        raise ValueError(f"Unknown operation: {operation}")

# Test multiple parameters
print(f"Basic: {create_connection_string('localhost', 5432, 'mydb')}")
print(f"With user: {create_connection_string('localhost', 5432, 'mydb', user='admin')}")
print(f"With credentials: {create_connection_string('localhost', 5432, 'mydb', user='admin', password='secret')}")

values = [10, 20, 30, 40]
print(f"Average of {values}: {calculate_resource_usage(*values, operation='average')}")
print(f"Sum of {values}: {calculate_resource_usage(*values, operation='sum')}")
print(f"Max of {values}: {calculate_resource_usage(*values, operation='max')}")

# === Part 3: Multiple Return Values ===
print("\n=== Part 3: Multiple Return Values ===")

def parse_log_line(log_line):
    """Parse a log line into components."""
    parts = log_line.split(" ", 3)
    if len(parts) >= 4:
        timestamp = f"{parts[0]} {parts[1]}"
        level = parts[2]
        message = parts[3]
        return timestamp, level, message
    return None, None, None

def analyze_servers(servers):
    """Analyze server statistics."""
    total = len(servers)
    running_servers = [s for s in servers if s["status"] == "running"]
    running = len(running_servers)
    
    if running > 0:
        avg_cpu = sum(s["cpu"] for s in running_servers) / running
    else:
        avg_cpu = 0
    
    high_cpu = [s["name"] for s in servers if s["cpu"] > 80]
    
    return {
        "total": total,
        "running": running,
        "avg_cpu": avg_cpu,
        "high_cpu": high_cpu
    }

# Test multiple return values
log_line = "2024-01-15 10:30:45 ERROR Database connection failed"
timestamp, level, message = parse_log_line(log_line)
print(f"Timestamp: {timestamp}")
print(f"Level: {level}")
print(f"Message: {message}")

servers = [
    {"name": "web-01", "status": "running", "cpu": 45},
    {"name": "web-02", "status": "stopped", "cpu": 0},
    {"name": "db-01", "status": "running", "cpu": 65},
    {"name": "cache-01", "status": "running", "cpu": 85},
]

analysis = analyze_servers(servers)
print("Server Analysis:")
print(f"  Total: {analysis['total']}")
print(f"  Running: {analysis['running']}")
print(f"  Avg CPU: {analysis['avg_cpu']:.2f}%")
print(f"  High CPU: {analysis['high_cpu']}")

# === Part 4: Decorator Challenge ===
print("\n=== Part 4: Decorator Challenge ===")

def log_execution(func):
    """Decorator that logs function execution."""
    def wrapper(*args, **kwargs):
        print(f"[LOG] Starting: {func.__name__}")
        result = func(*args, **kwargs)
        print(f"[LOG] Finished: {func.__name__}")
        print(f"[LOG] Result: {result}")
        return result
    return wrapper

@log_execution
def deploy_service(service_name, version):
    """Simulate deploying a service."""
    return f"Deployed {service_name} v{version} successfully"

# Test decorator
result = deploy_service("nginx", "2.0.1")
print(f"Deployment result: {result}")
```

### Explanation

**Basic Functions:**
- Functions are defined with `def function_name(parameters):`
- Use `return` to send back a value
- Functions without return implicitly return `None`

**Default Parameters:**
- Parameters with `=value` are optional
- Must come after required parameters
- Check with `if param:` or `if param is not None:`

**Variable Arguments (*args):**
- `*args` collects extra positional arguments into a tuple
- Unpack a list into arguments with `*list`
- Useful for functions that accept any number of inputs

**Multiple Return Values:**
- Return multiple values as a tuple: `return a, b, c`
- Unpack with: `x, y, z = function()`
- Can also return a dictionary for named values

**Decorators:**
- A decorator is a function that wraps another function
- Use `@decorator` syntax above function definition
- The wrapper function calls the original and can add behavior
- `*args, **kwargs` allows wrapping any function signature

</details>

## Test Cases

Save this as `test_functions.py`:

```python
#!/usr/bin/env python3
"""Test cases for functions exercise"""

def format_bytes(bytes_value):
    if bytes_value >= 1024**3:
        return f"{bytes_value / 1024**3:.2f} GB"
    elif bytes_value >= 1024**2:
        return f"{bytes_value / 1024**2:.2f} MB"
    elif bytes_value >= 1024:
        return f"{bytes_value / 1024:.2f} KB"
    else:
        return f"{bytes_value} B"

def validate_port(port):
    try:
        port_num = int(port)
        return 1 <= port_num <= 65535
    except (ValueError, TypeError):
        return False

def create_connection_string(host, port, database, user=None, password=None):
    base = f"{host}:{port}/{database}"
    if user and password:
        return f"{user}:{password}@{base}"
    elif user:
        return f"{user}@{base}"
    return base

def parse_log_line(log_line):
    parts = log_line.split(" ", 3)
    if len(parts) >= 4:
        return f"{parts[0]} {parts[1]}", parts[2], parts[3]
    return None, None, None

def test_format_bytes():
    """Test byte formatting function"""
    assert format_bytes(512) == "512 B"
    assert format_bytes(1024) == "1.00 KB"
    assert format_bytes(1536) == "1.50 KB"
    assert format_bytes(1048576) == "1.00 MB"
    assert format_bytes(1073741824) == "1.00 GB"
    print("✓ Format bytes tests passed")

def test_validate_port():
    """Test port validation function"""
    assert validate_port(80) == True
    assert validate_port(8080) == True
    assert validate_port(65535) == True
    assert validate_port(1) == True
    assert validate_port(0) == False
    assert validate_port(65536) == False
    assert validate_port(-1) == False
    assert validate_port("abc") == False
    assert validate_port(None) == False
    print("✓ Validate port tests passed")

def test_connection_string():
    """Test connection string builder"""
    assert create_connection_string("localhost", 5432, "db") == "localhost:5432/db"
    assert create_connection_string("localhost", 5432, "db", user="admin") == "admin@localhost:5432/db"
    assert create_connection_string("localhost", 5432, "db", user="admin", password="pass") == "admin:pass@localhost:5432/db"
    print("✓ Connection string tests passed")

def test_parse_log_line():
    """Test log line parsing"""
    timestamp, level, message = parse_log_line("2024-01-15 10:30:45 ERROR Database failed")
    assert timestamp == "2024-01-15 10:30:45"
    assert level == "ERROR"
    assert message == "Database failed"
    print("✓ Parse log line tests passed")

if __name__ == "__main__":
    test_format_bytes()
    test_validate_port()
    test_connection_string()
    test_parse_log_line()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_functions.py
```

## Additional Resources

- [Python Functions Documentation](https://docs.python.org/3/tutorial/controlflow.html#defining-functions)
- [Python *args and **kwargs](https://docs.python.org/3/tutorial/controlflow.html#arbitrary-argument-lists)
- [Python Decorators](https://docs.python.org/3/glossary.html#term-decorator)
