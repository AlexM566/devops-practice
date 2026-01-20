# Multi-File Module
# A module for creating multiple files from a map

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "files" {
  for_each = var.files

  filename = "${var.output_dir}/${each.key}"
  content  = each.value
}
