# Python Basics: Error Handling

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Python functions and control flow

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to handle errors gracefully in Python using try/except blocks, raise custom exceptions, and use finally for cleanup. Proper error handling is critical for robust DevOps scripts that don't crash unexpectedly.

## Instructions

### Part 1: Basic Try/Except

Create a file called `error_handling.py` in the workspace directory.

1. Write a function `safe_divide(a, b)` that:
   - Returns the result of a / b
   - Catches ZeroDivisionError and returns None
   - Prints an error message when division by zero occurs

2. Write a function `parse_config_value(value)` that:
   - Attempts to convert a string to an integer
   - If that fails, tries to convert to a float
   - If both fail, returns the original string
   - Uses multiple except blocks

### Part 2: Catching Specific Exceptions

3. Write a function `read_server_config(filepath)` that:
   - Attempts to read a JSON file
   - Catches FileNotFoundError and returns a default config
   - Catches json.JSONDecodeError and raises a custom error message
   - Returns the parsed JSON on success

4. Write a function `connect_to_service(host, port, timeout=5)` that:
   - Simulates a connection attempt
   - Raises ConnectionError if host is "invalid"
   - Raises TimeoutError if port is 0
   - Raises ValueError if timeout is negative
   - Returns "Connected" on success

### Part 3: Finally and Cleanup

5. Write a function `process_log_file(filepath)` that:
   - Opens a file for reading
   - Counts lines containing "ERROR"
   - Uses finally to ensure the file is always closed
   - Returns the error count

6. Write a context manager approach using `with` statement for the same task

### Part 4: Challenge - Custom Exceptions

7. Create custom exception classes:
   - `ConfigurationError` - for config-related issues
   - `ServiceUnavailableError` - for service connection issues
   - Both should accept a message and optional error code

8. Write a function `validate_deployment_config(config)` that:
   - Takes a dictionary with keys: "service", "version", "replicas"
   - Raises ConfigurationError if any required key is missing
   - Raises ConfigurationError if replicas < 1 or > 10
   - Raises ConfigurationError if version doesn't match pattern "X.Y.Z"
   - Returns True if valid

## Expected Output

```
=== Part 1: Basic Try/Except ===
10 / 2 = 5.0
10 / 0 = Error: Cannot divide by zero
Result: None
Parsing '42': 42 (int)
Parsing '3.14': 3.14 (float)
Parsing 'hello': hello (str)

=== Part 2: Specific Exceptions ===
Config from missing file: {'host': 'localhost', 'port': 8080}
Connection to localhost:8080: Connected
Connection to invalid host: ConnectionError - Invalid host
Connection with timeout 0: TimeoutError - Connection timed out

=== Part 3: Finally and Cleanup ===
Error count (with finally): 3
Error count (with context manager): 3

=== Part 4: Custom Exceptions ===
Valid config: True
Missing key error: ConfigurationError [1001]: Missing required key: replicas
Invalid replicas error: ConfigurationError [1002]: Replicas must be between 1 and 10
Invalid version error: ConfigurationError [1003]: Version must match X.Y.Z pattern
```

## Verification Steps

Run your script:
```bash
cd /workspace
python error_handling.py
```

1. Division by zero is caught and returns None
2. Config parsing tries int, then float, then returns string
3. File operations handle missing files gracefully
4. Custom exceptions include error codes and messages
5. Config validation catches all invalid cases

## Hints

<details>
<summary>Hint 1: Multiple Except Blocks</summary>

Handle different exceptions differently:
```python
try:
    result = risky_operation()
except ValueError:
    print("Invalid value")
except TypeError:
    print("Wrong type")
except Exception as e:
    print(f"Unexpected error: {e}")
```
</details>

<details>
<summary>Hint 2: Re-raising Exceptions</summary>

You can catch, log, and re-raise:
```python
try:
    operation()
except SomeError as e:
    print(f"Error occurred: {e}")
    raise  # Re-raise the same exception
```
</details>

<details>
<summary>Hint 3: Custom Exception Classes</summary>

Create custom exceptions by inheriting from Exception:
```python
class MyError(Exception):
    def __init__(self, message, code=None):
        super().__init__(message)
        self.code = code
```
</details>

<details>
<summary>Hint 4: Version Pattern Matching</summary>

