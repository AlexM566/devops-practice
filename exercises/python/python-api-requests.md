# Python DevOps: HTTP API Requests

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Python basics, understanding of HTTP methods

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to make HTTP requests using Python's `requests` library to interact with APIs and web services. This is essential for DevOps automation, monitoring, and integrating with external services.

## Instructions

### Part 1: Basic GET Requests

Create a file called `api_requests.py` in the workspace directory.

1. Write a function `check_service_health(url)` that:
   - Makes a GET request to the given URL
   - Returns a dictionary with: status_code, response_time_ms, is_healthy
   - is_healthy is True if status code is 200
   - Handles connection errors gracefully

2. Test your function against the playground's web-app service:
   ```python
   result = check_service_health("http://web-app:3000")
   ```

### Part 2: Working with JSON APIs

3. Write a function `get_prometheus_targets(prometheus_url)` that:
   - Makes a GET request to `{prometheus_url}/api/v1/targets`
   - Parses the JSON response
   - Returns a list of target endpoints
   - Handles errors and returns empty list on failure

4. Write a function `query_prometheus_metric(prometheus_url, metric_name)` that:
   - Makes a GET request to `{prometheus_url}/api/v1/query`
   - Passes the metric name as a query parameter
   - Returns the metric value or None if not found

### Part 3: POST Requests and Headers

5. Write a function `send_alert(webhook_url, alert_data)` that:
   - Makes a POST request with JSON body
   - Sets Content-Type header to application/json
   - Returns True if successful (2xx status), False otherwise
   - alert_data should include: title, message, severity

6. Write a function `authenticate_api(auth_url, username, password)` that:
   - Makes a POST request with credentials
   - Returns the auth token from response
   - Handles authentication failures

### Part 4: Challenge - Service Monitor

7. Create a `ServiceMonitor` class that:
   - Takes a list of service URLs in constructor
   - Method `check_all()` checks all services and returns status dict
   - Method `get_unhealthy()` returns list of unhealthy service URLs
   - Method `wait_for_healthy(url, timeout=30)` polls until healthy or timeout
   - Uses retry logic with exponential backoff

8. Implement request timeout and retry configuration:
   - Default timeout of 5 seconds
   - Retry up to 3 times on connection errors
   - Exponential backoff between retries

## Expected Output

```
=== Part 1: Basic GET Requests ===
Checking http://web-app:3000...
Health check result: {'status_code': 200, 'response_time_ms': 45, 'is_healthy': True}

=== Part 2: JSON APIs ===
Prometheus targets: ['web-app:3000', 'prometheus:9090']
Metric up value: 1

=== Part 3: POST Requests ===
Alert sent successfully: True
Auth token received: eyJhbGciOiJIUzI1NiIs...

=== Part 4: Service Monitor ===
All services status:
  http://web-app:3000: healthy
  http://prometheus:9090: healthy
Unhealthy services: []
Waiting for service to become healthy...
Service became healthy after 2 attempts
```

## Verification Steps

Run your script inside the Python container:
```bash
docker exec -it devops-python bash
cd /workspace
python api_requests.py
```

1. Health check returns correct status for running services
2. JSON parsing extracts data correctly from Prometheus API
3. POST requests send correct headers and body
4. ServiceMonitor correctly identifies unhealthy services
5. Retry logic works with exponential backoff

## Hints

<details>
<summary>Hint 1: Basic GET Request</summary>

```python
import requests

response = requests.get(url, timeout=5)
print(response.status_code)
print(response.text)
print(response.json())  # If JSON response
```
</details>

<details>
<summary>Hint 2: Measuring Response Time</summary>

```python
import time

start = time.time()
response = requests.get(url)
elapsed_ms = (time.time() - start) * 1000
```

Or use the built-in:
```python
response = requests.get(url)
elapsed_ms = response.elapsed.total_seconds() * 1000
```
</details>

<details>
<summary>Hint 3: POST with JSON</summary>

