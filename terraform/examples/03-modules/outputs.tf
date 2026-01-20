# Outputs from modules

output "app_config_path" {
  description = "Path to the app configuration file"
  value       = module.app_config.file_path
}

output "database_config_path" {
  description = "Path to the database configuration file"
  value       = module.database_config.file_path
}

output "documentation_files" {
  description = "List of documentation files created"
  value       = module.documentation.file_paths
}
