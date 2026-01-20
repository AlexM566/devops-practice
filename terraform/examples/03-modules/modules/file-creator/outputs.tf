# Module Outputs

output "file_path" {
  description = "Full path to the created file"
  value       = local_file.this.filename
}

output "file_id" {
  description = "ID of the file resource"
  value       = local_file.this.id
}

output "content_length" {
  description = "Length of the file content"
  value       = length(var.content)
}
