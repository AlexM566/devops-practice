# Module Input Variables

variable "filename" {
  description = "Name of the file to create"
  type        = string
}

variable "content" {
  description = "Content of the file"
  type        = string
}

variable "output_dir" {
  description = "Directory where the file will be created"
  type        = string
  default     = "."
}
