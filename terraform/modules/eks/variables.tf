variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "private_subnets" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "client" {
  type = string
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "processing_node_max" {
  type = string
}

variable "processing_node_min" {
  type = string
}

variable "processing_node_desired" {
  type = string
}

variable "processing_node_instance_type" {
  type = string
}

variable "aws_cli_profile" {
  type = string
}
