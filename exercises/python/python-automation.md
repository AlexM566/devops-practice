# Python DevOps: Automation Scripts

**Difficulty:** Intermediate
**Estimated Time:** 40 minutes
**Prerequisites:** Python basics, subprocess module, error handling

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to write automation scripts using Python's subprocess module for executing system commands, managing processes, and building health check systems. These skills are essential for DevOps automation and infrastructure management.

## Instructions

### Part 1: Running System Commands

Create a file called `automation.py` in the workspace directory.

1. Write a function `run_command(command, timeout=30)` that:
   - Executes a shell command using subprocess
   - Returns a dict with: stdout, stderr, return_code, success
   - Handles timeouts gracefully
   - Captures both stdout and stderr

2. Write a function `run_command_stream(command)` that:
   - Executes a command and streams output line by line
   - Yields each line as it's produced
   - Useful for long-running commands

### Part 2: Service Health Checks

3. Write a function `check_port(host, port, timeout=5)` that:
   - Checks if a TCP port is open
   - Returns True if connection succeeds, False otherwise
   - Uses socket module

4. Write a function `check_http_endpoint(url, expected_status=200, timeout=5)` that:
   - Makes an HTTP GET request
   - Returns dict with: healthy, status_code, response_time_ms
   - Handles connection errors

5. Write a function `check_disk_space(path="/", threshold=90)` that:
   - Checks disk usage for a path
   - Returns dict with: total_gb, used_gb, free_gb, percent_used, alert
   - alert is True if usage exceeds threshold

### Part 3: Process Management

6. Write a function `find_process(name)` that:
   - Finds processes matching a name pattern
   - Returns list of dicts with: pid, name, cpu_percent, memory_percent
   - Uses `ps` command or psutil if available

7. Write a function `kill_process(pid, signal="TERM")` that:
   - Sends a signal to a process
   - Returns True if successful, False otherwise
   - Supports TERM, KILL, HUP signals

### Part 4: Challenge - Health Check System

8. Create a `HealthChecker` class that:
   - Constructor takes a list of check configurations
   - Method `run_all()` executes all checks and returns results
   - Method `run_check(name)` runs a specific check
   - Method `get_status()` returns overall health status
   - Method `to_json()` exports results as JSON

9. Support these check types:
   - "port": Check if port is open
   - "http": Check HTTP endpoint
   - "command": Run command and check exit code
   - "disk": Check disk space

10. Implement retry logic and alerting:
    - Retry failed checks up to 3 times
    - Method `get_alerts()` returns list of failing checks
    - Method `watch(interval=60)` continuously monitors (generator)

## Expected Output

```
=== Part 1: Running Commands ===
Command 'echo hello': {'stdout': 'hello\n', 'stderr': '', 'return_code': 0, 'success': True}
Command 'ls /nonexistent': {'stdout': '', 'stderr': '...', 'return_code': 2, 'success': False}

Streaming output:
  Line: total 0
  Line: drwxr-xr-x  2 root root 40 Jan 15 10:00 .
  ...

=== Part 2: Health Checks ===
Port 80 on localhost: True
HTTP check http://web-app:3000: {'healthy': True, 'status_code': 200, 'response_time_ms': 45}
Disk space /: {'total_gb': 50.0, 'used_gb': 25.0, 'free_gb': 25.0, 'percent_used': 50.0, 'alert': False}

=== Part 3: Process Management ===
Found processes matching 'python': [{'pid': 1234, 'name': 'python', 'cpu': 0.5, 'memory': 1.2}]

=== Part 4: Health Check System ===
Running all health checks...
  ✓ web-app-port: healthy
  ✓ web-app-http: healthy
  ✗ redis-port: unhealthy
  ✓ disk-root: healthy

Overall status: DEGRADED
Alerts: ['redis-port']
```

## Verification Steps

Run your script:
```bash
cd /workspace
python automation.py
```

1. Commands execute and capture output correctly
2. Streaming output works for long commands
3. Port checks correctly identify open/closed ports
4. HTTP checks return accurate status
5. Disk space calculation is correct
6. Process finding works with pattern matching
7. HealthChecker runs all checks and reports status

## Hints

<details>
<summary>Hint 1: subprocess.run</summary>

```python
import subprocess

result = subprocess.run(
    ["ls", "-la"],
    capture_output=True,
    text=True,
    timeout=30
)
print(result.stdout)
print(result.returncode)
```
</details>

<details>
<summary>Hint 2: Socket Port Check</summary>

```python
import socket

def check_port(host, port, timeout=5):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    try:
        sock.connect((host, port))
        return True
    except (socket.timeout, socket.error):
        return False
    finally:
        sock.close()
```
</details>

