# Output Values
# Define outputs that can be queried after apply

output "greeting_file_path" {
  description = "Path to the greeting file"
  value       = local_file.greeting.filename
}

output "greeting_content" {
  description = "Content of the greeting file"
  value       = local_file.greeting.content
}

output "file_id" {
  description = "ID of the greeting file resource"
  value       = local_file.greeting.id
}

output "tags" {
  description = "Tags applied to resources"
  value       = var.tags
}

output "enabled_features" {
  description = "List of enabled features"
  value       = var.enabled_features
}

output "secret_file_path" {
  description = "Path to the secret file (sensitive)"
  value       = local_sensitive_file.secret.filename
  sensitive   = true
}
