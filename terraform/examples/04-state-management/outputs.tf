# Outputs for state management example

output "state_file_path" {
  description = "Path to the state demonstration file"
  value       = local_file.state_example.filename
}

output "random_id" {
  description = "Random ID generated (stored in state)"
  value       = random_id.example.hex
}

output "file_content_from_state" {
  description = "Content read from state via data source"
  value       = data.local_file.read_state_file.content
}

output "state_commands" {
  description = "Useful Terraform state commands"
  value = {
    list      = "terraform state list"
    show      = "terraform state show <resource>"
    pull      = "terraform state pull"
    push      = "terraform state push"
    mv        = "terraform state mv <source> <destination>"
    rm        = "terraform state rm <resource>"
    refresh   = "terraform refresh"
  }
}
