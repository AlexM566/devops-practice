# Terraform Basics

**Difficulty:** Beginner
**Estimated Time:** 20 minutes
**Prerequisites:** Terraform CLI installed, basic command line knowledge

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn the fundamental Terraform workflow by creating a simple configuration, initializing Terraform, previewing changes with plan, applying the configuration to create resources, and cleaning up with destroy.

## Instructions

In this exercise, you'll create a basic Terraform configuration that creates local files, then use the core Terraform commands to manage the infrastructure lifecycle.

### Step 1: Create a Working Directory

```bash
mkdir -p ~/terraform-practice/basics
cd ~/terraform-practice/basics
```

### Step 2: Write Your First Terraform Configuration

Create a file named `main.tf` with the following structure:

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

# TODO: Add a resource block to create a local file
# Resource type: local_file
# Resource name: welcome
# Filename: output/welcome.txt
# Content: "Welcome to Terraform!"
```

Your task is to add a `resource` block that creates a local file with:
- Resource type: `local_file`
- Resource name: `welcome`
- Filename: `output/welcome.txt`
- Content: `"Welcome to Terraform!"`

### Step 3: Initialize Terraform

Run the initialization command to download the required provider:

```bash
terraform init
```

### Step 4: Validate Your Configuration

Check that your configuration syntax is correct:

```bash
terraform validate
```

### Step 5: Preview Changes

Generate an execution plan to see what Terraform will do:

```bash
terraform plan
```

### Step 6: Apply the Configuration

Create the resources defined in your configuration:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 7: Verify the Resource

Check that the file was created:

```bash
cat output/welcome.txt
```

### Step 8: View the State

Terraform tracks resources in a state file. List the resources:

```bash
terraform state list
```

Show details about your resource:

```bash
terraform state show local_file.welcome
```

### Step 9: Clean Up

Destroy the resources you created:

```bash
terraform destroy
```

Type `yes` when prompted to confirm.

## Expected Output

**After `terraform init`:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.0"...
- Installing hashicorp/local v2.x.x...
Terraform has been successfully initialized!
```

**After `terraform plan`:**
```
Terraform will perform the following actions:

  # local_file.welcome will be created
  + resource "local_file" "welcome" {
      + content              = "Welcome to Terraform!"
      + filename             = "output/welcome.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**After `terraform apply`:**
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**File content:**
```
Welcome to Terraform!
```

**After `terraform state list`:**
```
local_file.welcome
```

## Verification Steps

1. ✓ `terraform init` completes without errors
2. ✓ `terraform validate` reports configuration is valid
3. ✓ `terraform plan` shows 1 resource to add
4. ✓ `terraform apply` creates the file successfully
5. ✓ The file `output/welcome.txt` exists with correct content
6. ✓ `terraform state list` shows the resource
7. ✓ `terraform destroy` removes the file

## Hints

<details>
<summary>Hint 1: Resource Block Syntax</summary>

A resource block follows this pattern:
```hcl
resource "RESOURCE_TYPE" "RESOURCE_NAME" {
  argument1 = "value1"
  argument2 = "value2"
}
```

For a local file, you need `filename` and `content` arguments.
</details>

<details>
<summary>Hint 2: File Path</summary>

The filename should be relative to your working directory. Use:
```hcl
filename = "output/welcome.txt"
```

Terraform will create the `output` directory automatically if it doesn't exist.
</details>

<details>
<summary>Hint 3: Common Errors</summary>

- **"No configuration files"**: Make sure your file is named `main.tf` (not `main.txt`)
- **"Invalid resource type"**: Check spelling of `local_file`
- **"Missing required argument"**: Both `filename` and `content` are required
- **Syntax errors**: Make sure you have matching quotes and braces
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

**Complete `main.tf`:**

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

resource "local_file" "welcome" {
  filename = "output/welcome.txt"
  content  = "Welcome to Terraform!"
}
```

**Complete workflow:**

```bash
# Create directory and navigate to it
mkdir -p ~/terraform-practice/basics
cd ~/terraform-practice/basics

# Create the main.tf file with the configuration above

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply configuration
terraform apply
# Type 'yes' when prompted

# Verify the file was created
cat output/welcome.txt

# View state
terraform state list
terraform state show local_file.welcome

# Clean up
terraform destroy
# Type 'yes' when prompted
```

**Explanation:**

1. **terraform block**: Specifies Terraform version and required providers
2. **required_providers**: Declares the `local` provider from HashiCorp registry
3. **resource block**: Defines a `local_file` resource named `welcome`
4. **filename**: Path where the file will be created
5. **content**: Content to write to the file

The Terraform workflow is:
- **init**: Download providers and initialize working directory
- **validate**: Check configuration syntax
- **plan**: Preview what changes will be made
- **apply**: Execute the changes and create resources
- **destroy**: Remove all managed resources

</details>

## Challenge

Try extending this exercise:

1. Add a second `local_file` resource that creates a file with the current timestamp using the `timestamp()` function
2. Use `terraform fmt` to format your code to canonical style
3. Create a file in a nested directory like `output/data/info.txt`
4. Add a comment above your resource explaining what it does

## Additional Resources

- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [Local Provider Documentation](https://registry.terraform.io/providers/hashicorp/local/latest/docs)
- [Resource Blocks](https://www.terraform.io/language/resources/syntax)
- [Terraform Workflow](https://www.terraform.io/intro/core-workflow)
