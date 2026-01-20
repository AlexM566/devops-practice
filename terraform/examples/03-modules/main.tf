# Module Structure Example
# This example demonstrates how to create and use Terraform modules

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Use the file-creator module to create multiple files
module "app_config" {
  source = "./modules/file-creator"

  filename = "app-config.json"
  content  = jsonencode({
    app_name    = "my-app"
    environment = "production"
    port        = 8080
  })
  output_dir = "${path.module}/output"
}

module "database_config" {
  source = "./modules/file-creator"

  filename = "db-config.json"
  content  = jsonencode({
    host     = "localhost"
    port     = 5432
    database = "mydb"
    username = "admin"
  })
  output_dir = "${path.module}/output"
}

# Use the multi-file module to create multiple files at once
module "documentation" {
  source = "./modules/multi-file"

  files = {
    "README.md" = "# My Application\n\nThis is a sample application."
    "INSTALL.md" = "# Installation\n\nRun: npm install"
    "LICENSE.md" = "# License\n\nMIT License"
  }
  output_dir = "${path.module}/output/docs"
}