Use a simple check or regex:
```python
import re
pattern = r'^\d+\.\d+\.\d+$'
if not re.match(pattern, version):
    raise ConfigurationError("Invalid version")
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
Python Basics: Error Handling
DevOps Interview Playground Exercise
"""

import json
import re

# === Part 1: Basic Try/Except ===
print("=== Part 1: Basic Try/Except ===")

def safe_divide(a, b):
    """Safely divide two numbers."""
    try:
        return a / b
    except ZeroDivisionError:
        print("Error: Cannot divide by zero")
        return None

def parse_config_value(value):
    """Parse a config value to appropriate type."""
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            return value

# Test basic try/except
print(f"10 / 2 = {safe_divide(10, 2)}")
result = safe_divide(10, 0)
print(f"Result: {result}")

for val in ['42', '3.14', 'hello']:
    parsed = parse_config_value(val)
    print(f"Parsing '{val}': {parsed} ({type(parsed).__name__})")

# === Part 2: Specific Exceptions ===
print("\n=== Part 2: Specific Exceptions ===")

def read_server_config(filepath):
    """Read and parse a JSON config file."""
    default_config = {"host": "localhost", "port": 8080}
    
    try:
        with open(filepath, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Config file not found, using defaults")
        return default_config
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON in config file: {e}")

def connect_to_service(host, port, timeout=5):
    """Simulate connecting to a service."""
    if timeout < 0:
        raise ValueError("Timeout cannot be negative")
    if host == "invalid":
        raise ConnectionError("Invalid host")
    if port == 0:
        raise TimeoutError("Connection timed out")
    return "Connected"

# Test specific exceptions
config = read_server_config("nonexistent.json")
print(f"Config from missing file: {config}")

try:
    result = connect_to_service("localhost", 8080)
    print(f"Connection to localhost:8080: {result}")
except Exception as e:
    print(f"Error: {e}")

try:
    connect_to_service("invalid", 8080)
except ConnectionError as e:
    print(f"Connection to invalid host: ConnectionError - {e}")

try:
    connect_to_service("localhost", 0)
except TimeoutError as e:
    print(f"Connection with timeout 0: TimeoutError - {e}")

# === Part 3: Finally and Cleanup ===
print("\n=== Part 3: Finally and Cleanup ===")

# Create a sample log file for testing
sample_log = """2024-01-15 10:00:00 INFO Server started
2024-01-15 10:01:00 ERROR Connection failed
2024-01-15 10:02:00 INFO Request received
2024-01-15 10:03:00 ERROR Database timeout
2024-01-15 10:04:00 WARNING High memory
2024-01-15 10:05:00 ERROR Disk full
"""

# Write sample log file
with open("/tmp/sample.log", "w") as f:
    f.write(sample_log)

def process_log_file_finally(filepath):
    """Count ERROR lines using try/finally."""
    error_count = 0
    f = None
    try:
        f = open(filepath, 'r')
        for line in f:
            if "ERROR" in line:
                error_count += 1
    except FileNotFoundError:
        print(f"Log file not found: {filepath}")
    finally:
        if f:
            f.close()
    return error_count

def process_log_file_context(filepath):
    """Count ERROR lines using context manager."""
    error_count = 0
    try:
        with open(filepath, 'r') as f:
            for line in f:
                if "ERROR" in line:
                    error_count += 1
    except FileNotFoundError:
        print(f"Log file not found: {filepath}")
    return error_count

# Test both approaches
count1 = process_log_file_finally("/tmp/sample.log")
print(f"Error count (with finally): {count1}")

count2 = process_log_file_context("/tmp/sample.log")
print(f"Error count (with context manager): {count2}")

# === Part 4: Custom Exceptions ===
print("\n=== Part 4: Custom Exceptions ===")

class ConfigurationError(Exception):
    """Custom exception for configuration errors."""
    def __init__(self, message, code=None):
        super().__init__(message)
        self.code = code
    
    def __str__(self):
        if self.code:
            return f"ConfigurationError [{self.code}]: {self.args[0]}"
        return f"ConfigurationError: {self.args[0]}"

class ServiceUnavailableError(Exception):
    """Custom exception for service availability issues."""
    def __init__(self, message, code=None):
        super().__init__(message)
        self.code = code

def validate_deployment_config(config):
    """Validate a deployment configuration."""
    required_keys = ["service", "version", "replicas"]
    
    # Check required keys
    for key in required_keys:
        if key not in config:
            raise ConfigurationError(f"Missing required key: {key}", code=1001)
    
    # Validate replicas
    replicas = config["replicas"]
    if not isinstance(replicas, int) or replicas < 1 or replicas > 10:
        raise ConfigurationError("Replicas must be between 1 and 10", code=1002)
    
    # Validate version format (X.Y.Z)
    version = config["version"]
    if not re.match(r'^\d+\.\d+\.\d+$', version):
        raise ConfigurationError("Version must match X.Y.Z pattern", code=1003)
    
    return True

# Test custom exceptions
valid_config = {"service": "nginx", "version": "1.2.3", "replicas": 3}
try:
    result = validate_deployment_config(valid_config)
    print(f"Valid config: {result}")
except ConfigurationError as e:
    print(e)

# Test missing key
try:
    validate_deployment_config({"service": "nginx", "version": "1.0.0"})
except ConfigurationError as e:
    print(f"Missing key error: {e}")

# Test invalid replicas
try:
    validate_deployment_config({"service": "nginx", "version": "1.0.0", "replicas": 15})
except ConfigurationError as e:
    print(f"Invalid replicas error: {e}")

# Test invalid version
try:
    validate_deployment_config({"service": "nginx", "version": "v1.0", "replicas": 3})
except ConfigurationError as e:
    print(f"Invalid version error: {e}")
```