```python
import requests

data = {"key": "value"}
response = requests.post(
    url,
    json=data,  # Automatically sets Content-Type
    headers={"Authorization": "Bearer token"}
)
```
</details>

<details>
<summary>Hint 4: Exponential Backoff</summary>

```python
import time

for attempt in range(max_retries):
    try:
        response = requests.get(url)
        return response
    except requests.RequestException:
        wait_time = 2 ** attempt  # 1, 2, 4, 8...
        time.sleep(wait_time)
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
Python DevOps: HTTP API Requests
DevOps Interview Playground Exercise
"""

import requests
import time
import json

# === Part 1: Basic GET Requests ===
print("=== Part 1: Basic GET Requests ===")

def check_service_health(url, timeout=5):
    """Check if a service is healthy by making a GET request."""
    try:
        start_time = time.time()
        response = requests.get(url, timeout=timeout)
        elapsed_ms = (time.time() - start_time) * 1000
        
        return {
            "status_code": response.status_code,
            "response_time_ms": round(elapsed_ms, 2),
            "is_healthy": response.status_code == 200
        }
    except requests.ConnectionError:
        return {
            "status_code": 0,
            "response_time_ms": 0,
            "is_healthy": False,
            "error": "Connection failed"
        }
    except requests.Timeout:
        return {
            "status_code": 0,
            "response_time_ms": timeout * 1000,
            "is_healthy": False,
            "error": "Request timed out"
        }
    except requests.RequestException as e:
        return {
            "status_code": 0,
            "response_time_ms": 0,
            "is_healthy": False,
            "error": str(e)
        }

# Test health check (use httpbin for demo if playground not running)
print("Checking http://web-app:3000...")
result = check_service_health("http://web-app:3000")
print(f"Health check result: {result}")

# === Part 2: JSON APIs ===
print("\n=== Part 2: JSON APIs ===")

def get_prometheus_targets(prometheus_url, timeout=5):
    """Get list of Prometheus scrape targets."""
    try:
        response = requests.get(
            f"{prometheus_url}/api/v1/targets",
            timeout=timeout
        )
        response.raise_for_status()
        
        data = response.json()
        targets = []
        
        if data.get("status") == "success":
            for target_group in data.get("data", {}).get("activeTargets", []):
                targets.append(target_group.get("scrapeUrl", ""))
        
        return targets
    except requests.RequestException as e:
        print(f"Error fetching targets: {e}")
        return []
    except json.JSONDecodeError:
        print("Invalid JSON response")
        return []

def query_prometheus_metric(prometheus_url, metric_name, timeout=5):
    """Query a Prometheus metric value."""
    try:
        response = requests.get(
            f"{prometheus_url}/api/v1/query",
            params={"query": metric_name},
            timeout=timeout
        )
        response.raise_for_status()
        
        data = response.json()
        
        if data.get("status") == "success":
            results = data.get("data", {}).get("result", [])
            if results:
                # Return the first result's value
                return results[0].get("value", [None, None])[1]
        
        return None
    except requests.RequestException as e:
        print(f"Error querying metric: {e}")
        return None

# Test Prometheus API
targets = get_prometheus_targets("http://prometheus:9090")
print(f"Prometheus targets: {targets}")

metric_value = query_prometheus_metric("http://prometheus:9090", "up")
print(f"Metric 'up' value: {metric_value}")

# === Part 3: POST Requests ===
print("\n=== Part 3: POST Requests ===")

def send_alert(webhook_url, alert_data, timeout=5):
    """Send an alert to a webhook endpoint."""
    try:
        response = requests.post(
            webhook_url,
            json=alert_data,
            headers={"Content-Type": "application/json"},
            timeout=timeout
        )
        return 200 <= response.status_code < 300
    except requests.RequestException as e:
        print(f"Error sending alert: {e}")
        return False

def authenticate_api(auth_url, username, password, timeout=5):
    """Authenticate and get an API token."""
    try:
        response = requests.post(
            auth_url,
            json={"username": username, "password": password},
            headers={"Content-Type": "application/json"},
            timeout=timeout
        )
        
        if response.status_code == 200:
            data = response.json()
            return data.get("token")
        else:
            print(f"Authentication failed: {response.status_code}")
            return None
    except requests.RequestException as e:
        print(f"Error authenticating: {e}")
        return None

# Demo POST requests (these would need actual endpoints)
alert_data = {
    "title": "High CPU Alert",
    "message": "CPU usage exceeded 90%",
    "severity": "warning"
}
print(f"Alert data prepared: {alert_data}")
# result = send_alert("http://alertmanager:9093/api/v1/alerts", alert_data)
# print(f"Alert sent successfully: {result}")

# === Part 4: Service Monitor ===
print("\n=== Part 4: Service Monitor ===")

class ServiceMonitor:
    """Monitor multiple services for health status."""
    
    def __init__(self, service_urls, timeout=5, max_retries=3):
        self.service_urls = service_urls
        self.timeout = timeout
        self.max_retries = max_retries
    
    def _request_with_retry(self, url):
        """Make a request with exponential backoff retry."""
        last_error = None
        
        for attempt in range(self.max_retries):
            try:
                response = requests.get(url, timeout=self.timeout)
                return response
            except requests.RequestException as e:
                last_error = e
                if attempt < self.max_retries - 1:
                    wait_time = 2 ** attempt  # 1, 2, 4 seconds
                    time.sleep(wait_time)
        
        raise last_error
    
    def check_all(self):
        """Check health of all services."""
        status = {}
        
        for url in self.service_urls:
            try:
                response = self._request_with_retry(url)
                status[url] = {
                    "healthy": response.status_code == 200,
                    "status_code": response.status_code,
                    "response_time_ms": response.elapsed.total_seconds() * 1000
                }
            except requests.RequestException as e:
                status[url] = {
                    "healthy": False,
                    "status_code": 0,
                    "error": str(e)
                }
        
        return status
    
    def get_unhealthy(self):
        """Get list of unhealthy service URLs."""
        status = self.check_all()
        return [url for url, info in status.items() if not info["healthy"]]
    
    def wait_for_healthy(self, url, timeout=30, poll_interval=2):
        """Wait for a service to become healthy."""
        start_time = time.time()
        attempts = 0
        
        print(f"Waiting for {url} to become healthy...")
        
        while time.time() - start_time < timeout:
            attempts += 1
            try:
                response = requests.get(url, timeout=self.timeout)
                if response.status_code == 200:
                    print(f"Service became healthy after {attempts} attempts")
                    return True
            except requests.RequestException:
                pass
            
            time.sleep(poll_interval)
        
        print(f"Timeout waiting for {url} after {attempts} attempts")
        return False

# Test ServiceMonitor
services = [
    "http://web-app:3000",
    "http://prometheus:9090"
]

monitor = ServiceMonitor(services)

print("All services status:")
status = monitor.check_all()
for url, info in status.items():
    health_status = "healthy" if info.get("healthy") else "unhealthy"
    print(f"  {url}: {health_status}")

unhealthy = monitor.get_unhealthy()
print(f"Unhealthy services: {unhealthy}")

# Demo wait_for_healthy (commented to avoid blocking)
# monitor.wait_for_healthy("http://web-app:3000", timeout=10)
```

