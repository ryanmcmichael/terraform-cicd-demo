module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${var.environment}-${var.client}"
  cidr   = "10.0.0.0/16"

  azs             = ["${var.region}d", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-${var.client}-cluster" = "shared"
    "kubernetes.io/role/elb"                                         = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}-${var.client}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                                = 1
  }

  tags = var.tags
}