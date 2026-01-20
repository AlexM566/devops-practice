# Python DevOps: Configuration Management with Jinja2

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Python basics, YAML parsing, understanding of templating

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn to generate configuration files dynamically using Jinja2 templates. This is essential for managing configurations across multiple environments (dev, staging, production) and automating infrastructure setup.

## Instructions

### Part 1: Basic Jinja2 Templates

Create a file called `config_management.py` in the workspace directory.

1. Write a function `render_template(template_string, variables)` that:
   - Takes a Jinja2 template string and a dict of variables
   - Returns the rendered string
   - Handles undefined variables gracefully

2. Create a simple nginx config template and render it:
   ```
   server {
       listen {{ port }};
       server_name {{ server_name }};
       root {{ document_root }};
   }
   ```

### Part 2: Template Files and Loops

3. Write a function `render_template_file(template_path, variables, output_path=None)` that:
   - Loads a template from a file
   - Renders it with provided variables
   - Optionally writes to output file
   - Returns the rendered content

4. Create a template that uses loops and conditionals:
   - Generate a hosts file with multiple servers
   - Include conditional blocks for different environments

### Part 3: Advanced Templating

5. Write a function `render_kubernetes_manifest(template_path, config)` that:
   - Renders a Kubernetes deployment template
   - Supports environment variables, replicas, resource limits
   - Handles optional fields gracefully

6. Create custom Jinja2 filters:
   - `to_yaml`: Convert dict to YAML string
   - `base64_encode`: Encode string to base64
   - `quote`: Wrap string in quotes

### Part 4: Challenge - Config Generator

7. Create a `ConfigGenerator` class that:
   - Constructor takes a templates directory path
   - Method `add_environment(name, variables)` registers an environment
   - Method `render(template_name, environment)` renders for specific env
   - Method `render_all(template_name)` renders for all environments
   - Method `diff(template_name, env1, env2)` shows differences between envs

8. Implement template inheritance:
   - Base template with common settings
   - Environment-specific templates that extend base
   - Override blocks for customization

9. Add validation:
   - Method `validate_template(template_name)` checks for syntax errors
   - Method `list_variables(template_name)` returns required variables

## Expected Output

```
=== Part 1: Basic Templates ===
Rendered nginx config:
server {
    listen 8080;
    server_name example.com;
    root /var/www/html;
}

=== Part 2: Loops and Conditionals ===
Generated hosts file:
# Production servers
192.168.1.10 web-01.prod.local
192.168.1.11 web-02.prod.local
192.168.1.20 db-01.prod.local

# Monitoring enabled
192.168.1.30 monitor.prod.local

=== Part 3: Kubernetes Manifest ===
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: web-app
          image: myapp:1.2.3
          resources:
            limits:
              cpu: "500m"
              memory: "256Mi"

=== Part 4: Config Generator ===
Environments: ['development', 'staging', 'production']
Development config generated: config/dev/app.conf
Production config generated: config/prod/app.conf

Diff between dev and prod:
- replicas: 1
+ replicas: 5
- debug: true
+ debug: false
```

## Verification Steps

Run your script:
```bash
cd /workspace
python config_management.py
```

1. Basic templates render with variable substitution
2. Loops generate repeated content correctly
3. Conditionals include/exclude content based on variables
4. Kubernetes manifests are valid YAML
5. Custom filters work correctly
6. ConfigGenerator manages multiple environments
7. Diff shows meaningful differences between configs

## Hints

<details>
<summary>Hint 1: Basic Jinja2 Usage</summary>

```python
from jinja2 import Template

template = Template("Hello {{ name }}!")
result = template.render(name="World")
```
</details>

<details>
<summary>Hint 2: Loading Templates from Files</summary>

```python
from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('templates'))
template = env.get_template('config.j2')
result = template.render(variables)
```
</details>

<details>
<summary>Hint 3: Loops in Templates</summary>

```jinja2
{% for server in servers %}
{{ server.ip }} {{ server.name }}
{% endfor %}
```
</details>

<details>
<summary>Hint 4: Custom Filters</summary>

