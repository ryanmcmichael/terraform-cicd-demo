locals {
  cluster_name = "${var.client}-${var.environment}"
  tags = merge(tomap({
    resource_type = "instance" }),
    var.tags,
  )
}

data "aws_caller_identity" "current" {}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.20.4"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id

  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  manage_aws_auth_configmap       = true
  enable_irsa                     = true

  aws_auth_users = var.map_users

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 100
    desired_size   = 3
    name_prefix    = "${var.client}-${var.environment}-"

    #vpc_security_group_ids  = [var.ttsd_security_group_id]

    #TODO: revisit permissions
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
      "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ]
  }

  eks_managed_node_groups = {
    processing = {
      max_size         = var.processing_node_max
      min_size         = var.processing_node_min
      desired_size     = var.processing_node_desired

      instance_types   = [var.processing_node_instance_type]

      labels = {
        "hazelcast"         = "true"
        "kafka"             = "true"
        "reference_manager" = "false"
        "content_manager"   = "true"
        "router"            = "true"
        "batcher"           = "true"
        "accumulator"       = "true"
        "fpga"              = "false"
      }

      #enable_bootstrap_user_data = true
      bootstrap_extra_args       = <<-EOT
[settings.kubernetes.node-labels]
"fpga" = "false"
EOT
    }
  }

  tags = var.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true # NOTE: This was what needed to be added

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  #config_path = "~/.kube/config"
}

#TODO: only create locally
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "AWS_PROFILE=${var.aws_cli_profile} aws eks --region ${var.region} update-kubeconfig --name $AWS_CLUSTER_NAME"
    environment = {
      AWS_CLUSTER_NAME = local.cluster_name
    }
  }
}
