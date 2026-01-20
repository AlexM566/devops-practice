# Python DevOps: Log Analysis

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Python basics, regular expressions

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to parse, analyze, and extract insights from log files using Python. Log analysis is essential for troubleshooting, monitoring, and understanding system behavior in DevOps.

## Instructions

### Part 1: Basic Log Parsing

Create a file called `log_analysis.py` in the workspace directory.

First, create a sample log file for testing:

```python
SAMPLE_LOGS = """
2024-01-15 10:00:00 INFO [web-server] Server started on port 8080
2024-01-15 10:00:05 DEBUG [web-server] Loading configuration from /etc/app/config.yaml
2024-01-15 10:00:10 INFO [web-server] Connected to database at localhost:5432
2024-01-15 10:01:00 INFO [web-server] Request received: GET /api/users
2024-01-15 10:01:01 DEBUG [web-server] Query executed in 45ms
2024-01-15 10:01:02 INFO [web-server] Response sent: 200 OK
2024-01-15 10:02:00 WARNING [web-server] High memory usage: 85%
2024-01-15 10:03:00 ERROR [web-server] Connection to redis failed: timeout
2024-01-15 10:03:01 INFO [web-server] Retrying redis connection...
2024-01-15 10:03:05 INFO [web-server] Redis connection restored
2024-01-15 10:05:00 ERROR [web-server] Database query failed: connection reset
2024-01-15 10:05:01 ERROR [web-server] Request failed: 500 Internal Server Error
2024-01-15 10:10:00 INFO [web-server] Health check: OK
2024-01-15 10:15:00 WARNING [web-server] Slow query detected: 2500ms
2024-01-15 10:20:00 INFO [web-server] Graceful shutdown initiated
"""
```

1. Write a function `parse_log_line(line)` that:
   - Parses a log line using regex
   - Returns a dict with: timestamp, level, component, message
   - Returns None for invalid lines

2. Write a function `read_log_file(filepath)` that:
   - Reads a log file line by line
   - Parses each line and returns a list of log entries
   - Skips empty lines and invalid entries

### Part 2: Log Filtering and Counting

3. Write a function `filter_by_level(logs, level)` that:
   - Filters logs to only include entries at or above the given level
   - Level priority: DEBUG < INFO < WARNING < ERROR
   - Returns filtered list

4. Write a function `count_by_level(logs)` that:
   - Counts log entries by level
   - Returns a dict like: {"INFO": 10, "ERROR": 2, ...}

5. Write a function `get_time_range(logs)` that:
   - Returns the earliest and latest timestamps
   - Returns tuple: (start_time, end_time)

### Part 3: Pattern Analysis

6. Write a function `find_errors_with_context(logs, context_lines=2)` that:
   - Finds all ERROR entries
   - Includes N lines before and after each error
   - Returns list of error contexts

7. Write a function `extract_metrics(logs)` that:
   - Extracts numeric values from log messages
   - Finds patterns like "45ms", "85%", "2500ms"
   - Returns dict mapping metric type to values list

### Part 4: Challenge - Log Analyzer Class

8. Create a `LogAnalyzer` class that:
   - Constructor takes a log file path or list of log entries
   - Method `summary()` returns overall statistics
   - Method `errors()` returns all error entries with context
   - Method `search(pattern)` finds entries matching regex pattern
   - Method `time_series(interval="minute")` groups logs by time interval
   - Method `top_messages(n=10)` returns most frequent message patterns

9. Implement error rate calculation:
   - Method `error_rate()` returns errors per minute
   - Method `alert_check(threshold=0.1)` returns True if error rate exceeds threshold

## Expected Output

```
=== Part 1: Basic Parsing ===
Parsed entry: {'timestamp': '2024-01-15 10:00:00', 'level': 'INFO', 'component': 'web-server', 'message': 'Server started on port 8080'}
Total entries parsed: 15

=== Part 2: Filtering and Counting ===
Entries at WARNING or above: 4
Log counts by level: {'INFO': 8, 'DEBUG': 2, 'WARNING': 2, 'ERROR': 3}
Time range: 2024-01-15 10:00:00 to 2024-01-15 10:20:00

=== Part 3: Pattern Analysis ===
Error with context:
  [BEFORE] 2024-01-15 10:02:00 WARNING High memory usage: 85%
  [ERROR]  2024-01-15 10:03:00 ERROR Connection to redis failed: timeout
  [AFTER]  2024-01-15 10:03:01 INFO Retrying redis connection...

Extracted metrics:
  Duration: [45, 2500] ms
  Percentage: [85] %

=== Part 4: Log Analyzer ===
Summary:
  Total entries: 15
  Time span: 20 minutes
  Error rate: 0.15 errors/minute
  Most common level: INFO

Top error messages:
  1. Connection to redis failed: timeout
  2. Database query failed: connection reset
  3. Request failed: 500 Internal Server Error
```

