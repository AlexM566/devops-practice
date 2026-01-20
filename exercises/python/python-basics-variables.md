# Python Basics: Variables and Data Types

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Python 3.11+ installed, basic command line knowledge

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn Python's fundamental data types and how to work with variables. You'll practice with strings, numbers, lists, and dictionaries - the building blocks of any Python program and essential for DevOps scripting.

## Instructions

### Part 1: Working with Strings and Numbers

Create a file called `variables.py` in the workspace directory.

1. Create variables to store server information:
   - A string variable `server_name` with value "web-server-01"
   - An integer variable `port` with value 8080
   - A float variable `cpu_usage` with value 45.5
   - A boolean variable `is_healthy` with value True

2. Print each variable with a descriptive label

3. Create a formatted string that combines all variables into a status message:
   ```
   Server: web-server-01 | Port: 8080 | CPU: 45.5% | Healthy: True
   ```

### Part 2: Working with Lists

4. Create a list called `services` containing: "nginx", "redis", "postgres", "grafana"

5. Perform these operations:
   - Add "prometheus" to the end of the list
   - Remove "redis" from the list
   - Print the first and last items
   - Print the total number of services

### Part 3: Working with Dictionaries

6. Create a dictionary called `server_config` with these key-value pairs:
   - "hostname": "prod-server-01"
   - "ip": "192.168.1.100"
   - "ports": [80, 443, 8080]
   - "enabled": True

7. Perform these operations:
   - Add a new key "region" with value "us-east-1"
   - Update the "hostname" to "prod-server-02"
   - Print all keys in the dictionary
   - Print all values in the dictionary

### Part 4: Challenge - Server Inventory

8. Create a list of dictionaries representing 3 servers with the following structure for each:
   - "name": server name
   - "ip": IP address
   - "status": "running" or "stopped"
   - "services": list of running services

9. Write code to:
   - Print the name of each server
   - Count how many servers are "running"
   - Find and print all unique services across all servers

## Expected Output

Your script should produce output similar to:

```
=== Part 1: Basic Variables ===
Server Name: web-server-01
Port: 8080
CPU Usage: 45.5
Is Healthy: True
Status: Server: web-server-01 | Port: 8080 | CPU: 45.5% | Healthy: True

=== Part 2: Lists ===
Services after adding prometheus: ['nginx', 'redis', 'postgres', 'grafana', 'prometheus']
Services after removing redis: ['nginx', 'postgres', 'grafana', 'prometheus']
First service: nginx
Last service: prometheus
Total services: 4

=== Part 3: Dictionaries ===
Config with region: {'hostname': 'prod-server-01', 'ip': '192.168.1.100', 'ports': [80, 443, 8080], 'enabled': True, 'region': 'us-east-1'}
Updated hostname: prod-server-02
Keys: dict_keys(['hostname', 'ip', 'ports', 'enabled', 'region'])
Values: dict_values(['prod-server-02', '192.168.1.100', [80, 443, 8080], True, 'us-east-1'])

=== Part 4: Server Inventory ===
Server names: server-01, server-02, server-03
Running servers: 2
All unique services: {'nginx', 'postgres', 'redis', 'grafana'}
```

## Verification Steps

Run your script and verify:
```bash
cd /workspace
python variables.py
```

1. All variable types are correctly assigned
2. String formatting produces the expected status message
3. List operations (append, remove, indexing) work correctly
4. Dictionary operations (add, update, keys, values) work correctly
5. Server inventory challenge produces correct counts and unique services

## Hints

<details>
<summary>Hint 1: String Formatting</summary>

Python offers several ways to format strings. The f-string method is most readable:
```python
name = "server"
port = 8080
message = f"Server: {name} | Port: {port}"
```
</details>

<details>
<summary>Hint 2: List Operations</summary>

Common list operations:
```python
my_list = ["a", "b", "c"]
my_list.append("d")      # Add to end
my_list.remove("b")      # Remove by value
first = my_list[0]       # First item
last = my_list[-1]       # Last item
count = len(my_list)     # Length
```
</details>

<details>
<summary>Hint 3: Dictionary Operations</summary>

Common dictionary operations:
```python
my_dict = {"key": "value"}
my_dict["new_key"] = "new_value"  # Add new key
my_dict["key"] = "updated"        # Update existing
keys = my_dict.keys()             # Get all keys
values = my_dict.values()         # Get all values
```
</details>

<details>
<summary>Hint 4: Finding Unique Items</summary>

