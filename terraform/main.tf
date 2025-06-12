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
resource "aws_kms_key" "tf_backend" {
  description             = "KMS key for Terraform backend (S3 and DynamoDB)"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.project_name}-terraform-state"
  force_destroy = true
  tags = {
    Name = "Terraform State Bucket"
  }
}

# Server-side encryption for the state bucket with custom KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tf_backend.arn
    }
  }
}

# Block public access for the state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for logs
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.project_name}-logs"
  force_destroy = true
  tags = {
    Name = "Terraform Logs Bucket"
  }
}

# Server-side encryption for the logs bucket with custom KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tf_backend.arn
    }
  }
}

# Block public access for the logs bucket
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning for the logs bucket
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# (Optional) Logging for the logs bucket (can use itself as target)
# resource "aws_s3_bucket_logging" "logs" {
#   bucket        = aws_s3_bucket.logs.id
#   target_bucket = aws_s3_bucket.logs.id
#   target_prefix = "log/"
# }

# Logging for the state bucket
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}

# Versioning for the state bucket
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  # Server-side encryption with custom KMS
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tf_backend.arn
  }
  # Point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }
  tags = {
    Name = "Terraform State Lock Table"
  }
}

resource "aws_s3_bucket_logging" "logs" {
  bucket        = aws_s3_bucket.logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
} 