### Explanation

**Try/Except Basics:**
- Code that might fail goes in `try` block
- Exception handlers go in `except` blocks
- Can have multiple `except` blocks for different exceptions
- `except Exception as e` catches all exceptions and stores in `e`

**Specific Exceptions:**
- Always catch specific exceptions when possible
- Order matters: more specific exceptions first
- Common exceptions: ValueError, TypeError, FileNotFoundError, KeyError

**Finally Block:**
- `finally` always executes, even if exception occurs
- Use for cleanup (closing files, connections, etc.)
- Context managers (`with`) are preferred for resource management

**Custom Exceptions:**
- Inherit from `Exception` or a more specific exception
- Add custom attributes like error codes
- Override `__str__` for custom string representation
- Use descriptive names ending in "Error"

**Best Practices:**
- Don't catch exceptions you can't handle
- Log exceptions before re-raising
- Use specific exception types
- Provide helpful error messages

</details>

## Test Cases

Save this as `test_error_handling.py`:

```python
#!/usr/bin/env python3
"""Test cases for error handling exercise"""

import re

class ConfigurationError(Exception):
    def __init__(self, message, code=None):
        super().__init__(message)
        self.code = code

def safe_divide(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return None

def parse_config_value(value):
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            return value

def validate_deployment_config(config):
    required_keys = ["service", "version", "replicas"]
    for key in required_keys:
        if key not in config:
            raise ConfigurationError(f"Missing required key: {key}", code=1001)
    if not isinstance(config["replicas"], int) or config["replicas"] < 1 or config["replicas"] > 10:
        raise ConfigurationError("Replicas must be between 1 and 10", code=1002)
    if not re.match(r'^\d+\.\d+\.\d+$', config["version"]):
        raise ConfigurationError("Version must match X.Y.Z pattern", code=1003)
    return True

def test_safe_divide():
    """Test safe division function"""
    assert safe_divide(10, 2) == 5.0
    assert safe_divide(10, 0) is None
    assert safe_divide(0, 5) == 0.0
    print("✓ Safe divide tests passed")

def test_parse_config_value():
    """Test config value parsing"""
    assert parse_config_value("42") == 42
    assert isinstance(parse_config_value("42"), int)
    assert parse_config_value("3.14") == 3.14
    assert isinstance(parse_config_value("3.14"), float)
    assert parse_config_value("hello") == "hello"
    assert isinstance(parse_config_value("hello"), str)
    print("✓ Parse config value tests passed")

def test_validate_deployment_config():
    """Test deployment config validation"""
    # Valid config
    valid = {"service": "nginx", "version": "1.2.3", "replicas": 3}
    assert validate_deployment_config(valid) == True
    
    # Missing key
    try:
        validate_deployment_config({"service": "nginx", "version": "1.0.0"})
        assert False, "Should have raised ConfigurationError"
    except ConfigurationError as e:
        assert e.code == 1001
    
    # Invalid replicas
    try:
        validate_deployment_config({"service": "nginx", "version": "1.0.0", "replicas": 15})
        assert False, "Should have raised ConfigurationError"
    except ConfigurationError as e:
        assert e.code == 1002
    
    # Invalid version
    try:
        validate_deployment_config({"service": "nginx", "version": "v1.0", "replicas": 3})
        assert False, "Should have raised ConfigurationError"
    except ConfigurationError as e:
        assert e.code == 1003
    
    print("✓ Validate deployment config tests passed")

if __name__ == "__main__":
    test_safe_divide()
    test_parse_config_value()
    test_validate_deployment_config()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_error_handling.py
```

## Additional Resources

- [Python Exceptions Documentation](https://docs.python.org/3/tutorial/errors.html)
- [Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)
- [Context Managers](https://docs.python.org/3/reference/datamodel.html#context-managers)
