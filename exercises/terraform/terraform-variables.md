# Terraform Variables and Outputs

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Completed terraform-basics.md, understanding of Terraform resource blocks

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to make Terraform configurations flexible and reusable using input variables, and how to expose information about created resources using output values. Understand different variable types, default values, and how to pass variables via command line and files.

## Instructions

In this exercise, you'll create a Terraform configuration that uses variables to customize resource creation and outputs to display information about the created resources.

### Step 1: Create a Working Directory

```bash
mkdir -p ~/terraform-practice/variables
cd ~/terraform-practice/variables
```

### Step 2: Create the Main Configuration

Create `main.tf`:

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

# TODO: Create a local_file resource that uses variables
# Use var.filename for the filename
# Use var.message and var.author to build the content
```

### Step 3: Create Variables File

Create `variables.tf` to define your input variables:

```hcl
# TODO: Define the following variables:
# 1. filename (string) - default: "output/message.txt"
# 2. message (string) - default: "Hello from Terraform"
# 3. author (string) - no default (user must provide)
# 4. tags (map of strings) - default: { Environment = "dev" }
```

### Step 4: Create Outputs File

Create `outputs.tf` to define what information to display:

```hcl
# TODO: Define the following outputs:
# 1. file_path - the full path to the created file
# 2. file_content - the content of the file
# 3. applied_tags - the tags that were applied
```

### Step 5: Initialize and Apply with Defaults

```bash
terraform init
terraform plan
```

You should see an error because `author` has no default value.

### Step 6: Apply with Variable via Command Line

Provide the required variable:

```bash
terraform apply -var="author=YourName"
```

### Step 7: View Outputs

After applying, view the outputs:

```bash
terraform output
terraform output file_path
terraform output file_content
```

### Step 8: Override Variables

Apply again with different values:

```bash
terraform apply -var="author=Alice" -var="message=Custom message" -var="filename=output/custom.txt"
```

### Step 9: Use a Variables File

Create `terraform.tfvars`:

```hcl
author  = "Bob"
message = "Configuration from tfvars file"
filename = "output/bob-message.txt"
tags = {
  Environment = "production"
  Team        = "DevOps"
}
```

Apply using the tfvars file:

```bash
terraform apply
```

### Step 10: Clean Up

```bash
terraform destroy
```

## Expected Output

**After `terraform plan` (without author):**
```
Error: No value for required variable

  on variables.tf line X:
   X: variable "author" {

The variable "author" is required, but no definition was found.
```

**After `terraform apply -var="author=YourName"`:**
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

applied_tags = {
  "Environment" = "dev"
}
file_content = "Hello from Terraform - by YourName"
file_path = "output/message.txt"
```

**After `terraform output`:**
```
applied_tags = {
  "Environment" = "dev"
}
file_content = "Hello from Terraform - by YourName"
file_path = "output/message.txt"
```

**After applying with tfvars file:**
```
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

applied_tags = {
  "Environment" = "production"
  "Team" = "DevOps"
}
file_content = "Configuration from tfvars file - by Bob"
file_path = "output/bob-message.txt"
```

## Verification Steps

1. ✓ Variables are defined in `variables.tf`
2. ✓ Outputs are defined in `outputs.tf`
3. ✓ `terraform plan` fails without required variable
4. ✓ `terraform apply` succeeds when variable is provided
5. ✓ Outputs display correct information
6. ✓ Variables can be overridden via command line
7. ✓ Variables can be set via `terraform.tfvars` file
8. ✓ File content includes both message and author

## Hints

<details>
<summary>Hint 1: Variable Definition Syntax</summary>

Variables are defined in `variables.tf` using this syntax:

```hcl
variable "variable_name" {
  description = "Description of the variable"
  type        = string  # or map(string), list(string), etc.
  default     = "default_value"  # optional
}
```

To make a variable required, omit the `default` attribute.
</details>

<details>
<summary>Hint 2: Using Variables in Resources</summary>

Reference variables in your configuration using `var.variable_name`:

```hcl
resource "local_file" "example" {
  filename = var.filename
  content  = "${var.message} - by ${var.author}"
}
```

Use string interpolation with `${}` to combine variables.
</details>

<details>
<summary>Hint 3: Output Syntax</summary>

Outputs are defined in `outputs.tf`:

```hcl
output "output_name" {
  description = "Description of the output"
  value       = resource_type.resource_name.attribute
}
```

For example, to output the filename:
```hcl
output "file_path" {
  value = local_file.my_resource.filename
}
```
</details>

<details>
<summary>Hint 4: Variable Types</summary>

Common variable types:
- `string` - Single text value
- `number` - Numeric value
- `bool` - true or false
- `list(string)` - List of strings
- `map(string)` - Key-value pairs

For tags, use `map(string)`:
```hcl
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}
```
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

**`main.tf`:**

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

resource "local_file" "message" {
  filename = var.filename
  content  = "${var.message} - by ${var.author}"
}
```

**`variables.tf`:**

```hcl
variable "filename" {
  description = "Name of the output file"
  type        = string
  default     = "output/message.txt"
}

variable "message" {
  description = "Message to write to the file"
  type        = string
  default     = "Hello from Terraform"
}

variable "author" {
  description = "Author of the message (required)"
  type        = string
  # No default - this makes it required
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
  }
}
```

**`outputs.tf`:**

```hcl
output "file_path" {
  description = "Path to the created file"
  value       = local_file.message.filename
}

