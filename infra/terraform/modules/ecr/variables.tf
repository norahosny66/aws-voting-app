variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "repositories" {
  description = "List of repository names to create"
  type        = list(string)
}
