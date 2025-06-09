output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "oidc_provider_arn" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer_arn
}

output "oidc_provider_url" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "fastapi_sa_role_arn" {
  value = aws_iam_role.fastapi_sa.arn
} 