# Terraform Examples

This directory contains practical Terraform examples to help you learn Infrastructure as Code (IaC) concepts. Each example builds on the previous one, introducing new concepts progressively.

## Prerequisites

- Terraform CLI installed (version >= 1.0)
- Basic understanding of command line
- Text editor for viewing/editing `.tf` files

## Quick Start

```bash
# Navigate to any example directory
cd 01-simple-resource

# Initialize Terraform (downloads providers)
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Clean up resources
terraform destroy
```

## Examples Overview

### 1. Simple Resource Creation (`01-simple-resource/`)

**Concepts:** Basic Terraform syntax, resource blocks, providers

**What you'll learn:**
- How to define a Terraform configuration
- How to create resources using the `resource` block
- Basic Terraform workflow: init, plan, apply, destroy
- Using built-in functions like `timestamp()`

**Files:**
- `main.tf` - Main configuration with resource definitions

**Try it:**
```bash
cd 01-simple-resource
terraform init
terraform plan
terraform apply
# Check the output/ directory for created files
terraform destroy
```

---

### 2. Variables and Outputs (`02-variables-outputs/`)

**Concepts:** Input variables, output values, variable types, sensitive data

**What you'll learn:**
- How to define input variables with different types (string, map, list)
- How to set default values for variables
- How to mark variables as sensitive
- How to define output values to display after apply
- How to use variables in resource configurations
- How to pass variables via command line or `.tfvars` files

**Files:**
- `main.tf` - Resource definitions using variables
- `variables.tf` - Input variable declarations
- `outputs.tf` - Output value definitions
- `terraform.tfvars.example` - Example variable values

**Try it:**
```bash
cd 02-variables-outputs
terraform init

# Use default values
terraform apply

# Override variables via command line
terraform apply -var="name=Alice" -var="greeting_message=Hi"

# Use a tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform apply

# View outputs
terraform output
terraform output greeting_content

# Clean up
terraform destroy
```

---

### 3. Module Structure (`03-modules/`)

**Concepts:** Modules, code reusability, module composition, DRY principle

**What you'll learn:**
- How to create reusable Terraform modules
- How to define module inputs (variables) and outputs
- How to call modules from root configuration
- How to organize code for maintainability
- Module best practices

**Structure:**
```
03-modules/
├── main.tf              # Root module calling child modules
├── outputs.tf           # Root module outputs
└── modules/
    ├── file-creator/    # Simple module for creating a file
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── multi-file/      # Module for creating multiple files
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Try it:**
```bash
cd 03-modules
terraform init
terraform plan
terraform apply

# Check the output/ directory for files created by modules
ls -la output/
ls -la output/docs/

# View module outputs
terraform output

# Clean up
terraform destroy
```

---

### 4. State Management (`04-state-management/`)

**Concepts:** Terraform state, state backends, state locking, lifecycle rules

**What you'll learn:**
- What Terraform state is and why it's important
- How state tracks real-world resources
- Local vs remote state backends
- State file structure and contents
- Useful state commands
- Resource lifecycle management
- State locking and team collaboration

**Files:**
- `main.tf` - Configuration with state backend and lifecycle rules
- `providers.tf` - Provider requirements
- `outputs.tf` - Outputs including state commands reference

**Try it:**
```bash
cd 04-state-management
terraform init
terraform apply

# Explore state commands
terraform state list                    # List all resources in state
terraform state show local_file.state_example  # Show resource details
terraform state pull                    # View raw state JSON

# View the state file
cat terraform.tfstate

# Refresh state from real infrastructure
terraform refresh

# View outputs with state commands
terraform output state_commands

# Clean up
terraform destroy
```

**Important State Concepts:**

1. **State File (`terraform.tfstate`):**
   - JSON file tracking resource mappings
   - Contains sensitive data - never commit to version control
   - Used to determine what changes to make

2. **State Backends:**
   - Local: State stored in local file (default)
   - Remote: State stored in S3, Azure Blob, Terraform Cloud, etc.
   - Remote backends enable team collaboration and state locking

3. **State Locking:**
   - Prevents concurrent modifications
   - Automatically handled by remote backends
   - Protects against corruption

4. **State Commands:**
   - `terraform state list` - List resources
   - `terraform state show <resource>` - Show resource details
   - `terraform state mv` - Rename resources
   - `terraform state rm` - Remove from state (doesn't destroy)
   - `terraform state pull` - Download remote state
   - `terraform state push` - Upload state (dangerous!)

---

## Common Terraform Commands

```bash
# Initialize working directory (download providers)
terraform init

# Validate configuration syntax
terraform validate

# Format code to canonical style
terraform fmt

# Preview changes without applying
terraform plan

# Apply changes to create/update infrastructure
terraform apply

# Apply without interactive approval
terraform apply -auto-approve

# Destroy all resources
terraform destroy

# Show current state
terraform show

# List resources in state
terraform state list

# View outputs
terraform output

# Refresh state from real infrastructure
terraform refresh

# Create execution plan and save it
terraform plan -out=tfplan

# Apply saved plan
terraform apply tfplan
```

## Best Practices

1. **Version Control:**
   - Commit `.tf` files to git
   - Add `terraform.tfstate*` to `.gitignore`
   - Add `.terraform/` to `.gitignore`
   - Add `*.tfvars` to `.gitignore` (contains secrets)

2. **State Management:**
   - Use remote state for team collaboration
   - Enable state locking
   - Never edit state files manually
   - Back up state files regularly

3. **Code Organization:**
   - Use modules for reusable components
   - Keep configurations DRY (Don't Repeat Yourself)
   - Use meaningful resource names
   - Add comments for complex logic

4. **Variables:**
   - Use variables for values that change between environments
   - Set sensible defaults
   - Mark sensitive variables appropriately
   - Document variables with descriptions

5. **Security:**
   - Never commit secrets to version control
   - Use environment variables or secret management tools
   - Mark sensitive outputs appropriately
   - Review plans before applying

## Terraform Workflow

```
┌─────────────┐
│   Write     │  Write .tf configuration files
│   Config    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Initialize working directory
│    init     │  Download providers and modules
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Validate syntax and configuration
│  validate   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Preview changes
│    plan     │  See what will be created/modified/destroyed
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Apply changes
│   apply     │  Create/update infrastructure
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Destroy infrastructure when done
│  destroy    │
└─────────────┘
```

## File Structure Conventions

```
terraform-project/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output value definitions
├── providers.tf      # Provider configurations
├── versions.tf       # Terraform and provider version constraints
├── terraform.tfvars  # Variable values (gitignored)
├── .gitignore        # Ignore state files and .terraform/
└── modules/          # Reusable modules
    └── my-module/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Next Steps

1. Complete each example in order
2. Experiment by modifying the configurations
3. Try creating your own resources and modules
4. Explore the [Terraform Registry](https://registry.terraform.io/) for providers and modules
5. Read the [Terraform Documentation](https://www.terraform.io/docs)

## Troubleshooting

**Error: "terraform: command not found"**
- Install Terraform CLI from https://www.terraform.io/downloads

**Error: "Error locking state"**
- Another terraform process is running
- Wait for it to complete or remove `.terraform.tfstate.lock.info`

**Error: "Provider registry.terraform.io/... not found"**
- Check internet connection
- Run `terraform init` again
- Verify provider name in configuration

**State file conflicts:**
- Never edit state files manually
- Use `terraform state` commands instead
- For team work, use remote state with locking

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
