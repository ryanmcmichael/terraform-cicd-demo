variable "environment" {
  type    = string
  default = "demo"
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "client" {
  default = "toptal"
  type    = string
}

variable "domain" {
  default = "ryanmcmichael-demo.com"
  type    = string
}

variable "profile" {
  default = "ryan-terraform"
  type    = string
}

variable "db_username" {
  default = "toptal"
  type    = string
}

variable "db_name" {
  default = "toptal"
  type    = string
}

variable "db_password" {
  default = "supersecret"
  type    = string
}

variable "efs_subnet_ids" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
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
      userarn  = "arn:aws:iam::803410019076:user/wex.github.actions"
      username = "terraform"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::803410019076:user/ryan.mcmichael"
      username = "ryan.mcmichael"
      groups   = ["system:masters"]
    },
  ]
}
