# Python Basics: Classes and Objects

**Difficulty:** Beginner
**Estimated Time:** 35 minutes
**Prerequisites:** Python functions and error handling

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn object-oriented programming in Python by creating classes, defining methods, and using inheritance. OOP helps organize complex DevOps tools into maintainable, reusable components.

## Instructions

### Part 1: Basic Class Definition

Create a file called `objects.py` in the workspace directory.

1. Create a `Server` class with:
   - `__init__` method accepting: name, ip_address, port (default 22)
   - Attributes: name, ip_address, port, status (default "stopped")
   - Method `start()` that sets status to "running" and prints a message
   - Method `stop()` that sets status to "stopped" and prints a message
   - Method `get_info()` that returns a formatted string with server details

2. Create two Server instances and demonstrate starting/stopping them

### Part 2: Properties and Encapsulation

3. Create a `Container` class with:
   - Private attribute `_cpu_limit` (use underscore prefix)
   - Property `cpu_limit` with getter and setter
   - Setter should validate that cpu_limit is between 0.1 and 4.0
   - Raise ValueError if validation fails

4. Create a `Service` class with:
   - Attributes: name, replicas, image
   - Property `replicas` that ensures value is always >= 0
   - Method `scale(count)` that sets replicas to count
   - Method `__str__` that returns a readable representation

### Part 3: Inheritance

5. Create a base class `Resource` with:
   - Attributes: name, created_at (default to current time)
   - Method `describe()` that prints resource info
   - Method `age()` that returns seconds since creation

6. Create child classes that inherit from `Resource`:
   - `Pod` with additional attributes: namespace, containers (list)
   - `Deployment` with additional attributes: namespace, replicas, selector
   - Both should override `describe()` to include their specific attributes

### Part 4: Challenge - Service Registry

7. Create a `ServiceRegistry` class that:
   - Maintains a dictionary of registered services
   - Method `register(service)` adds a service by name
   - Method `unregister(name)` removes a service
   - Method `get(name)` returns a service or None
   - Method `list_all()` returns all service names
   - Method `find_by_image(image)` returns services using that image

8. Implement `__len__` to return the count of registered services
9. Implement `__contains__` to check if a service name exists

## Expected Output

```
=== Part 1: Basic Class ===
Server web-01 created at 192.168.1.10:22
Starting server web-01...
Server web-01 is now running
Server Info: web-01 (192.168.1.10:22) - running
Stopping server web-01...
Server web-01 is now stopped

=== Part 2: Properties ===
Container CPU limit: 2.0
Updated CPU limit: 1.5
Error setting CPU limit: CPU limit must be between 0.1 and 4.0
Service: nginx (3 replicas) using nginx:latest
Scaled to 5 replicas

=== Part 3: Inheritance ===
Resource: my-pod (created 0 seconds ago)
Pod: my-pod in namespace default with 2 containers
Deployment: my-app in namespace production with 3 replicas

=== Part 4: Service Registry ===
Registered services: ['nginx', 'redis', 'postgres']
Registry contains 3 services
'nginx' in registry: True
Services using redis image: ['redis']
After unregister: ['nginx', 'postgres']
```

## Verification Steps

Run your script:
```bash
cd /workspace
python objects.py
```

1. Server class creates instances with correct attributes
2. Start/stop methods change status correctly
3. Property validation raises ValueError for invalid values
4. Child classes inherit from parent and override methods
5. ServiceRegistry manages services correctly
6. Magic methods (__len__, __contains__, __str__) work as expected

## Hints

<details>
<summary>Hint 1: Class Definition</summary>

Basic class structure:
```python
class MyClass:
    def __init__(self, param1, param2="default"):
        self.param1 = param1
        self.param2 = param2
    
    def my_method(self):
        return f"Value: {self.param1}"
```
</details>

<details>
<summary>Hint 2: Properties</summary>

Use @property decorator for getters and setters:
```python
class MyClass:
    def __init__(self):
        self._value = 0
    
    @property
    def value(self):
        return self._value
    
    @value.setter
    def value(self, new_value):
        if new_value < 0:
            raise ValueError("Must be positive")
        self._value = new_value
```
</details>

<details>
<summary>Hint 3: Inheritance</summary>

Child classes inherit from parent:
```python
class Parent:
    def __init__(self, name):
        self.name = name

class Child(Parent):
    def __init__(self, name, extra):
        super().__init__(name)  # Call parent __init__
        self.extra = extra
```
</details>

<details>
<summary>Hint 4: Magic Methods</summary>

