# Simple Resource Creation Example
# This example demonstrates basic Terraform syntax and resource creation

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Create a simple local file resource
resource "local_file" "example" {
  filename = "${path.module}/output/hello.txt"
  content  = "Hello from Terraform!"
}

# Create another file with different content
resource "local_file" "timestamp" {
  filename = "${path.module}/output/timestamp.txt"
  content  = "Created at: ${timestamp()}"
}
