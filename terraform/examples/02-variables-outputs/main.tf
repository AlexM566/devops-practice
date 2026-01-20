# Variables and Outputs Example
# This example demonstrates how to use input variables and output values

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Create a file using variables
resource "local_file" "greeting" {
  filename = "${path.module}/output/${var.filename}"
  content  = "${var.greeting_message} ${var.name}!"
}

# Create a file with sensitive content
resource "local_sensitive_file" "secret" {
  filename = "${path.module}/output/secret.txt"
  content  = "Secret value: ${var.secret_value}"
}