```python
import yaml
import base64

def to_yaml_filter(value):
    return yaml.dump(value, default_flow_style=False)

env = Environment(...)
env.filters['to_yaml'] = to_yaml_filter
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
Python DevOps: Configuration Management with Jinja2
DevOps Interview Playground Exercise
"""

import os
import yaml
import base64
import difflib
from jinja2 import Environment, FileSystemLoader, BaseLoader, Template, meta, UndefinedError

# === Part 1: Basic Templates ===
print("=== Part 1: Basic Templates ===")

def render_template(template_string, variables):
    """Render a Jinja2 template string with variables."""
    try:
        template = Template(template_string)
        return template.render(**variables)
    except UndefinedError as e:
        print(f"Template error: {e}")
        return None

# Test basic template
nginx_template = """server {
    listen {{ port }};
    server_name {{ server_name }};
    root {{ document_root }};
}"""

nginx_vars = {
    "port": 8080,
    "server_name": "example.com",
    "document_root": "/var/www/html"
}

result = render_template(nginx_template, nginx_vars)
print("Rendered nginx config:")
print(result)

# === Part 2: Loops and Conditionals ===
print("\n=== Part 2: Loops and Conditionals ===")

def render_template_file(template_string, variables, output_path=None):
    """Render a template and optionally save to file."""
    try:
        template = Template(template_string)
        rendered = template.render(**variables)
        
        if output_path:
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with open(output_path, 'w') as f:
                f.write(rendered)
        
        return rendered
    except Exception as e:
        print(f"Error rendering template: {e}")
        return None

# Template with loops and conditionals
hosts_template = """# {{ environment | capitalize }} servers
{% for server in servers %}
{{ server.ip }} {{ server.name }}.{{ domain }}
{% endfor %}
{% if monitoring_enabled %}

# Monitoring enabled
{{ monitoring_server.ip }} {{ monitoring_server.name }}.{{ domain }}
{% endif %}
"""

hosts_vars = {
    "environment": "production",
    "domain": "prod.local",
    "servers": [
        {"ip": "192.168.1.10", "name": "web-01"},
        {"ip": "192.168.1.11", "name": "web-02"},
        {"ip": "192.168.1.20", "name": "db-01"},
    ],
    "monitoring_enabled": True,
    "monitoring_server": {"ip": "192.168.1.30", "name": "monitor"}
}

result = render_template_file(hosts_template, hosts_vars)
print("Generated hosts file:")
print(result)

# === Part 3: Kubernetes Manifest ===
print("\n=== Part 3: Kubernetes Manifest ===")

# Custom Jinja2 filters
def to_yaml_filter(value, indent=0):
    """Convert a Python object to YAML string."""
    yaml_str = yaml.dump(value, default_flow_style=False)
    if indent > 0:
        lines = yaml_str.split('\n')
        yaml_str = '\n'.join(' ' * indent + line if line else line for line in lines)
    return yaml_str.rstrip()

def base64_encode_filter(value):
    """Encode a string to base64."""
    return base64.b64encode(value.encode()).decode()

def quote_filter(value):
    """Wrap a value in quotes."""
    return f'"{value}"'

# Create environment with custom filters
def create_jinja_env():
    """Create Jinja2 environment with custom filters."""
    env = Environment(loader=BaseLoader())
    env.filters['to_yaml'] = to_yaml_filter
    env.filters['base64_encode'] = base64_encode_filter
    env.filters['quote'] = quote_filter
    return env

def render_kubernetes_manifest(template_string, config):
    """Render a Kubernetes manifest template."""
    env = create_jinja_env()
    template = env.from_string(template_string)
    return template.render(**config)

# Kubernetes deployment template
k8s_template = """apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ name }}
  namespace: {{ namespace | default('default') }}
  labels:
    app: {{ name }}
spec:
  replicas: {{ replicas | default(1) }}
  selector:
    matchLabels:
      app: {{ name }}
  template:
    metadata:
      labels:
        app: {{ name }}
    spec:
      containers:
        - name: {{ name }}
          image: {{ image }}:{{ version }}
{% if resources %}
          resources:
            limits:
              cpu: {{ resources.cpu | quote }}
              memory: {{ resources.memory | quote }}
{% endif %}
{% if env_vars %}
          env:
{% for key, value in env_vars.items() %}
            - name: {{ key }}
              value: {{ value | quote }}
{% endfor %}
{% endif %}
"""

k8s_config = {
    "name": "web-app",
    "namespace": "production",
    "replicas": 3,
    "image": "myapp",
    "version": "1.2.3",
    "resources": {
        "cpu": "500m",
        "memory": "256Mi"
    },
    "env_vars": {
        "LOG_LEVEL": "info",
        "DB_HOST": "postgres.production"
    }
}

result = render_kubernetes_manifest(k8s_template, k8s_config)
print("Kubernetes Deployment:")
print(result)

# === Part 4: Config Generator ===
print("\n=== Part 4: Config Generator ===")

class ConfigGenerator:
    """Generate configuration files for multiple environments."""
    
    def __init__(self, templates_dir=None):
        """Initialize with optional templates directory."""
        self.templates_dir = templates_dir
        self.environments = {}
        self.env = create_jinja_env()
        
        if templates_dir and os.path.exists(templates_dir):
            self.env = Environment(
                loader=FileSystemLoader(templates_dir)
            )
            self.env.filters['to_yaml'] = to_yaml_filter
            self.env.filters['base64_encode'] = base64_encode_filter
            self.env.filters['quote'] = quote_filter
    
    def add_environment(self, name, variables):
        """Register an environment with its variables."""
        self.environments[name] = variables
    
    def render(self, template_string, environment):
        """Render a template for a specific environment."""
        if environment not in self.environments:
            raise ValueError(f"Unknown environment: {environment}")
        
        variables = self.environments[environment]
        template = self.env.from_string(template_string)
        return template.render(**variables)
    
    def render_all(self, template_string):
        """Render a template for all environments."""
        results = {}
        for env_name in self.environments:
            results[env_name] = self.render(template_string, env_name)
        return results
    
    def diff(self, template_string, env1, env2):
        """Show differences between two environment configs."""
        config1 = self.render(template_string, env1)
        config2 = self.render(template_string, env2)
        
        diff = difflib.unified_diff(
            config1.splitlines(keepends=True),
            config2.splitlines(keepends=True),
            fromfile=env1,
            tofile=env2
        )
        return ''.join(diff)
    
    def validate_template(self, template_string):
        """Check template for syntax errors."""
        try:
            self.env.parse(template_string)
            return True, None
        except Exception as e:
            return False, str(e)
    
    def list_variables(self, template_string):
        """List variables used in a template."""
        ast = self.env.parse(template_string)
        return meta.find_undeclared_variables(ast)

# Test ConfigGenerator
generator = ConfigGenerator()

# Add environments
generator.add_environment("development", {
    "app_name": "myapp",
    "replicas": 1,
    "debug": True,
    "log_level": "DEBUG",
    "database_host": "localhost",
    "cache_enabled": False
})

generator.add_environment("staging", {
    "app_name": "myapp",
    "replicas": 2,
    "debug": True,
    "log_level": "INFO",
    "database_host": "staging-db.internal",
    "cache_enabled": True
})

generator.add_environment("production", {
    "app_name": "myapp",
    "replicas": 5,
    "debug": False,
    "log_level": "WARNING",
    "database_host": "prod-db.internal",
    "cache_enabled": True
})

print(f"Environments: {list(generator.environments.keys())}")

# App config template
app_config_template = """# Application Configuration
app_name: {{ app_name }}
replicas: {{ replicas }}
debug: {{ debug }}
log_level: {{ log_level }}
database:
  host: {{ database_host }}
  pool_size: {{ replicas * 5 }}
{% if cache_enabled %}
cache:
  enabled: true
  ttl: 3600
{% endif %}
"""

# Render for all environments
print("\nDevelopment config:")
dev_config = generator.render(app_config_template, "development")
print(dev_config)

print("Production config:")
prod_config = generator.render(app_config_template, "production")
print(prod_config)

# Show diff
print("Diff between development and production:")
diff = generator.diff(app_config_template, "development", "production")
print(diff)

# Validate template
valid, error = generator.validate_template(app_config_template)
print(f"\nTemplate valid: {valid}")

# List variables
variables = generator.list_variables(app_config_template)
print(f"Required variables: {variables}")

# Test custom filters
print("\n=== Custom Filters Demo ===")
filter_template = """
Secret (base64): {{ password | base64_encode }}
Quoted value: {{ name | quote }}
YAML output:
{{ config | to_yaml }}
"""

filter_vars = {
    "password": "mysecret123",
    "name": "my-service",
    "config": {
        "key1": "value1",
        "key2": ["item1", "item2"],
        "nested": {"a": 1, "b": 2}
    }
}

result = render_template(filter_template, filter_vars)
print(result)
```