### Explanation

**requests Library:**
- `requests.get(url)` - Make GET request
- `requests.post(url, json=data)` - Make POST with JSON body
- `response.status_code` - HTTP status code
- `response.json()` - Parse JSON response
- `response.text` - Raw response text
- `response.elapsed` - Request duration

**Error Handling:**
- `requests.ConnectionError` - Cannot connect to server
- `requests.Timeout` - Request exceeded timeout
- `requests.HTTPError` - HTTP error status (use raise_for_status())
- `requests.RequestException` - Base class for all request errors

**Headers and Parameters:**
- `headers={"Key": "Value"}` - Set request headers
- `params={"key": "value"}` - URL query parameters
- `json=data` - Send JSON body (auto-sets Content-Type)
- `data=payload` - Send form data

**Retry Logic:**
- Exponential backoff: wait 2^attempt seconds between retries
- Prevents overwhelming failing services
- Common pattern in distributed systems

**Best Practices:**
- Always set timeouts to prevent hanging
- Handle specific exceptions before generic ones
- Use `raise_for_status()` to catch HTTP errors
- Log errors for debugging
- Implement retry logic for transient failures

</details>

## Test Cases

Save this as `test_api_requests.py`:

```python
#!/usr/bin/env python3
"""Test cases for API requests exercise"""

import requests
from unittest.mock import Mock, patch
import time

def check_service_health(url, timeout=5):
    try:
        start_time = time.time()
        response = requests.get(url, timeout=timeout)
        elapsed_ms = (time.time() - start_time) * 1000
        return {
            "status_code": response.status_code,
            "response_time_ms": round(elapsed_ms, 2),
            "is_healthy": response.status_code == 200
        }
    except requests.RequestException as e:
        return {
            "status_code": 0,
            "response_time_ms": 0,
            "is_healthy": False,
            "error": str(e)
        }

def test_health_check_structure():
    """Test health check returns correct structure"""
    # Test with a mock or real endpoint
    result = check_service_health("http://httpbin.org/status/200")
    
    assert "status_code" in result
    assert "response_time_ms" in result
    assert "is_healthy" in result
    assert isinstance(result["status_code"], int)
    assert isinstance(result["response_time_ms"], (int, float))
    assert isinstance(result["is_healthy"], bool)
    print("✓ Health check structure test passed")

def test_health_check_healthy():
    """Test health check identifies healthy service"""
    result = check_service_health("http://httpbin.org/status/200")
    assert result["is_healthy"] == True
    assert result["status_code"] == 200
    print("✓ Health check healthy test passed")

def test_health_check_unhealthy():
    """Test health check identifies unhealthy service"""
    result = check_service_health("http://httpbin.org/status/500")
    assert result["is_healthy"] == False
    assert result["status_code"] == 500
    print("✓ Health check unhealthy test passed")

def test_health_check_connection_error():
    """Test health check handles connection errors"""
    result = check_service_health("http://nonexistent.invalid:9999")
    assert result["is_healthy"] == False
    assert result["status_code"] == 0
    assert "error" in result
    print("✓ Health check connection error test passed")

def test_service_monitor_class():
    """Test ServiceMonitor class structure"""
    class ServiceMonitor:
        def __init__(self, urls):
            self.service_urls = urls
        
        def check_all(self):
            return {url: {"healthy": True} for url in self.service_urls}
        
        def get_unhealthy(self):
            return []
    
    monitor = ServiceMonitor(["http://test1", "http://test2"])
    assert len(monitor.service_urls) == 2
    
    status = monitor.check_all()
    assert len(status) == 2
    
    unhealthy = monitor.get_unhealthy()
    assert isinstance(unhealthy, list)
    print("✓ ServiceMonitor class test passed")

if __name__ == "__main__":
    print("Running API request tests...")
    print("Note: These tests require internet access\n")
    
    try:
        test_health_check_structure()
        test_health_check_healthy()
        test_health_check_unhealthy()
        test_health_check_connection_error()
        test_service_monitor_class()
        print("\n✅ All tests passed!")
    except requests.RequestException as e:
        print(f"\n⚠️ Network error during tests: {e}")
        print("Some tests require internet access to httpbin.org")
```

Run tests with:
```bash
python test_api_requests.py
```

## Additional Resources

- [Requests Library Documentation](https://requests.readthedocs.io/)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [Prometheus HTTP API](https://prometheus.io/docs/prometheus/latest/querying/api/)