To find unique items across multiple lists, use a set:
```python
all_items = set()
for item_list in list_of_lists:
    all_items.update(item_list)
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
Python Basics: Variables and Data Types
DevOps Interview Playground Exercise
"""

# === Part 1: Basic Variables ===
print("=== Part 1: Basic Variables ===")

# Create variables for server information
server_name = "web-server-01"
port = 8080
cpu_usage = 45.5
is_healthy = True

# Print each variable
print(f"Server Name: {server_name}")
print(f"Port: {port}")
print(f"CPU Usage: {cpu_usage}")
print(f"Is Healthy: {is_healthy}")

# Create formatted status message
status_message = f"Server: {server_name} | Port: {port} | CPU: {cpu_usage}% | Healthy: {is_healthy}"
print(f"Status: {status_message}")

# === Part 2: Lists ===
print("\n=== Part 2: Lists ===")

# Create services list
services = ["nginx", "redis", "postgres", "grafana"]

# Add prometheus
services.append("prometheus")
print(f"Services after adding prometheus: {services}")

# Remove redis
services.remove("redis")
print(f"Services after removing redis: {services}")

# Print first and last items
print(f"First service: {services[0]}")
print(f"Last service: {services[-1]}")

# Print total count
print(f"Total services: {len(services)}")

# === Part 3: Dictionaries ===
print("\n=== Part 3: Dictionaries ===")

# Create server config dictionary
server_config = {
    "hostname": "prod-server-01",
    "ip": "192.168.1.100",
    "ports": [80, 443, 8080],
    "enabled": True
}

# Add region key
server_config["region"] = "us-east-1"
print(f"Config with region: {server_config}")

# Update hostname
server_config["hostname"] = "prod-server-02"
print(f"Updated hostname: {server_config['hostname']}")

# Print keys and values
print(f"Keys: {server_config.keys()}")
print(f"Values: {server_config.values()}")

# === Part 4: Server Inventory Challenge ===
print("\n=== Part 4: Server Inventory ===")

# Create server inventory
servers = [
    {
        "name": "server-01",
        "ip": "192.168.1.10",
        "status": "running",
        "services": ["nginx", "redis"]
    },
    {
        "name": "server-02",
        "ip": "192.168.1.11",
        "status": "running",
        "services": ["postgres", "grafana"]
    },
    {
        "name": "server-03",
        "ip": "192.168.1.12",
        "status": "stopped",
        "services": ["nginx", "redis"]
    }
]

# Print server names
server_names = [server["name"] for server in servers]
print(f"Server names: {', '.join(server_names)}")

# Count running servers
running_count = sum(1 for server in servers if server["status"] == "running")
print(f"Running servers: {running_count}")

# Find all unique services
all_services = set()
for server in servers:
    all_services.update(server["services"])
print(f"All unique services: {all_services}")
```

### Explanation

**Variables and Types:**
- Python is dynamically typed - you don't declare types explicitly
- Strings use quotes (single or double)
- Integers are whole numbers, floats have decimals
- Booleans are `True` or `False` (capitalized)

**F-strings:**
- Prefix string with `f` to enable variable interpolation
- Variables go inside `{curly_braces}`

**Lists:**
- Ordered, mutable collections using `[]`
- `append()` adds to end, `remove()` removes by value
- Index with `[0]` for first, `[-1]` for last
- `len()` returns count

**Dictionaries:**
- Key-value pairs using `{}`
- Access values with `dict["key"]`
- Add/update with `dict["key"] = value`
- `.keys()` and `.values()` return views

**List Comprehensions:**
- `[x for x in list]` creates new list from existing
- Can include conditions: `[x for x in list if condition]`

**Sets:**
- Unordered collection of unique items
- `set.update(list)` adds all items from list

</details>

## Test Cases

Save this as `test_variables.py` to verify your solution:

```python
#!/usr/bin/env python3
"""Test cases for variables exercise"""

def test_string_formatting():
    """Test that string formatting works correctly"""
    server_name = "web-server-01"
    port = 8080
    cpu_usage = 45.5
    is_healthy = True
    
    status = f"Server: {server_name} | Port: {port} | CPU: {cpu_usage}% | Healthy: {is_healthy}"
    assert "web-server-01" in status
    assert "8080" in status
    assert "45.5" in status
    assert "True" in status
    print("✓ String formatting test passed")

def test_list_operations():
    """Test list operations"""
    services = ["nginx", "redis", "postgres", "grafana"]
    services.append("prometheus")
    assert "prometheus" in services
    assert len(services) == 5
    
    services.remove("redis")
    assert "redis" not in services
    assert len(services) == 4
    assert services[0] == "nginx"
    assert services[-1] == "prometheus"
    print("✓ List operations test passed")

def test_dictionary_operations():
    """Test dictionary operations"""
    server_config = {
        "hostname": "prod-server-01",
        "ip": "192.168.1.100",
        "ports": [80, 443, 8080],
        "enabled": True
    }
    
    server_config["region"] = "us-east-1"
    assert "region" in server_config
    assert server_config["region"] == "us-east-1"
    
    server_config["hostname"] = "prod-server-02"
    assert server_config["hostname"] == "prod-server-02"
    print("✓ Dictionary operations test passed")

def test_server_inventory():
    """Test server inventory challenge"""
    servers = [
        {"name": "server-01", "ip": "192.168.1.10", "status": "running", "services": ["nginx", "redis"]},
        {"name": "server-02", "ip": "192.168.1.11", "status": "running", "services": ["postgres", "grafana"]},
        {"name": "server-03", "ip": "192.168.1.12", "status": "stopped", "services": ["nginx", "redis"]}
    ]
    
    # Test server names extraction
    server_names = [server["name"] for server in servers]
    assert len(server_names) == 3
    assert "server-01" in server_names
    
    # Test running count
    running_count = sum(1 for server in servers if server["status"] == "running")
    assert running_count == 2
    
    # Test unique services
    all_services = set()
    for server in servers:
        all_services.update(server["services"])
    assert len(all_services) == 4
    assert "nginx" in all_services
    print("✓ Server inventory test passed")

if __name__ == "__main__":
    test_string_formatting()
    test_list_operations()
    test_dictionary_operations()
    test_server_inventory()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_variables.py
```

## Additional Resources

- [Python Data Types Documentation](https://docs.python.org/3/library/stdtypes.html)
- [Python F-strings Guide](https://docs.python.org/3/tutorial/inputoutput.html#formatted-string-literals)
- [Python Lists Tutorial](https://docs.python.org/3/tutorial/datastructures.html#more-on-lists)
- [Python Dictionaries Tutorial](https://docs.python.org/3/tutorial/datastructures.html#dictionaries)