## Verification Steps

Run your script:
```bash
cd /workspace
python log_analysis.py
```

1. Log lines are parsed correctly with all fields extracted
2. Filtering by level works with correct priority
3. Counts match expected values
4. Error context includes surrounding lines
5. Metrics are extracted from messages
6. LogAnalyzer provides accurate statistics

## Hints

<details>
<summary>Hint 1: Log Line Regex</summary>

```python
import re

pattern = r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (\w+) \[([^\]]+)\] (.+)$'
match = re.match(pattern, line)
if match:
    timestamp, level, component, message = match.groups()
```
</details>

<details>
<summary>Hint 2: Level Priority</summary>

```python
LEVEL_PRIORITY = {
    "DEBUG": 0,
    "INFO": 1,
    "WARNING": 2,
    "ERROR": 3
}

def filter_by_level(logs, min_level):
    min_priority = LEVEL_PRIORITY[min_level]
    return [log for log in logs if LEVEL_PRIORITY[log["level"]] >= min_priority]
```
</details>

<details>
<summary>Hint 3: Extracting Numbers</summary>

```python
import re

# Find durations like "45ms" or "2500ms"
durations = re.findall(r'(\d+)ms', message)

# Find percentages like "85%"
percentages = re.findall(r'(\d+)%', message)
```
</details>

<details>
<summary>Hint 4: Time Series Grouping</summary>

