variable "environment" {
  type    = string
  default = "demo"
}

variable "client" {
  type = string
}

variable "domain" {
  type = string
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}