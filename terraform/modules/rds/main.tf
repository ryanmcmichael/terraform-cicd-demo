module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "${var.client}-${var.environment}"

  engine            = "postgres"
  instance_class    = var.db_instance_type
  allocated_storage = var.db_storage
  multi_az          = true

  name     = var.client
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [module.postgresql_security_group.security_group_id]

  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  backup_retention_period = 30

  tags = var.tags

  # DB subnet group
  subnet_ids = var.private_subnets

  # DB parameter group
  family = "postgres14"

  # DB option group
  major_engine_version = "14"

  # Database Deletion Protection
  deletion_protection = true
}

module "postgresql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 4.0"
  name    = "${var.client}-${var.environment}-postgresql"
  vpc_id  = var.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
}
