# State Management Example
# This example demonstrates Terraform state concepts and backends

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Local backend configuration (default)
  # State is stored in terraform.tfstate file
  backend "local" {
    path = "terraform.tfstate"
  }

  # Example of remote backend (commented out)
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "state-management-example/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Create resources to demonstrate state management
resource "local_file" "state_example" {
  filename = "${path.module}/output/state-demo.txt"
  content  = <<-EOT
    This file demonstrates Terraform state management.
    
    State File: Contains the current state of infrastructure
    State Locking: Prevents concurrent modifications
    Remote State: Enables team collaboration
    
    Resource ID: ${random_id.example.hex}
  EOT
}

# Use random provider to show state persistence
resource "random_id" "example" {
  byte_length = 8
}

# Data source to read from state
data "local_file" "read_state_file" {
  filename = local_file.state_example.filename

  depends_on = [local_file.state_example]
}

# Resource with lifecycle rules
resource "local_file" "lifecycle_example" {
  filename = "${path.module}/output/lifecycle.txt"
  content  = "This file demonstrates lifecycle rules"

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false

    # Create new resource before destroying old one
    create_before_destroy = true

    # Ignore changes to specific attributes
    ignore_changes = [
      # content
    ]
  }
}