output "file_content" {
  description = "Content of the created file"
  value       = local_file.message.content
}

output "applied_tags" {
  description = "Tags applied to resources"
  value       = var.tags
}
```

**`terraform.tfvars`:**

```hcl
author  = "Bob"
message = "Configuration from tfvars file"
filename = "output/bob-message.txt"
tags = {
  Environment = "production"
  Team        = "DevOps"
}
```

**Complete workflow:**

```bash
# Create directory
mkdir -p ~/terraform-practice/variables
cd ~/terraform-practice/variables

# Create the three .tf files above

# Initialize
terraform init

# Try to plan (will fail - missing required variable)
terraform plan

# Apply with variable via CLI
terraform apply -var="author=YourName"

# View outputs
terraform output
terraform output file_path

# Apply with different values
terraform apply -var="author=Alice" -var="message=Custom message"

# Create terraform.tfvars file
# Apply using tfvars (automatically loaded)
terraform apply

# Clean up
terraform destroy
```

**Explanation:**

1. **Input Variables**: Make configurations flexible and reusable
   - Define in `variables.tf`
   - Reference with `var.variable_name`
   - Can have defaults or be required
   - Support different types (string, number, list, map, etc.)

2. **Variable Precedence** (highest to lowest):
   - Command line `-var` flags
   - `terraform.tfvars` file
   - Environment variables (`TF_VAR_name`)
   - Default values in variable definitions

3. **Outputs**: Expose information about created resources
   - Define in `outputs.tf`
   - View with `terraform output`
   - Can be used by other Terraform configurations
   - Can be marked as sensitive to hide values

4. **String Interpolation**: Combine variables and text
   - Use `"${var.name}"` syntax
   - Can include multiple variables and functions

</details>

## Challenge

Try extending this exercise:

1. Add a `list(string)` variable called `recipients` and include them in the file content
2. Add a `number` variable for a version number
3. Create a sensitive variable and mark the corresponding output as sensitive
4. Use the `length()` function to output the number of tags
5. Add validation rules to a variable (e.g., filename must end with `.txt`)

## Additional Resources

- [Input Variables Documentation](https://www.terraform.io/language/values/variables)
- [Output Values Documentation](https://www.terraform.io/language/values/outputs)
- [Variable Definition Precedence](https://www.terraform.io/language/values/variables#variable-definition-precedence)
- [Type Constraints](https://www.terraform.io/language/expressions/type-constraints)
- [String Interpolation](https://www.terraform.io/language/expressions/strings)
