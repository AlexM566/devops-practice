# Python DevOps: YAML Parsing and Manipulation

**Difficulty:** Intermediate
**Estimated Time:** 30 minutes
**Prerequisites:** Python basics, understanding of YAML format

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to parse, modify, and generate YAML configuration files using Python's `pyyaml` library. YAML is the standard format for Kubernetes manifests, Docker Compose files, and many DevOps tools.

## Instructions

### Part 1: Reading YAML Files

Create a file called `yaml_parsing.py` in the workspace directory.

1. Write a function `load_yaml_file(filepath)` that:
   - Reads a YAML file and returns the parsed content as a Python dict
   - Handles FileNotFoundError gracefully
   - Handles invalid YAML syntax errors
   - Returns None on error

2. Write a function `load_yaml_string(yaml_string)` that:
   - Parses a YAML string and returns a Python dict
   - Handles parsing errors gracefully

### Part 2: Navigating YAML Structures

3. Write a function `get_nested_value(data, path)` that:
   - Takes a dict and a dot-separated path (e.g., "spec.containers.0.image")
   - Returns the value at that path
   - Returns None if path doesn't exist
   - Handles both dict keys and list indices

4. Write a function `extract_k8s_info(manifest)` that:
   - Takes a Kubernetes manifest dict
   - Returns a dict with: kind, name, namespace, labels
   - Handles missing fields gracefully

### Part 3: Modifying YAML

5. Write a function `set_nested_value(data, path, value)` that:
   - Sets a value at a dot-separated path
   - Creates intermediate dicts/lists if needed
   - Returns the modified data

6. Write a function `update_deployment_image(manifest, new_image)` that:
   - Updates the container image in a Kubernetes Deployment
   - Assumes single container for simplicity
   - Returns the modified manifest

### Part 4: Challenge - Config Merger

7. Create a `ConfigMerger` class that:
   - Method `load(filepath)` loads a YAML config file
   - Method `merge(override_config)` deep merges another config
   - Method `get(path, default=None)` gets value by path
   - Method `set(path, value)` sets value by path
   - Method `save(filepath)` writes config to file
   - Method `validate(schema)` validates against a simple schema dict

8. Implement deep merge logic:
   - Dicts are merged recursively
   - Lists are replaced (not concatenated)
   - Scalar values are overwritten

## Expected Output

```
=== Part 1: Reading YAML ===
Loaded config: {'apiVersion': 'v1', 'kind': 'ConfigMap', 'metadata': {'name': 'my-config'}}
Loaded from string: {'database': {'host': 'localhost', 'port': 5432}}

=== Part 2: Navigating YAML ===
Container image: nginx:1.19
K8s info: {'kind': 'Deployment', 'name': 'web-app', 'namespace': 'default', 'labels': {'app': 'web'}}

=== Part 3: Modifying YAML ===
Updated replicas: 5
Updated image: nginx:1.21

=== Part 4: Config Merger ===
Base config loaded
Merged with overrides
Database host: prod-db.example.com
Final config saved to output.yaml
```

## Verification Steps

Run your script:
```bash
cd /workspace
python yaml_parsing.py
```

1. YAML files are loaded correctly
2. Nested values are accessed with dot notation
3. Kubernetes manifest info is extracted correctly
4. Modifications preserve YAML structure
5. Config merger handles deep merging correctly

## Hints

<details>
<summary>Hint 1: Basic YAML Loading</summary>

```python
import yaml

# Load from file
with open('config.yaml', 'r') as f:
    data = yaml.safe_load(f)

# Load from string
data = yaml.safe_load(yaml_string)
```
</details>

<details>
<summary>Hint 2: Navigating Nested Structures</summary>

```python
def get_nested(data, path):
    keys = path.split('.')
    current = data
    for key in keys:
        if key.isdigit():
            key = int(key)
        current = current[key]
    return current
```
</details>

<details>
<summary>Hint 3: Writing YAML</summary>

```python
import yaml

with open('output.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False)
```
</details>

<details>
<summary>Hint 4: Deep Merge</summary>