Special methods for Python operators:
```python
class MyCollection:
    def __len__(self):
        return len(self._items)
    
    def __contains__(self, item):
        return item in self._items
    
    def __str__(self):
        return f"Collection with {len(self)} items"
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
Python Basics: Classes and Objects
DevOps Interview Playground Exercise
"""

from datetime import datetime

# === Part 1: Basic Class ===
print("=== Part 1: Basic Class ===")

class Server:
    """Represents a server in the infrastructure."""
    
    def __init__(self, name, ip_address, port=22):
        self.name = name
        self.ip_address = ip_address
        self.port = port
        self.status = "stopped"
        print(f"Server {name} created at {ip_address}:{port}")
    
    def start(self):
        """Start the server."""
        print(f"Starting server {self.name}...")
        self.status = "running"
        print(f"Server {self.name} is now running")
    
    def stop(self):
        """Stop the server."""
        print(f"Stopping server {self.name}...")
        self.status = "stopped"
        print(f"Server {self.name} is now stopped")
    
    def get_info(self):
        """Get server information."""
        return f"{self.name} ({self.ip_address}:{self.port}) - {self.status}"

# Test Server class
server1 = Server("web-01", "192.168.1.10")
server1.start()
print(f"Server Info: {server1.get_info()}")
server1.stop()

# === Part 2: Properties ===
print("\n=== Part 2: Properties ===")

class Container:
    """Represents a container with resource limits."""
    
    def __init__(self, name, cpu_limit=1.0):
        self.name = name
        self._cpu_limit = cpu_limit
    
    @property
    def cpu_limit(self):
        """Get CPU limit."""
        return self._cpu_limit
    
    @cpu_limit.setter
    def cpu_limit(self, value):
        """Set CPU limit with validation."""
        if not 0.1 <= value <= 4.0:
            raise ValueError("CPU limit must be between 0.1 and 4.0")
        self._cpu_limit = value

class Service:
    """Represents a deployable service."""
    
    def __init__(self, name, image, replicas=1):
        self.name = name
        self.image = image
        self._replicas = max(0, replicas)
    
    @property
    def replicas(self):
        return self._replicas
    
    @replicas.setter
    def replicas(self, value):
        self._replicas = max(0, value)
    
    def scale(self, count):
        """Scale the service to specified replicas."""
        self.replicas = count
        print(f"Scaled to {self.replicas} replicas")
    
    def __str__(self):
        return f"{self.name} ({self.replicas} replicas) using {self.image}"

# Test Container
container = Container("app", 2.0)
print(f"Container CPU limit: {container.cpu_limit}")
container.cpu_limit = 1.5
print(f"Updated CPU limit: {container.cpu_limit}")

try:
    container.cpu_limit = 5.0
except ValueError as e:
    print(f"Error setting CPU limit: {e}")

# Test Service
service = Service("nginx", "nginx:latest", 3)
print(f"Service: {service}")
service.scale(5)

# === Part 3: Inheritance ===
print("\n=== Part 3: Inheritance ===")

class Resource:
    """Base class for Kubernetes resources."""
    
    def __init__(self, name):
        self.name = name
        self.created_at = datetime.now()
    
    def describe(self):
        """Print resource description."""
        age = self.age()
        print(f"Resource: {self.name} (created {age} seconds ago)")
    
    def age(self):
        """Return age in seconds."""
        delta = datetime.now() - self.created_at
        return int(delta.total_seconds())

class Pod(Resource):
    """Represents a Kubernetes Pod."""
    
    def __init__(self, name, namespace="default", containers=None):
        super().__init__(name)
        self.namespace = namespace
        self.containers = containers or []
    
    def describe(self):
        """Print pod description."""
        print(f"Pod: {self.name} in namespace {self.namespace} with {len(self.containers)} containers")

class Deployment(Resource):
    """Represents a Kubernetes Deployment."""
    
    def __init__(self, name, namespace="default", replicas=1, selector=None):
        super().__init__(name)
        self.namespace = namespace
        self.replicas = replicas
        self.selector = selector or {}
    
    def describe(self):
        """Print deployment description."""
        print(f"Deployment: {self.name} in namespace {self.namespace} with {self.replicas} replicas")

# Test inheritance
resource = Resource("my-pod")
resource.describe()

pod = Pod("my-pod", "default", ["nginx", "sidecar"])
pod.describe()

deployment = Deployment("my-app", "production", 3)
deployment.describe()

# === Part 4: Service Registry ===
print("\n=== Part 4: Service Registry ===")

class ServiceRegistry:
    """Registry for managing services."""
    
    def __init__(self):
        self._services = {}
    
    def register(self, service):
        """Register a service."""
        self._services[service.name] = service
    
    def unregister(self, name):
        """Unregister a service by name."""
        if name in self._services:
            del self._services[name]
    
    def get(self, name):
        """Get a service by name."""
        return self._services.get(name)
    
    def list_all(self):
        """List all service names."""
        return list(self._services.keys())
    
    def find_by_image(self, image):
        """Find services using a specific image."""
        return [
            name for name, svc in self._services.items()
            if svc.image == image
        ]
    
    def __len__(self):
        """Return number of registered services."""
        return len(self._services)
    
    def __contains__(self, name):
        """Check if service name is registered."""
        return name in self._services

# Test ServiceRegistry
registry = ServiceRegistry()

# Register services
registry.register(Service("nginx", "nginx:latest", 3))
registry.register(Service("redis", "redis:alpine", 1))
registry.register(Service("postgres", "postgres:15", 1))

print(f"Registered services: {registry.list_all()}")
print(f"Registry contains {len(registry)} services")
print(f"'nginx' in registry: {'nginx' in registry}")
print(f"Services using redis image: {registry.find_by_image('redis:alpine')}")

registry.unregister("redis")
print(f"After unregister: {registry.list_all()}")
```

