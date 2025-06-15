output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "vpc_id" {
  value = data.aws_vpc.existing.id
}

output "public_subnet_ids" {
  value = [data.aws_subnet.public.id]
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
} 