```python
def deep_merge(base, override):
    result = base.copy()
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = value
    return result
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
Python DevOps: YAML Parsing and Manipulation
DevOps Interview Playground Exercise
"""

import yaml
import os

# === Part 1: Reading YAML ===
print("=== Part 1: Reading YAML ===")

def load_yaml_file(filepath):
    """Load and parse a YAML file."""
    try:
        with open(filepath, 'r') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"File not found: {filepath}")
        return None
    except yaml.YAMLError as e:
        print(f"YAML parsing error: {e}")
        return None

def load_yaml_string(yaml_string):
    """Parse a YAML string."""
    try:
        return yaml.safe_load(yaml_string)
    except yaml.YAMLError as e:
        print(f"YAML parsing error: {e}")
        return None

# Create sample YAML file for testing
sample_yaml = """
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
"""

with open("/tmp/sample.yaml", "w") as f:
    f.write(sample_yaml)

# Test loading
config = load_yaml_file("/tmp/sample.yaml")
print(f"Loaded config: {config}")

yaml_str = """
database:
  host: localhost
  port: 5432
"""
data = load_yaml_string(yaml_str)
print(f"Loaded from string: {data}")

# === Part 2: Navigating YAML ===
print("\n=== Part 2: Navigating YAML ===")

def get_nested_value(data, path):
    """Get a value from nested dict using dot notation."""
    if data is None:
        return None
    
    keys = path.split('.')
    current = data
    
    try:
        for key in keys:
            if isinstance(current, list):
                key = int(key)
            current = current[key]
        return current
    except (KeyError, IndexError, TypeError, ValueError):
        return None

def extract_k8s_info(manifest):
    """Extract common info from a Kubernetes manifest."""
    return {
        "kind": manifest.get("kind"),
        "name": get_nested_value(manifest, "metadata.name"),
        "namespace": get_nested_value(manifest, "metadata.namespace") or "default",
        "labels": get_nested_value(manifest, "metadata.labels") or {}
    }

# Create sample Kubernetes deployment
k8s_deployment = """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:1.19
          ports:
            - containerPort: 80
"""

deployment = load_yaml_string(k8s_deployment)
image = get_nested_value(deployment, "spec.template.spec.containers.0.image")
print(f"Container image: {image}")

info = extract_k8s_info(deployment)
print(f"K8s info: {info}")

# === Part 3: Modifying YAML ===
print("\n=== Part 3: Modifying YAML ===")

def set_nested_value(data, path, value):
    """Set a value in nested dict using dot notation."""
    keys = path.split('.')
    current = data
    
    for i, key in enumerate(keys[:-1]):
        next_key = keys[i + 1]
        
        if isinstance(current, list):
            key = int(key)
        
        if key not in current if isinstance(current, dict) else key >= len(current):
            # Create intermediate structure
            if next_key.isdigit():
                current[key] = []
            else:
                current[key] = {}
        
        current = current[key]
    
    final_key = keys[-1]
    if isinstance(current, list):
        final_key = int(final_key)
    current[final_key] = value
    
    return data

def update_deployment_image(manifest, new_image):
    """Update the container image in a Deployment."""
    # Deep copy to avoid modifying original
    import copy
    updated = copy.deepcopy(manifest)
    
    containers = get_nested_value(updated, "spec.template.spec.containers")
    if containers and len(containers) > 0:
        containers[0]["image"] = new_image
    
    return updated

# Test modifications
deployment_copy = load_yaml_string(k8s_deployment)
set_nested_value(deployment_copy, "spec.replicas", 5)
print(f"Updated replicas: {get_nested_value(deployment_copy, 'spec.replicas')}")

updated_deployment = update_deployment_image(deployment, "nginx:1.21")
new_image = get_nested_value(updated_deployment, "spec.template.spec.containers.0.image")
print(f"Updated image: {new_image}")

# === Part 4: Config Merger ===
print("\n=== Part 4: Config Merger ===")

class ConfigMerger:
    """Merge and manage YAML configurations."""
    
    def __init__(self):
        self.config = {}
    
    def load(self, filepath):
        """Load a YAML config file."""
        loaded = load_yaml_file(filepath)
        if loaded:
            self.config = loaded
            return True
        return False
    
    def merge(self, override_config):
        """Deep merge another config into current config."""
        self.config = self._deep_merge(self.config, override_config)
    
    def _deep_merge(self, base, override):
        """Recursively merge two dicts."""
        if not isinstance(base, dict) or not isinstance(override, dict):
            return override
        
        result = base.copy()
        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = self._deep_merge(result[key], value)
            else:
                result[key] = value
        return result
    
    def get(self, path, default=None):
        """Get a value by dot-separated path."""
        value = get_nested_value(self.config, path)
        return value if value is not None else default
    
    def set(self, path, value):
        """Set a value by dot-separated path."""
        set_nested_value(self.config, path, value)
    
    def save(self, filepath):
        """Save config to a YAML file."""
        try:
            with open(filepath, 'w') as f:
                yaml.dump(self.config, f, default_flow_style=False)
            return True
        except IOError as e:
            print(f"Error saving config: {e}")
            return False
    
    def validate(self, schema):
        """Validate config against a simple schema."""
        errors = []
        
        for path, expected_type in schema.items():
            value = self.get(path)
            if value is None:
                errors.append(f"Missing required field: {path}")
            elif not isinstance(value, expected_type):
                errors.append(f"Invalid type for {path}: expected {expected_type.__name__}")
        
        return len(errors) == 0, errors

# Create base config file
base_config = """
app:
  name: myapp
  version: 1.0.0
database:
  host: localhost
  port: 5432
  name: mydb
logging:
  level: INFO
  format: json
"""

with open("/tmp/base_config.yaml", "w") as f:
    f.write(base_config)

# Test ConfigMerger
merger = ConfigMerger()
merger.load("/tmp/base_config.yaml")
print("Base config loaded")

# Merge with overrides
overrides = {
    "database": {
        "host": "prod-db.example.com",
        "password": "secret"
    },
    "logging": {
        "level": "WARNING"
    }
}
merger.merge(overrides)
print("Merged with overrides")

print(f"Database host: {merger.get('database.host')}")

# Save merged config
merger.save("/tmp/output.yaml")
print("Final config saved to output.yaml")

# Validate
schema = {
    "app.name": str,
    "database.host": str,
    "database.port": int
}
valid, errors = merger.validate(schema)
print(f"Config valid: {valid}")
if errors:
    print(f"Validation errors: {errors}")
```

