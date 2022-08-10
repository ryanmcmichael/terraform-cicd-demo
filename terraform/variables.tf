variable "environment" {
  type    = string
  default = "<YOUR_ENVIRONMENT_HERE>"
}

variable "region" {
  default = "<YOUR_REGION_HERE>"
  type    = string
}

variable "client" {
  default = "<YOUR_CLIENT_HERE>"
  type    = string
}

variable "aws_account_id" {
  default = "<YOUR_AWS_ACCOUNT_ID_HERE>"
  type    = string
}

variable "domain" {
  default = "<YOUR_DOMAIN_HERE>"
  type    = string
}

variable "profile" {
  default = "<YOUR_AWS_CLI_PROFILE_HERE>"
  type    = string
}

variable "db_username" {
  default = "<YOUR_USERNAME_HERE>"
  type    = string
}

variable "db_name" {
  default = "<YOUR_CLIENT_HERE>"
  type    = string
}

# Note: you should probably put these in SSM
variable "db_password" {
  default = "<YOUR_PW_HERE>"
  type    = string
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      #TODO: THIS USER MUST BE CREATED BEFORE RUNNING
      userarn  = "<SAMPLE_USER_ARN>"
      username = "<SAMPLE_USER_NAME>"
      groups   = ["system:masters"]
    },
  ]
}
