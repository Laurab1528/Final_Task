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

# Runner module to be used with private EKS endpoint
module "runner" {
  source                = "./modules/ec2"
  ami                   = var.runner_ami
  runner_instance_type  = var.runner_instance_type
  subnet_id             = "subnet-0d623f0efa8a6150b"
  security_group_id     = aws_security_group.runner.id
  github_pat            = var.github_pat
}

# Runner security group
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

  tags = {
    Name = "runner-sg"
  }
}

# Security group rule to allow runner to access EKS
resource "aws_security_group_rule" "eks_from_runner" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.runner.id
  security_group_id        = module.eks.node_security_group_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

module "ec2" {
  source               = "./modules/ec2"
  ami                  = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  runner_instance_type = "t2.medium"
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_id    = module.eks.node_security_group_id
  github_pat           = var.github_pat
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(
      [
        {
          groups   = ["system:bootstrappers", "system:nodes"]
          rolearn  = module.eks.eks_node_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
        }
      ]
    )
  }
}