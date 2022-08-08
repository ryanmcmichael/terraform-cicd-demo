output "private_subnets" {
  description = "VPC Private Subnets"
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.default_vpc_cidr_block
}
