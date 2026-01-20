# Terraform Modules

**Difficulty:** Intermediate
**Estimated Time:** 30 minutes
**Prerequisites:** Completed terraform-basics.md and terraform-variables.md, understanding of variables and outputs

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to create reusable Terraform modules to organize code, promote DRY (Don't Repeat Yourself) principles, and build composable infrastructure. Understand module structure, how to pass inputs to modules, and how to use module outputs.

## Instructions

In this exercise, you'll create a reusable module for creating configuration files, then use that module multiple times from a root configuration to create different files with different settings.

### Step 1: Create Project Structure

```bash
mkdir -p ~/terraform-practice/modules-demo
cd ~/terraform-practice/modules-demo
mkdir -p modules/config-file
```

Your directory structure will be:
```
modules-demo/
├── main.tf              # Root module (calls child modules)
├── outputs.tf           # Root module outputs
└── modules/
    └── config-file/     # Reusable module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Step 2: Create the Module

First, create the module's variable definitions in `modules/config-file/variables.tf`:

```hcl
# TODO: Define the following variables for the module:
# 1. config_name (string, required) - Name of the configuration
# 2. config_data (map(string), required) - Configuration key-value pairs
# 3. output_dir (string, default: "output") - Directory for the file
# 4. file_format (string, default: "json") - Format: json or yaml
```

Next, create the module's main configuration in `modules/config-file/main.tf`:

```hcl
# TODO: Create a local_file resource that:
# 1. Creates a file named "${var.output_dir}/${var.config_name}.${var.file_format}"
# 2. Uses jsonencode(var.config_data) for the content if format is json
# 3. Uses yamlencode(var.config_data) for the content if format is yaml
# Hint: Use a conditional expression with the ternary operator
```

Finally, create the module's outputs in `modules/config-file/outputs.tf`:

```hcl
# TODO: Define the following outputs:
# 1. file_path - Path to the created file
# 2. file_id - ID of the file resource
# 3. config_name - Name of the configuration (pass through)
```

### Step 3: Create the Root Configuration

Create `main.tf` in the root directory:

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Use the config-file module to create an app configuration
# Module source: "./modules/config-file"
# config_name: "app-config"
# config_data: { app_name = "my-app", port = "8080", environment = "dev" }

# TODO: Use the config-file module to create a database configuration
# Module source: "./modules/config-file"
# config_name: "db-config"
# config_data: { host = "localhost", port = "5432", database = "mydb" }
# file_format: "yaml"

# TODO: Use the config-file module to create a cache configuration
# Module source: "./modules/config-file"
# config_name: "cache-config"
# config_data: { host = "localhost", port = "6379", ttl = "3600" }
# output_dir: "output/configs"
```

### Step 4: Create Root Outputs

Create `outputs.tf` in the root directory:

```hcl
# TODO: Create outputs that display:
# 1. All file paths from all three module instances
# 2. The app config file path specifically
# 3. The database config file path specifically
```

### Step 5: Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Step 6: Verify the Created Files

Check that all files were created:

```bash
ls -la output/
ls -la output/configs/
cat output/app-config.json
cat output/db-config.yaml
cat output/configs/cache-config.json
```

### Step 7: View Module Outputs

```bash
terraform output
```

### Step 8: Explore the State

See how modules are tracked in state:

```bash
terraform state list
```

Notice the module prefix in resource names.

### Step 9: Clean Up

```bash
terraform destroy
```

## Expected Output

**After `terraform init`:**
```
Initializing modules...
- app_config in modules/config-file
- cache_config in modules/config-file
- db_config in modules/config-file

Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

**After `terraform plan`:**
```
Terraform will perform the following actions:

  # module.app_config.local_file.config will be created
  + resource "local_file" "config" {
      + content   = jsonencode(...)
      + filename  = "output/app-config.json"
      + id        = (known after apply)
    }

  # module.cache_config.local_file.config will be created
  ...

  # module.db_config.local_file.config will be created
  ...

Plan: 3 to add, 0 to change, 0 to destroy.
```

**After `terraform apply`:**
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

app_config_path = "output/app-config.json"
db_config_path = "output/db-config.yaml"
all_config_paths = [
  "output/app-config.json",
  "output/db-config.yaml",
  "output/configs/cache-config.json",
]
```

**File contents:**

`output/app-config.json`:
```json
{"app_name":"my-app","environment":"dev","port":"8080"}
```

`output/db-config.yaml`:
```yaml
database: mydb
host: localhost
port: "5432"
```

**After `terraform state list`:**
```
module.app_config.local_file.config
module.cache_config.local_file.config
module.db_config.local_file.config
```

## Verification Steps

1. ✓ Module directory structure is created correctly
2. ✓ Module has variables.tf, main.tf, and outputs.tf
3. ✓ Root configuration calls the module multiple times
4. ✓ `terraform init` downloads the module
5. ✓ `terraform plan` shows 3 resources to create
6. ✓ All three config files are created
7. ✓ JSON and YAML formats are both working
8. ✓ Outputs display information from modules
9. ✓ State shows module prefixes

## Hints

<details>
<summary>Hint 1: Module Block Syntax</summary>

To use a module in your root configuration:

```hcl
module "module_instance_name" {
  source = "./path/to/module"
  
  # Pass values to module variables
  variable_name = "value"
  another_var   = "another_value"
}
```

The `source` can be a local path, Git repository, or Terraform Registry.
</details>

<details>
<summary>Hint 2: Conditional Expression for File Format</summary>

Use the ternary operator to choose between JSON and YAML:

```hcl
content = var.file_format == "json" ? jsonencode(var.config_data) : yamlencode(var.config_data)
```

Syntax: `condition ? true_value : false_value`
</details>

<details>
<summary>Hint 3: Accessing Module Outputs</summary>

Reference module outputs in the root configuration:

```hcl
output "app_config_path" {
  value = module.app_config.file_path
}
```

Use `module.module_instance_name.output_name` syntax.
</details>

<details>
<summary>Hint 4: Module Variables</summary>

Module variables work just like root variables, but they're scoped to the module:

**modules/config-file/variables.tf:**
```hcl
variable "config_name" {
  description = "Name of the configuration"
  type        = string
}

variable "config_data" {
  description = "Configuration data as key-value pairs"
  type        = map(string)
}
```

These must be provided when calling the module (unless they have defaults).
</details>

<details>
<summary>Hint 5: Module Outputs</summary>

Module outputs expose information to the calling configuration:

**modules/config-file/outputs.tf:**
```hcl
output "file_path" {
  value = local_file.config.filename
}
```

These can be accessed in the root module using `module.instance_name.output_name`.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

**`modules/config-file/variables.tf`:**

```hcl
variable "config_name" {
  description = "Name of the configuration"
  type        = string
}

variable "config_data" {
  description = "Configuration data as key-value pairs"
  type        = map(string)
}

variable "output_dir" {
  description = "Directory where the config file will be created"
  type        = string
  default     = "output"
}

variable "file_format" {
  description = "Format of the config file (json or yaml)"
  type        = string
  default     = "json"
  
  validation {
    condition     = contains(["json", "yaml"], var.file_format)
    error_message = "file_format must be either 'json' or 'yaml'"
  }
}
```

**`modules/config-file/main.tf`:**

```hcl
resource "local_file" "config" {
  filename = "${var.output_dir}/${var.config_name}.${var.file_format}"
  content  = var.file_format == "json" ? jsonencode(var.config_data) : yamlencode(var.config_data)
}
```

**`modules/config-file/outputs.tf`:**

```hcl
output "file_path" {
  description = "Path to the created configuration file"
  value       = local_file.config.filename
}

output "file_id" {
  description = "ID of the file resource"
  value       = local_file.config.id
}

output "config_name" {
  description = "Name of the configuration"
  value       = var.config_name
}
```

**`main.tf` (root):**

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

module "app_config" {
  source = "./modules/config-file"

  config_name = "app-config"
  config_data = {
    app_name    = "my-app"
    port        = "8080"
    environment = "dev"
  }
}

module "db_config" {
  source = "./modules/config-file"

  config_name = "db-config"
  config_data = {
    host     = "localhost"
    port     = "5432"
    database = "mydb"
  }
  file_format = "yaml"
}

module "cache_config" {
  source = "./modules/config-file"

  config_name = "cache-config"
  config_data = {
    host = "localhost"
    port = "6379"
    ttl  = "3600"
  }
  output_dir = "output/configs"
}
```

**`outputs.tf` (root):**

```hcl
output "app_config_path" {
  description = "Path to the app configuration file"
  value       = module.app_config.file_path
}

output "db_config_path" {
  description = "Path to the database configuration file"
  value       = module.db_config.file_path
}

output "all_config_paths" {
  description = "Paths to all configuration files"
  value = [
    module.app_config.file_path,
    module.db_config.file_path,
    module.cache_config.file_path,
  ]
}
```

**Complete workflow:**

```bash
# Create directory structure
mkdir -p ~/terraform-practice/modules-demo/modules/config-file
cd ~/terraform-practice/modules-demo

# Create all the files above in their respective locations

# Initialize (downloads modules)
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Verify files
ls -la output/
ls -la output/configs/
cat output/app-config.json
cat output/db-config.yaml
cat output/configs/cache-config.json

# View outputs
terraform output
terraform output all_config_paths

# View state with module prefixes
terraform state list
terraform state show module.app_config.local_file.config

# Clean up
terraform destroy
```

**Explanation:**

1. **Module Structure**:
   - Modules are self-contained Terraform configurations
   - Typically have variables.tf, main.tf, outputs.tf
   - Can be reused multiple times with different inputs

2. **Module Source**:
   - Local path: `./modules/config-file`
   - Git: `git::https://github.com/user/repo.git//path/to/module`
   - Registry: `hashicorp/consul/aws`

3. **Module Inputs**:
   - Defined as variables in the module
   - Passed as arguments when calling the module
   - Can have defaults or be required

4. **Module Outputs**:
   - Expose information from the module
   - Accessed with `module.instance_name.output_name`
   - Can be used in root outputs or other resources

5. **Benefits of Modules**:
   - Code reusability (DRY principle)
   - Encapsulation and abstraction
   - Easier testing and maintenance
   - Consistent patterns across infrastructure
   - Team collaboration and sharing

6. **Module Instances**:
   - Same module can be called multiple times
   - Each call creates a separate instance
   - Instances are tracked separately in state
   - Use different instance names for each call

</details>

## Challenge

Try extending this exercise:

1. Add a `count` or `for_each` to create multiple configs from a list
2. Create a second module for creating directories and use both modules together
3. Add a module variable for file permissions
4. Create a module that calls another module (nested modules)
5. Publish your module to a Git repository and reference it by URL
6. Add validation rules to module variables
7. Create a module that conditionally creates resources based on a variable

## Additional Resources

- [Modules Documentation](https://www.terraform.io/language/modules)
- [Module Sources](https://www.terraform.io/language/modules/sources)
- [Terraform Registry](https://registry.terraform.io/)
- [Module Best Practices](https://www.terraform.io/language/modules/develop)
- [Module Composition Patterns](https://www.terraform.io/language/modules/develop/composition)
- [Publishing Modules](https://www.terraform.io/registry/modules/publish)
