variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}
