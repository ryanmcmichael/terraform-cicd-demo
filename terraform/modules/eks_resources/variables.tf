variable "environment" {
  type    = string
  default = "demo"
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "cluster_id" {
  type = string
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "worker_iam_role_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "api_service_port" {
  type    = string
  default = "3000"
}

variable "web_service_port" {
  type    = string
  default = "3000"
}

variable "client" {
  type = string
}

variable "domain" {
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

variable "db_endpoint" {
  type    = string
}
