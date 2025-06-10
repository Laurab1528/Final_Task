provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

# VPC para EKS
module "vpc" {
  source = "./modules/vpc"
}

# EKS Cluster
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

resource "helm_release" "fastapi_app" {
  name             = "fastapi-app"
  chart            = "../helm/fastapi-app"
  values           = [file("../helm/fastapi-app/values-prod.yaml")]
  namespace        = "production"
  create_namespace = true
} 