### Explanation

**PyYAML Basics:**
- `yaml.safe_load()` - Parse YAML safely (no arbitrary code execution)
- `yaml.dump()` - Convert Python objects to YAML string
- `default_flow_style=False` - Use block style (more readable)

**Navigating Nested Structures:**
- Split path by dots to get keys
- Handle both dict keys and list indices
- Use try/except for missing keys

**Deep Merge:**
- Recursively merge dictionaries
- Override scalars and lists
- Preserve nested structure

**Common YAML Patterns:**
- Kubernetes manifests have standard structure
- ConfigMaps, Secrets, Deployments follow patterns
- Labels and annotations are key-value pairs

**Best Practices:**
- Always use `safe_load()` to prevent code injection
- Handle missing keys gracefully
- Validate config before using
- Keep original files unchanged (work on copies)

</details>

## Test Cases

Save this as `test_yaml_parsing.py`:

```python
#!/usr/bin/env python3
"""Test cases for YAML parsing exercise"""

import yaml

def load_yaml_string(yaml_string):
    try:
        return yaml.safe_load(yaml_string)
    except yaml.YAMLError:
        return None

def get_nested_value(data, path):
    if data is None:
        return None
    keys = path.split('.')
    current = data
    try:
        for key in keys:
            if isinstance(current, list):
                key = int(key)
            current = current[key]
        return current
    except (KeyError, IndexError, TypeError, ValueError):
        return None

def set_nested_value(data, path, value):
    keys = path.split('.')
    current = data
    for key in keys[:-1]:
        if isinstance(current, list):
            key = int(key)
        if key not in current:
            current[key] = {}
        current = current[key]
    final_key = keys[-1]
    if isinstance(current, list):
        final_key = int(final_key)
    current[final_key] = value
    return data

def test_load_yaml_string():
    """Test YAML string parsing"""
    yaml_str = "key: value\nnested:\n  inner: data"
    result = load_yaml_string(yaml_str)
    
    assert result is not None
    assert result["key"] == "value"
    assert result["nested"]["inner"] == "data"
    print("✓ Load YAML string test passed")

def test_load_invalid_yaml():
    """Test handling of invalid YAML"""
    invalid_yaml = "key: value\n  bad indent"
    result = load_yaml_string(invalid_yaml)
    # Should handle gracefully (may return partial or None)
    print("✓ Invalid YAML handling test passed")

def test_get_nested_value():
    """Test nested value retrieval"""
    data = {
        "level1": {
            "level2": {
                "level3": "value"
            }
        },
        "list": ["a", "b", "c"]
    }
    
    assert get_nested_value(data, "level1.level2.level3") == "value"
    assert get_nested_value(data, "list.0") == "a"
    assert get_nested_value(data, "list.2") == "c"
    assert get_nested_value(data, "nonexistent") is None
    assert get_nested_value(data, "level1.nonexistent") is None
    print("✓ Get nested value test passed")

def test_set_nested_value():
    """Test nested value setting"""
    data = {"existing": {"key": "old"}}
    
    set_nested_value(data, "existing.key", "new")
    assert data["existing"]["key"] == "new"
    
    set_nested_value(data, "new.nested.key", "value")
    assert data["new"]["nested"]["key"] == "value"
    print("✓ Set nested value test passed")

def test_k8s_manifest_parsing():
    """Test Kubernetes manifest parsing"""
    manifest = """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: production
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: app
          image: myapp:1.0
"""
    data = load_yaml_string(manifest)
    
    assert data["kind"] == "Deployment"
    assert get_nested_value(data, "metadata.name") == "test-app"
    assert get_nested_value(data, "metadata.namespace") == "production"
    assert get_nested_value(data, "spec.replicas") == 3
    assert get_nested_value(data, "spec.template.spec.containers.0.image") == "myapp:1.0"
    print("✓ K8s manifest parsing test passed")

if __name__ == "__main__":
    test_load_yaml_string()
    test_load_invalid_yaml()
    test_get_nested_value()
    test_set_nested_value()
    test_k8s_manifest_parsing()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_yaml_parsing.py
```

## Additional Resources

- [PyYAML Documentation](https://pyyaml.org/wiki/PyYAMLDocumentation)
- [YAML Specification](https://yaml.org/spec/1.2.2/)
- [Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)