### Explanation

**Jinja2 Basics:**
- `{{ variable }}` - Output a variable
- `{% for item in list %}` - Loop construct
- `{% if condition %}` - Conditional block
- `{{ var | filter }}` - Apply filter to variable

**Template Loading:**
- `Template(string)` - Create from string
- `FileSystemLoader` - Load from directory
- `Environment` - Configure template engine

**Custom Filters:**
- Functions that transform values
- Register with `env.filters['name'] = func`
- Chain filters: `{{ var | filter1 | filter2 }}`

**Template Inheritance:**
- `{% extends "base.j2" %}` - Inherit from base
- `{% block name %}` - Define overridable blocks
- Useful for DRY configuration

**Variable Discovery:**
- `meta.find_undeclared_variables()` - Find required vars
- Useful for validation and documentation
- Helps catch missing variables early

**Best Practices:**
- Use meaningful variable names
- Provide defaults with `| default(value)`
- Validate templates before deployment
- Keep templates simple and readable
- Use inheritance for common patterns

</details>

## Test Cases

Save this as `test_config_management.py`:

```python
#!/usr/bin/env python3
"""Test cases for config management exercise"""

from jinja2 import Template, Environment, BaseLoader, meta
import yaml
import base64

def render_template(template_string, variables):
    template = Template(template_string)
    return template.render(**variables)

def to_yaml_filter(value):
    return yaml.dump(value, default_flow_style=False).rstrip()

def base64_encode_filter(value):
    return base64.b64encode(value.encode()).decode()

def test_basic_template():
    """Test basic variable substitution"""
    template = "Hello {{ name }}!"
    result = render_template(template, {"name": "World"})
    assert result == "Hello World!"
    print("✓ Basic template test passed")

def test_loop_template():
    """Test loop in template"""
    template = "{% for item in items %}{{ item }},{% endfor %}"
    result = render_template(template, {"items": ["a", "b", "c"]})
    assert result == "a,b,c,"
    print("✓ Loop template test passed")

def test_conditional_template():
    """Test conditional in template"""
    template = "{% if enabled %}ON{% else %}OFF{% endif %}"
    
    result = render_template(template, {"enabled": True})
    assert result == "ON"
    
    result = render_template(template, {"enabled": False})
    assert result == "OFF"
    print("✓ Conditional template test passed")

def test_default_filter():
    """Test default filter"""
    template = "{{ value | default('fallback') }}"
    
    result = render_template(template, {"value": "actual"})
    assert result == "actual"
    
    result = render_template(template, {})
    assert result == "fallback"
    print("✓ Default filter test passed")

def test_custom_filters():
    """Test custom filters"""
    # Test base64 encode
    result = base64_encode_filter("hello")
    assert result == base64.b64encode(b"hello").decode()
    
    # Test to_yaml
    data = {"key": "value"}
    result = to_yaml_filter(data)
    assert "key: value" in result
    print("✓ Custom filters test passed")

def test_variable_discovery():
    """Test finding undeclared variables"""
    env = Environment(loader=BaseLoader())
    template_str = "{{ name }} - {{ age }} - {{ city }}"
    ast = env.parse(template_str)
    variables = meta.find_undeclared_variables(ast)
    
    assert "name" in variables
    assert "age" in variables
    assert "city" in variables
    print("✓ Variable discovery test passed")

def test_nested_variables():
    """Test nested variable access"""
    template = "{{ server.host }}:{{ server.port }}"
    result = render_template(template, {
        "server": {"host": "localhost", "port": 8080}
    })
    assert result == "localhost:8080"
    print("✓ Nested variables test passed")

if __name__ == "__main__":
    test_basic_template()
    test_loop_template()
    test_conditional_template()
    test_default_filter()
    test_custom_filters()
    test_variable_discovery()
    test_nested_variables()
    print("\n✅ All tests passed!")
```

Run tests with:
```bash
python test_config_management.py
```

## Additional Resources

- [Jinja2 Documentation](https://jinja.palletsprojects.com/)
- [Jinja2 Template Designer Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates/)
- [Ansible Templating (uses Jinja2)](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)
