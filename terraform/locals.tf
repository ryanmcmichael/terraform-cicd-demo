locals {
  #TODO: put tags on all eks resources
  tags = {
    Environment  = var.environment
    Organization = var.client
    Terraform    = "true"
  }
}