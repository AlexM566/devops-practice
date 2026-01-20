# Input Variables
# Define variables that can be passed to the configuration

variable "name" {
  description = "Name to include in the greeting"
  type        = string
  default     = "DevOps Engineer"
}

variable "greeting_message" {
  description = "Greeting message to use"
  type        = string
  default     = "Hello"
}

variable "filename" {
  description = "Name of the output file"
  type        = string
  default     = "greeting.txt"
}

variable "secret_value" {
  description = "A secret value (sensitive)"
  type        = string
  sensitive   = true
  default     = "my-secret-123"
}

variable "tags" {
  description = "Map of tags to apply"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-example"
  }
}

variable "enabled_features" {
  description = "List of enabled features"
  type        = list(string)
  default     = ["feature-a", "feature-b"]
}
