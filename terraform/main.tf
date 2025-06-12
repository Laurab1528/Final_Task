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

# VPC EKS
module "vpc" {
  source      = "./modules/vpc"
  kms_key_arn = module.eks.kms_key_arn
}

# EKS Cluster
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  api_key            = var.api_key
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
# --- TEMPORARY: Only create backend resources (S3 and DynamoDB) in the first apply ---
# Comment out all other resources below this line for the initial apply
# KMS key for backend encryption (S3 and DynamoDB)
# resource "aws_kms_key" "tf_backend" {
#   description             = "KMS key for Terraform backend (S3 and DynamoDB)"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true
# }

# S3 bucket for Terraform state
# resource "aws_s3_bucket" "terraform_state" { ... }
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" { ... }
# resource "aws_s3_bucket_public_access_block" "terraform_state" { ... }
# resource "aws_s3_bucket_logging" "terraform_state" { ... }
# resource "aws_s3_bucket_versioning" "terraform_state_versioning" { ... }

# DynamoDB table for state locking
# resource "aws_dynamodb_table" "terraform_locks" { ... }

# S3 bucket for logs
# resource "aws_s3_bucket" "logs" { ... }
# resource "aws_s3_bucket_server_side_encryption_configuration" "logs" { ... }
# resource "aws_s3_bucket_public_access_block" "logs" { ... }
# resource "aws_s3_bucket_versioning" "logs" { ... }
# resource "aws_s3_bucket_logging" "logs" { ... }

# Logging for the state bucket
# resource "aws_s3_bucket_logging" "terraform_state" { ... }
# Versioning for the state bucket
# resource "aws_s3_bucket_versioning" "terraform_state_versioning" { ... }
# DynamoDB table for state locking
# resource "aws_dynamodb_table" "terraform_locks" { ... } 