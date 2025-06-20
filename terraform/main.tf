# VPC EKS
module "vpc" {
  source = "./modules/vpc"
}

# EKS Cluster
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  api_key            = var.api_key
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Runner Security Group
resource "aws_security_group" "runner_sg" {
  name        = "runner-sg"
  description = "Security group for GitHub Actions runner"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "runner-sg"
  }
}

# Rule to allow Runner to access EKS API
resource "aws_security_group_rule" "runner_to_eks" {
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.runner_sg.id
  security_group_id         = module.eks.node_security_group_id
}

# Self-hosted Runner EC2 Instance
module "ec2" {
  source               = "./modules/ec2"
  runner_instance_type = "t2.medium"
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_id    = aws_security_group.runner_sg.id
  github_pat           = var.github_pat
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = yamlencode([
      {
        rolearn  = module.eks.eks_node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "arn:aws:iam::579177902857:role/actions"
        username = "cicd-role"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks]
}