```python
from datetime import datetime
from collections import defaultdict

def group_by_minute(logs):
    groups = defaultdict(list)
    for log in logs:
        dt = datetime.strptime(log["timestamp"], "%Y-%m-%d %H:%M:%S")
        minute_key = dt.strftime("%Y-%m-%d %H:%M")
        groups[minute_key].append(log)
    return dict(groups)
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
Python DevOps: Log Analysis
DevOps Interview Playground Exercise
"""

import re
from datetime import datetime
from collections import defaultdict, Counter

# Sample log data
SAMPLE_LOGS = """
2024-01-15 10:00:00 INFO [web-server] Server started on port 8080
2024-01-15 10:00:05 DEBUG [web-server] Loading configuration from /etc/app/config.yaml
2024-01-15 10:00:10 INFO [web-server] Connected to database at localhost:5432
2024-01-15 10:01:00 INFO [web-server] Request received: GET /api/users
2024-01-15 10:01:01 DEBUG [web-server] Query executed in 45ms
2024-01-15 10:01:02 INFO [web-server] Response sent: 200 OK
2024-01-15 10:02:00 WARNING [web-server] High memory usage: 85%
2024-01-15 10:03:00 ERROR [web-server] Connection to redis failed: timeout
2024-01-15 10:03:01 INFO [web-server] Retrying redis connection...
2024-01-15 10:03:05 INFO [web-server] Redis connection restored
2024-01-15 10:05:00 ERROR [web-server] Database query failed: connection reset
2024-01-15 10:05:01 ERROR [web-server] Request failed: 500 Internal Server Error
2024-01-15 10:10:00 INFO [web-server] Health check: OK
2024-01-15 10:15:00 WARNING [web-server] Slow query detected: 2500ms
2024-01-15 10:20:00 INFO [web-server] Graceful shutdown initiated
"""

LEVEL_PRIORITY = {
    "DEBUG": 0,
    "INFO": 1,
    "WARNING": 2,
    "ERROR": 3
}

# === Part 1: Basic Parsing ===
print("=== Part 1: Basic Parsing ===")

def parse_log_line(line):
    """Parse a single log line into components."""
    pattern = r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (\w+) \[([^\]]+)\] (.+)$'
    match = re.match(pattern, line.strip())
    
    if match:
        timestamp, level, component, message = match.groups()
        return {
            "timestamp": timestamp,
            "level": level,
            "component": component,
            "message": message
        }
    return None

def read_log_file(filepath):
    """Read and parse a log file."""
    logs = []
    try:
        with open(filepath, 'r') as f:
            for line in f:
                entry = parse_log_line(line)
                if entry:
                    logs.append(entry)
    except FileNotFoundError:
        print(f"File not found: {filepath}")
    return logs

def parse_log_string(log_string):
    """Parse logs from a string."""
    logs = []
    for line in log_string.strip().split('\n'):
        entry = parse_log_line(line)
        if entry:
            logs.append(entry)
    return logs

# Test parsing
logs = parse_log_string(SAMPLE_LOGS)
print(f"Parsed entry: {logs[0]}")
print(f"Total entries parsed: {len(logs)}")

# === Part 2: Filtering and Counting ===
print("\n=== Part 2: Filtering and Counting ===")

def filter_by_level(logs, min_level):
    """Filter logs by minimum level."""
    min_priority = LEVEL_PRIORITY.get(min_level, 0)
    return [
        log for log in logs
        if LEVEL_PRIORITY.get(log["level"], 0) >= min_priority
    ]

def count_by_level(logs):
    """Count logs by level."""
    counts = defaultdict(int)
    for log in logs:
        counts[log["level"]] += 1
    return dict(counts)

def get_time_range(logs):
    """Get the time range of logs."""
    if not logs:
        return None, None
    
    timestamps = [log["timestamp"] for log in logs]
    return min(timestamps), max(timestamps)

# Test filtering and counting
warning_and_above = filter_by_level(logs, "WARNING")
print(f"Entries at WARNING or above: {len(warning_and_above)}")

counts = count_by_level(logs)
print(f"Log counts by level: {counts}")

start_time, end_time = get_time_range(logs)
print(f"Time range: {start_time} to {end_time}")

# === Part 3: Pattern Analysis ===
print("\n=== Part 3: Pattern Analysis ===")

def find_errors_with_context(logs, context_lines=2):
    """Find errors with surrounding context."""
    contexts = []
    
    for i, log in enumerate(logs):
        if log["level"] == "ERROR":
            context = {
                "error": log,
                "before": logs[max(0, i - context_lines):i],
                "after": logs[i + 1:i + 1 + context_lines]
            }
            contexts.append(context)
    
    return contexts

def extract_metrics(logs):
    """Extract numeric metrics from log messages."""
    metrics = {
        "duration_ms": [],
        "percentage": []
    }
    
    for log in logs:
        message = log["message"]
        
        # Find durations (e.g., "45ms", "2500ms")
        durations = re.findall(r'(\d+)ms', message)
        metrics["duration_ms"].extend([int(d) for d in durations])
        
        # Find percentages (e.g., "85%")
        percentages = re.findall(r'(\d+)%', message)
        metrics["percentage"].extend([int(p) for p in percentages])
    
    return metrics

# Test pattern analysis
error_contexts = find_errors_with_context(logs, context_lines=1)
if error_contexts:
    ctx = error_contexts[0]
    print("Error with context:")
    for before in ctx["before"]:
        print(f"  [BEFORE] {before['timestamp']} {before['level']} {before['message']}")
    print(f"  [ERROR]  {ctx['error']['timestamp']} {ctx['error']['level']} {ctx['error']['message']}")
    for after in ctx["after"]:
        print(f"  [AFTER]  {after['timestamp']} {after['level']} {after['message']}")

metrics = extract_metrics(logs)
print(f"\nExtracted metrics:")
print(f"  Duration: {metrics['duration_ms']} ms")
print(f"  Percentage: {metrics['percentage']} %")

# === Part 4: Log Analyzer Class ===
print("\n=== Part 4: Log Analyzer ===")

class LogAnalyzer:
    """Comprehensive log analysis tool."""
    
    def __init__(self, source):
        """Initialize with file path or log entries."""
        if isinstance(source, str):
            if '\n' in source:
                self.logs = parse_log_string(source)
            else:
                self.logs = read_log_file(source)
        else:
            self.logs = source
    
    def summary(self):
        """Get overall log statistics."""
        if not self.logs:
            return {"total": 0}
        
        counts = count_by_level(self.logs)
        start_time, end_time = get_time_range(self.logs)
        
        # Calculate time span in minutes
        if start_time and end_time:
            start_dt = datetime.strptime(start_time, "%Y-%m-%d %H:%M:%S")
            end_dt = datetime.strptime(end_time, "%Y-%m-%d %H:%M:%S")
            time_span_minutes = (end_dt - start_dt).total_seconds() / 60
        else:
            time_span_minutes = 0
        
        # Find most common level
        most_common_level = max(counts, key=counts.get) if counts else None
        
        return {
            "total": len(self.logs),
            "counts_by_level": counts,
            "time_span_minutes": time_span_minutes,
            "start_time": start_time,
            "end_time": end_time,
            "most_common_level": most_common_level,
            "error_rate": self.error_rate()
        }
    
    def errors(self, context_lines=2):
        """Get all errors with context."""
        return find_errors_with_context(self.logs, context_lines)
    
    def search(self, pattern):
        """Search logs by regex pattern."""
        regex = re.compile(pattern, re.IGNORECASE)
        return [
            log for log in self.logs
            if regex.search(log["message"])
        ]
    
    def time_series(self, interval="minute"):
        """Group logs by time interval."""
        groups = defaultdict(list)
        
        for log in self.logs:
            dt = datetime.strptime(log["timestamp"], "%Y-%m-%d %H:%M:%S")
            
            if interval == "minute":
                key = dt.strftime("%Y-%m-%d %H:%M")
            elif interval == "hour":
                key = dt.strftime("%Y-%m-%d %H:00")
            elif interval == "day":
                key = dt.strftime("%Y-%m-%d")
            else:
                key = dt.strftime("%Y-%m-%d %H:%M:%S")
            
            groups[key].append(log)
        
        return dict(groups)
    
    def top_messages(self, n=10):
        """Get most frequent message patterns."""
        # Normalize messages by removing specific values
        normalized = []
        for log in self.logs:
            msg = log["message"]
            # Remove numbers and specific values
            msg = re.sub(r'\d+', 'N', msg)
            msg = re.sub(r'[a-f0-9]{8,}', 'ID', msg)
            normalized.append(msg)
        
        counter = Counter(normalized)
        return counter.most_common(n)
    
    def error_rate(self):
        """Calculate errors per minute."""
        if not self.logs:
            return 0
        
        error_count = sum(1 for log in self.logs if log["level"] == "ERROR")
        start_time, end_time = get_time_range(self.logs)
        
        if start_time and end_time:
            start_dt = datetime.strptime(start_time, "%Y-%m-%d %H:%M:%S")
            end_dt = datetime.strptime(end_time, "%Y-%m-%d %H:%M:%S")
            minutes = max((end_dt - start_dt).total_seconds() / 60, 1)
            return error_count / minutes
        
        return error_count
    
    def alert_check(self, threshold=0.1):
        """Check if error rate exceeds threshold."""
        return self.error_rate() > threshold

# Test LogAnalyzer
analyzer = LogAnalyzer(SAMPLE_LOGS)

summary = analyzer.summary()
print("Summary:")
print(f"  Total entries: {summary['total']}")
print(f"  Time span: {summary['time_span_minutes']:.0f} minutes")
print(f"  Error rate: {summary['error_rate']:.2f} errors/minute")
print(f"  Most common level: {summary['most_common_level']}")

print("\nTop error messages:")
errors = analyzer.errors(context_lines=0)
for i, err in enumerate(errors, 1):
    print(f"  {i}. {err['error']['message']}")

# Search for specific patterns
redis_logs = analyzer.search("redis")
print(f"\nLogs mentioning 'redis': {len(redis_logs)}")

# Check alert threshold
if analyzer.alert_check(threshold=0.1):
    print("\n⚠️ ALERT: Error rate exceeds threshold!")
```