<details>
<summary>Hint 3: Disk Space</summary>

```python
import shutil

usage = shutil.disk_usage("/")
total_gb = usage.total / (1024**3)
used_gb = usage.used / (1024**3)
free_gb = usage.free / (1024**3)
```
</details>

<details>
<summary>Hint 4: Streaming Output</summary>

```python
import subprocess

def stream_command(command):
    process = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    for line in process.stdout:
        yield line.strip()
    process.wait()
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
Python DevOps: Automation Scripts
DevOps Interview Playground Exercise
"""

import subprocess
import socket
import shutil
import os
import json
import time
import signal
import requests
from datetime import datetime

# === Part 1: Running Commands ===
print("=== Part 1: Running Commands ===")

def run_command(command, timeout=30, shell=True):
    """Execute a shell command and capture output."""
    try:
        result = subprocess.run(
            command,
            shell=shell,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return {
            "stdout": result.stdout,
            "stderr": result.stderr,
            "return_code": result.returncode,
            "success": result.returncode == 0
        }
    except subprocess.TimeoutExpired:
        return {
            "stdout": "",
            "stderr": f"Command timed out after {timeout} seconds",
            "return_code": -1,
            "success": False
        }
    except Exception as e:
        return {
            "stdout": "",
            "stderr": str(e),
            "return_code": -1,
            "success": False
        }

def run_command_stream(command):
    """Execute a command and stream output line by line."""
    process = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    
    for line in process.stdout:
        yield line.rstrip('\n')
    
    process.wait()

# Test commands
result = run_command("echo hello")
print(f"Command 'echo hello': {result}")

result = run_command("ls /nonexistent 2>&1")
print(f"Command 'ls /nonexistent': success={result['success']}")

print("\nStreaming output:")
for line in run_command_stream("ls -la /tmp | head -5"):
    print(f"  Line: {line}")

# === Part 2: Health Checks ===
print("\n=== Part 2: Health Checks ===")

def check_port(host, port, timeout=5):
    """Check if a TCP port is open."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    try:
        sock.connect((host, port))
        return True
    except (socket.timeout, socket.error, OSError):
        return False
    finally:
        sock.close()

def check_http_endpoint(url, expected_status=200, timeout=5):
    """Check an HTTP endpoint health."""
    try:
        start_time = time.time()
        response = requests.get(url, timeout=timeout)
        elapsed_ms = (time.time() - start_time) * 1000
        
        return {
            "healthy": response.status_code == expected_status,
            "status_code": response.status_code,
            "response_time_ms": round(elapsed_ms, 2)
        }
    except requests.ConnectionError:
        return {
            "healthy": False,
            "status_code": 0,
            "response_time_ms": 0,
            "error": "Connection failed"
        }
    except requests.Timeout:
        return {
            "healthy": False,
            "status_code": 0,
            "response_time_ms": timeout * 1000,
            "error": "Request timed out"
        }

def check_disk_space(path="/", threshold=90):
    """Check disk space usage."""
    try:
        usage = shutil.disk_usage(path)
        total_gb = usage.total / (1024**3)
        used_gb = usage.used / (1024**3)
        free_gb = usage.free / (1024**3)
        percent_used = (usage.used / usage.total) * 100
        
        return {
            "total_gb": round(total_gb, 2),
            "used_gb": round(used_gb, 2),
            "free_gb": round(free_gb, 2),
            "percent_used": round(percent_used, 2),
            "alert": percent_used > threshold
        }
    except OSError as e:
        return {
            "error": str(e),
            "alert": True
        }

# Test health checks
print(f"Port 22 on localhost: {check_port('localhost', 22)}")
print(f"Port 9999 on localhost: {check_port('localhost', 9999)}")

# HTTP check (may fail if service not running)
http_result = check_http_endpoint("http://localhost:3000")
print(f"HTTP check localhost:3000: {http_result}")

disk_result = check_disk_space("/")
print(f"Disk space /: {disk_result}")

# === Part 3: Process Management ===
print("\n=== Part 3: Process Management ===")

def find_process(name):
    """Find processes matching a name pattern."""
    processes = []
    
    try:
        # Use ps command to find processes
        result = run_command(f"ps aux | grep -i '{name}' | grep -v grep")
        
        if result["success"] and result["stdout"]:
            for line in result["stdout"].strip().split('\n'):
                parts = line.split()
                if len(parts) >= 11:
                    processes.append({
                        "pid": int(parts[1]),
                        "user": parts[0],
                        "cpu": float(parts[2]),
                        "memory": float(parts[3]),
                        "command": ' '.join(parts[10:])
                    })
    except Exception as e:
        print(f"Error finding processes: {e}")
    
    return processes

def kill_process(pid, sig="TERM"):
    """Send a signal to a process."""
    signal_map = {
        "TERM": signal.SIGTERM,
        "KILL": signal.SIGKILL,
        "HUP": signal.SIGHUP,
        "INT": signal.SIGINT
    }
    
    sig_num = signal_map.get(sig.upper(), signal.SIGTERM)
    
    try:
        os.kill(pid, sig_num)
        return True
    except ProcessLookupError:
        print(f"Process {pid} not found")
        return False
    except PermissionError:
        print(f"Permission denied to kill process {pid}")
        return False

# Test process management
python_procs = find_process("python")
print(f"Found {len(python_procs)} Python processes")
if python_procs:
    print(f"First process: PID={python_procs[0]['pid']}, CPU={python_procs[0]['cpu']}%")

# === Part 4: Health Check System ===
print("\n=== Part 4: Health Check System ===")

class HealthChecker:
    """Comprehensive health check system."""
    
    def __init__(self, checks):
        """Initialize with check configurations."""
        self.checks = checks
        self.results = {}
        self.last_run = None
    
    def _run_single_check(self, check):
        """Run a single health check."""
        check_type = check.get("type")
        name = check.get("name", "unnamed")
        
        try:
            if check_type == "port":
                host = check.get("host", "localhost")
                port = check.get("port")
                timeout = check.get("timeout", 5)
                healthy = check_port(host, port, timeout)
                return {"healthy": healthy, "type": "port", "host": host, "port": port}
            
            elif check_type == "http":
                url = check.get("url")
                expected = check.get("expected_status", 200)
                timeout = check.get("timeout", 5)
                result = check_http_endpoint(url, expected, timeout)
                return result
            
            elif check_type == "command":
                command = check.get("command")
                result = run_command(command, timeout=check.get("timeout", 30))
                return {
                    "healthy": result["success"],
                    "type": "command",
                    "return_code": result["return_code"],
                    "output": result["stdout"][:200]  # Truncate output
                }
            
            elif check_type == "disk":
                path = check.get("path", "/")
                threshold = check.get("threshold", 90)
                result = check_disk_space(path, threshold)
                result["healthy"] = not result.get("alert", True)
                return result
            
            else:
                return {"healthy": False, "error": f"Unknown check type: {check_type}"}
        
        except Exception as e:
            return {"healthy": False, "error": str(e)}
    
    def run_check(self, name, retries=3):
        """Run a specific check with retries."""
        check = next((c for c in self.checks if c.get("name") == name), None)
        
        if not check:
            return {"healthy": False, "error": f"Check '{name}' not found"}
        
        for attempt in range(retries):
            result = self._run_single_check(check)
            if result.get("healthy"):
                result["attempts"] = attempt + 1
                self.results[name] = result
                return result
            
            if attempt < retries - 1:
                time.sleep(1)  # Wait before retry
        
        result["attempts"] = retries
        self.results[name] = result
        return result
    
    def run_all(self, retries=3):
        """Run all health checks."""
        self.last_run = datetime.now()
        
        print("Running all health checks...")
        for check in self.checks:
            name = check.get("name", "unnamed")
            result = self.run_check(name, retries)
            status = "✓" if result.get("healthy") else "✗"
            health = "healthy" if result.get("healthy") else "unhealthy"
            print(f"  {status} {name}: {health}")
        
        return self.results
    
    def get_status(self):
        """Get overall health status."""
        if not self.results:
            return "UNKNOWN"
        
        healthy_count = sum(1 for r in self.results.values() if r.get("healthy"))
        total_count = len(self.results)
        
        if healthy_count == total_count:
            return "HEALTHY"
        elif healthy_count == 0:
            return "UNHEALTHY"
        else:
            return "DEGRADED"
    
    def get_alerts(self):
        """Get list of failing checks."""
        return [
            name for name, result in self.results.items()
            if not result.get("healthy")
        ]
    
    def to_json(self):
        """Export results as JSON."""
        return json.dumps({
            "status": self.get_status(),
            "last_run": self.last_run.isoformat() if self.last_run else None,
            "checks": self.results,
            "alerts": self.get_alerts()
        }, indent=2)
    
    def watch(self, interval=60):
        """Continuously monitor health (generator)."""
        while True:
            self.run_all()
            yield {
                "timestamp": datetime.now().isoformat(),
                "status": self.get_status(),
                "alerts": self.get_alerts()
            }
            time.sleep(interval)

# Test HealthChecker
checks = [
    {"name": "localhost-ssh", "type": "port", "host": "localhost", "port": 22},
    {"name": "localhost-http", "type": "port", "host": "localhost", "port": 80},
    {"name": "disk-root", "type": "disk", "path": "/", "threshold": 90},
    {"name": "echo-test", "type": "command", "command": "echo 'health check'"},
]

checker = HealthChecker(checks)
checker.run_all(retries=1)

print(f"\nOverall status: {checker.get_status()}")
print(f"Alerts: {checker.get_alerts()}")

# Export as JSON
print("\nJSON output:")
print(checker.to_json())
```

