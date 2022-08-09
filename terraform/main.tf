#TODO: document that branches must be dev/qa/uat/main to sync with CI/CD

provider "aws" {
  region  = "us-east-1"
  profile = "ryan-terraform"
}

terraform {
  backend "s3" {
    bucket  = "ryan-mcmichael-terraform-state"
    key     = "toptal-demo-state.tfstate"
    region  = "us-east-1"
    profile = "ryan-terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  environment = terraform.workspace
  region      = var.region
  client      = var.client
  tags        = local.tags
}

module "rds" {
  source = "./modules/rds"

  environment = terraform.workspace
  region      = var.region
  client      = var.client
  tags        = local.tags

  private_subnets = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = module.vpc.vpc_cidr

  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password

  db_instance_type = "db.t4g.micro"
  db_storage       = 5
  db_port          = "5432"
}

module "ecr" {
  source = "./modules/ecr"

  environment     = terraform.workspace
  client          = var.client
  tags            = local.tags
}

module "eks" {
  source = "./modules/eks"

  environment = terraform.workspace
  region      = var.region
  client      = var.client

  private_subnets = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  map_users       = var.map_users

  processing_node_instance_type = "t3.medium"
  processing_node_desired       = "3"
  processing_node_max           = "6"
  processing_node_min           = "1"

  aws_cli_profile = var.profile
}

module "eks_resources" {
  source = "./modules/eks_resources"

  environment = terraform.workspace
  region      = var.region
  client      = var.client

  vpc_id                  = module.vpc.vpc_id
  cluster_id              = module.eks.cluster_id
  oidc_provider_arn       = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  worker_iam_role_name    = module.eks.worker_iam_role_name
  domain                  = var.domain

  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_endpoint             = module.rds.db_endpoint
}

module "cloudfront" {
  source = "./modules/cloudfront"

  client      = var.client
  domain      = var.domain
  tags        = local.tags
  environment = var.environment
}
