data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    kubernetes = {
      source = "registry.terraform.io/hashicorp/kubernetes"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    time = {
      source = "hashicorp/time"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

resource "kubernetes_namespace" "sla" {
  provider   = kubernetes
  depends_on = [data.aws_eks_cluster_auth.cluster]
  metadata {
    name = var.client
  }
}

resource "helm_release" "cloudwatch_logs" {
  depends_on = [kubernetes_namespace.sla]
  name       = "${var.environment}-cloudwatch-logs"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = kubernetes_namespace.sla.metadata.0.name
  timeout    = 600
}

/*module "cloudwatch_logs" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-cloudwatch-logs.git"

  enabled = true

  cluster_name                     = data.aws_eks_cluster.cluster.name
  cluster_identity_oidc_issuer     = var.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.oidc_provider_arn
  worker_iam_role_name             = var.worker_iam_role_name
  region                           = var.region
}

#TODO: make this operational
module "kubernetes_dashboard" {
  source = "git::https://github.com/lablabs/terraform-aws-eks-kubernetes-dashboard.git"

  settings = {}
}*/