### Explanation

**Log Parsing:**
- Use regex to extract structured data from log lines
- Handle different log formats with flexible patterns
- Skip invalid or empty lines gracefully

**Level Filtering:**
- Define priority order for log levels
- Filter by minimum level for focused analysis
- Count occurrences for quick overview

**Context Analysis:**
- Include surrounding lines for error investigation
- Helps understand what led to errors
- Common pattern in log analysis tools

**Metric Extraction:**
- Use regex to find numeric patterns
- Extract durations, percentages, counts
- Useful for performance analysis

**Time Series:**
- Group logs by time intervals
- Identify patterns and trends
- Calculate rates over time

**Best Practices:**
- Stream large files instead of loading all at once
- Use generators for memory efficiency
- Index logs for faster searching
- Normalize messages for pattern detection

</details>

## Test Cases

Save this as `test_log_analysis.py`:

```python
#!/usr/bin/env python3
"""Test cases for log analysis exercise"""

import re
from collections import defaultdict

LEVEL_PRIORITY = {"DEBUG": 0, "INFO": 1, "WARNING": 2, "ERROR": 3}

def parse_log_line(line):
    pattern = r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (\w+) \[([^\]]+)\] (.+)$'
    match = re.match(pattern, line.strip())
    if match:
        timestamp, level, component, message = match.groups()
        return {"timestamp": timestamp, "level": level, "component": component, "message": message}
    return None

def filter_by_level(logs, min_level):
    min_priority = LEVEL_PRIORITY.get(min_level, 0)
    return [log for log in logs if LEVEL_PRIORITY.get(log["level"], 0) >= min_priority]

def count_by_level(logs):
    counts = defaultdict(int)
    for log in logs:
        counts[log["level"]] += 1
    return dict(counts)

def test_parse_log_line():
    """Test log line parsing"""
    line = "2024-01-15 10:00:00 INFO [web-server] Server started"
    result = parse_log_line(line)
    
    assert result is not None
    assert result["timestamp"] == "2024-01-15 10:00:00"
    assert result["level"] == "INFO"
    assert result["component"] == "web-server"
    assert result["message"] == "Server started"
    print("✓ Parse log line test passed")

def test_parse_invalid_line():
    """Test parsing invalid log lines"""
    assert parse_log_line("") is None
    assert parse_log_line("invalid log line") is None
    assert parse_log_line("   ") is None
    print("✓ Parse invalid line test passed")

def test_filter_by_level():
    """Test level filtering"""
    logs = [
        {"level": "DEBUG", "message": "debug"},
        {"level": "INFO", "message": "info"},
        {"level": "WARNING", "message": "warning"},
        {"level": "ERROR", "message": "error"},
    ]
    
    # Filter at WARNING
    filtered = filter_by_level(logs, "WARNING")
    assert len(filtered) == 2
    assert all(log["level"] in ["WARNING", "ERROR"] for log in filtered)
    
    # Filter at DEBUG (all logs)
    filtered = filter_by_level(logs, "DEBUG")
    assert len(filtered) == 4
    
    # Filter at ERROR
    filtered = filter_by_level(logs, "ERROR")
    assert len(filtered) == 1
    print("✓ Filter by level test passed")

def test_count_by_level():
    """Test level counting"""
    logs = [
        {"level": "INFO"},
        {"level": "INFO"},
        {"level": "ERROR"},
        {"level": "WARNING"},
        {"level": "INFO"},
    ]
    
    counts = count_by_level(logs)
    assert counts["INFO"] == 3
    assert counts["ERROR"] == 1
    assert counts["WARNING"] == 1
    print("✓ Count by level test passed")

def test_extract_metrics():
    """Test metric extraction from messages"""
    messages = [
        "Query executed in 45ms",
        "High memory usage: 85%",
        "Slow query detected: 2500ms"
    ]
    
    durations = []
    percentages = []
    
    for msg in messages:
        durations.extend([int(d) for d in re.findall(r'(\d+)ms', msg)])
        percentages.extend([int(p) for p in re.findall(r'(\d+)%', msg)])
    
    assert 45 in durations
    assert 2500 in durations
    assert 85 in percentages
    print("✓ Extract metrics test passed")

if __name__ == "__main__":
    test_parse_log_line()
    test_parse_invalid_line()
    test_filter_by_level()
    test_count_by_level()
    test_extract_metrics()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_log_analysis.py
```

## Additional Resources

- [Python re Module Documentation](https://docs.python.org/3/library/re.html)
- [Python datetime Module](https://docs.python.org/3/library/datetime.html)
- [Log Analysis Best Practices](https://www.loggly.com/ultimate-guide/analyzing-log-data/)