### Explanation

**Class Basics:**
- `class ClassName:` defines a class
- `__init__` is the constructor, called when creating instances
- `self` refers to the current instance
- Instance attributes are set with `self.attribute = value`

**Properties:**
- `@property` decorator creates a getter method
- `@property_name.setter` creates a setter method
- Use properties to add validation or computed values
- Convention: prefix private attributes with underscore `_`

**Inheritance:**
- `class Child(Parent):` inherits from Parent
- `super().__init__()` calls parent's constructor
- Child classes can override parent methods
- Child classes can add new attributes and methods

**Magic Methods:**
- `__init__`: Constructor
- `__str__`: String representation (for print)
- `__len__`: Length (for len())
- `__contains__`: Membership test (for `in` operator)
- `__repr__`: Developer-friendly representation

**Best Practices:**
- Use descriptive class and method names
- Document classes and methods with docstrings
- Keep classes focused on a single responsibility
- Use inheritance for "is-a" relationships
- Use composition for "has-a" relationships

</details>

## Test Cases

Save this as `test_objects.py`:

```python
#!/usr/bin/env python3
"""Test cases for objects exercise"""

from datetime import datetime

class Server:
    def __init__(self, name, ip_address, port=22):
        self.name = name
        self.ip_address = ip_address
        self.port = port
        self.status = "stopped"
    
    def start(self):
        self.status = "running"
    
    def stop(self):
        self.status = "stopped"
    
    def get_info(self):
        return f"{self.name} ({self.ip_address}:{self.port}) - {self.status}"

class Container:
    def __init__(self, name, cpu_limit=1.0):
        self.name = name
        self._cpu_limit = cpu_limit
    
    @property
    def cpu_limit(self):
        return self._cpu_limit
    
    @cpu_limit.setter
    def cpu_limit(self, value):
        if not 0.1 <= value <= 4.0:
            raise ValueError("CPU limit must be between 0.1 and 4.0")
        self._cpu_limit = value

class Service:
    def __init__(self, name, image, replicas=1):
        self.name = name
        self.image = image
        self._replicas = max(0, replicas)
    
    @property
    def replicas(self):
        return self._replicas
    
    @replicas.setter
    def replicas(self, value):
        self._replicas = max(0, value)

class ServiceRegistry:
    def __init__(self):
        self._services = {}
    
    def register(self, service):
        self._services[service.name] = service
    
    def unregister(self, name):
        if name in self._services:
            del self._services[name]
    
    def list_all(self):
        return list(self._services.keys())
    
    def __len__(self):
        return len(self._services)
    
    def __contains__(self, name):
        return name in self._services

def test_server_class():
    """Test Server class"""
    server = Server("web-01", "192.168.1.10", 8080)
    assert server.name == "web-01"
    assert server.ip_address == "192.168.1.10"
    assert server.port == 8080
    assert server.status == "stopped"
    
    server.start()
    assert server.status == "running"
    
    server.stop()
    assert server.status == "stopped"
    
    info = server.get_info()
    assert "web-01" in info
    assert "192.168.1.10" in info
    print("✓ Server class tests passed")

def test_container_property():
    """Test Container property validation"""
    container = Container("app", 2.0)
    assert container.cpu_limit == 2.0
    
    container.cpu_limit = 1.5
    assert container.cpu_limit == 1.5
    
    try:
        container.cpu_limit = 5.0
        assert False, "Should have raised ValueError"
    except ValueError:
        pass
    
    try:
        container.cpu_limit = 0.05
        assert False, "Should have raised ValueError"
    except ValueError:
        pass
    
    print("✓ Container property tests passed")

def test_service_registry():
    """Test ServiceRegistry class"""
    registry = ServiceRegistry()
    
    registry.register(Service("nginx", "nginx:latest", 3))
    registry.register(Service("redis", "redis:alpine", 1))
    
    assert len(registry) == 2
    assert "nginx" in registry
    assert "redis" in registry
    assert "postgres" not in registry
    
    registry.unregister("redis")
    assert len(registry) == 1
    assert "redis" not in registry
    
    print("✓ ServiceRegistry tests passed")

if __name__ == "__main__":
    test_server_class()
    test_container_property()
    test_service_registry()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_objects.py
```

## Additional Resources

- [Python Classes Documentation](https://docs.python.org/3/tutorial/classes.html)
- [Python Properties](https://docs.python.org/3/library/functions.html#property)
- [Python Data Model (Magic Methods)](https://docs.python.org/3/reference/datamodel.html)