### Explanation

**subprocess Module:**
- `subprocess.run()` - Run command and wait for completion
- `subprocess.Popen()` - Start process for streaming output
- `capture_output=True` - Capture stdout and stderr
- `text=True` - Return strings instead of bytes
- `shell=True` - Run through shell (use carefully)

**Socket Port Checking:**
- Create TCP socket with `socket.socket()`
- Set timeout to avoid hanging
- `connect()` returns immediately if port is open
- Always close socket in finally block

**Disk Space:**
- `shutil.disk_usage()` returns named tuple
- Convert bytes to GB for readability
- Calculate percentage for threshold alerts

**Process Management:**
- Parse `ps aux` output for process info
- `os.kill()` sends signals to processes
- Handle permission and not-found errors

**Health Check Patterns:**
- Retry logic for transient failures
- Aggregate status (HEALTHY/DEGRADED/UNHEALTHY)
- JSON export for monitoring systems
- Generator pattern for continuous monitoring

**Best Practices:**
- Always set timeouts on network operations
- Handle all exception types gracefully
- Log errors for debugging
- Use retries for transient failures
- Avoid shell=True when possible (security)

</details>

## Test Cases

Save this as `test_automation.py`:

```python
#!/usr/bin/env python3
"""Test cases for automation exercise"""

import subprocess
import socket
import shutil

def run_command(command, timeout=30):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=timeout)
        return {"stdout": result.stdout, "stderr": result.stderr, "return_code": result.returncode, "success": result.returncode == 0}
    except subprocess.TimeoutExpired:
        return {"stdout": "", "stderr": "Timeout", "return_code": -1, "success": False}

def check_port(host, port, timeout=5):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    try:
        sock.connect((host, port))
        return True
    except (socket.timeout, socket.error, OSError):
        return False
    finally:
        sock.close()

def check_disk_space(path="/", threshold=90):
    usage = shutil.disk_usage(path)
    percent_used = (usage.used / usage.total) * 100
    return {
        "total_gb": round(usage.total / (1024**3), 2),
        "used_gb": round(usage.used / (1024**3), 2),
        "free_gb": round(usage.free / (1024**3), 2),
        "percent_used": round(percent_used, 2),
        "alert": percent_used > threshold
    }

def test_run_command_success():
    """Test successful command execution"""
    result = run_command("echo 'test'")
    assert result["success"] == True
    assert result["return_code"] == 0
    assert "test" in result["stdout"]
    print("✓ Run command success test passed")

def test_run_command_failure():
    """Test failed command execution"""
    result = run_command("exit 1")
    assert result["success"] == False
    assert result["return_code"] == 1
    print("✓ Run command failure test passed")

def test_check_port_closed():
    """Test checking a closed port"""
    # Port 59999 should be closed on most systems
    result = check_port("localhost", 59999, timeout=1)
    assert result == False
    print("✓ Check closed port test passed")

def test_disk_space():
    """Test disk space check"""
    result = check_disk_space("/")
    
    assert "total_gb" in result
    assert "used_gb" in result
    assert "free_gb" in result
    assert "percent_used" in result
    assert "alert" in result
    
    assert result["total_gb"] > 0
    assert result["used_gb"] >= 0
    assert result["free_gb"] >= 0
    assert 0 <= result["percent_used"] <= 100
    print("✓ Disk space test passed")

def test_disk_space_alert():
    """Test disk space alert threshold"""
    # Test with very low threshold to trigger alert
    result = check_disk_space("/", threshold=1)
    assert result["alert"] == True
    
    # Test with very high threshold to not trigger alert
    result = check_disk_space("/", threshold=99.9)
    assert result["alert"] == False
    print("✓ Disk space alert test passed")

if __name__ == "__main__":
    test_run_command_success()
    test_run_command_failure()
    test_check_port_closed()
    test_disk_space()
    test_disk_space_alert()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_automation.py
```

## Additional Resources

- [Python subprocess Documentation](https://docs.python.org/3/library/subprocess.html)
- [Python socket Documentation](https://docs.python.org/3/library/socket.html)
- [Python shutil Documentation](https://docs.python.org/3/library/shutil.html)
