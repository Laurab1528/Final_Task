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
# Clave KMS para cifrado de backend (S3 y DynamoDB)
resource "aws_kms_key" "tf_backend" {
  description             = "KMS key for Terraform backend (S3 and DynamoDB)"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# S3 bucket para Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.project_name}-terraform-state"
  force_destroy = true
  tags = {
    Name = "Terraform State Bucket"
  }
}

# Cifrado del bucket de state con KMS propia
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tf_backend.arn
    }
  }
}

# Bloquea el acceso público al bucket S3 de state
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket para logs del bucket de state
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-logs"
  force_destroy = true
  tags = {
    Name = "Terraform Logs Bucket"
  }
}

# Cifrado del bucket de logs con KMS propia
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tf_backend.arn
    }
  }
}

# Bloquea el acceso público al bucket de logs
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versionado del bucket de logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# (Opcional) Logging para el bucket de logs (puedes usar el mismo bucket o crear otro)
# resource "aws_s3_bucket_logging" "logs" {
#   bucket        = aws_s3_bucket.logs.id
#   target_bucket = aws_s3_bucket.logs.id
#   target_prefix = "log/"
# }

# Logging para el bucket de state
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}

# Versionado del bucket de state
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
  # Cifrado en reposo con KMS propia
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