variable "environment" {
  type    = string
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

variable "db_instance_type" {
  type = string
}

variable "db_storage" {
  type = string
}

variable "db_port" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "client" {
  type = string
}

variable "private_subnets" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
