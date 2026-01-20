# File Creator Module
# A reusable module for creating files

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "this" {
  filename = "${var.output_dir}/${var.filename}"
  content  = var.content
}
