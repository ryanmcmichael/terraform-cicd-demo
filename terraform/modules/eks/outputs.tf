output "cluster_id" {
  description = "Cluster ID"
  value       = module.eks.cluster_id
}

output "oidc_provider_arn" {
  description = "OIDC ARN"
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "OIDC URL"
  value       = module.eks.cluster_oidc_issuer_url
}

output "worker_iam_role_name" {
  description = "Worker IAM role name"
  value       = module.eks.cluster_iam_role_name
}
