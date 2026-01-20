# Module Input Variables

variable "files" {
  description = "Map of filename to content"
  type        = map(string)
}

variable "output_dir" {
  description = "Directory where files will be created"
  type        = string
  default     = "."
}
