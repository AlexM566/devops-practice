# Module Outputs

output "file_paths" {
  description = "Map of filename to full path"
  value       = { for k, v in local_file.files : k => v.filename }
}

output "file_count" {
  description = "Number of files created"
  value       = length(local_file.files)
}
