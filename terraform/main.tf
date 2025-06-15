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
  depends_on         = [module.runner]
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

module "runner" {
  source                = "./modules/ec2"
  ami                   = var.runner_ami
  runner_instance_type  = var.runner_instance_type
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_id     = aws_security_group.runner.id
  github_pat            = var.github_pat
}

resource "aws_security_group_rule" "eks_from_runner" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.runner.id
  security_group_id        = module.eks.node_security_group_id
}

resource "aws_security_group" "runner" {
  name        = "runner-sg"
  description = "Security group for GitHub Actions runner"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No ingress rules: no SSH access

  tags = {
    Name = "runner-sg"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  provider = kubernetes.eks
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode([
      {
        rolearn  = "arn:aws:iam::579177902857:role/eks-node-role"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn  = "arn:aws:iam::579177902857:role/eks-cluster-role"
        username = "eks-cluster-role"
        groups   = [
          "system:masters"
        ]
      },
      {
        rolearn  = "arn:aws:iam::579177902857:role/actions"
        username = "actions"
        groups   = [
          "system:masters"
        ]
      }
    ])
  }
  depends_on = [module.eks, module.eks]
}