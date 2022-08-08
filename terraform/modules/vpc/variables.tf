variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "client" {
  type = string
}
