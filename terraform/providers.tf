provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Variables pueden ser proporcionadas por:
# 1. Variables de entorno: export TF_VAR_aws_access_key_id="tu_access_key"
# 2. Archivo terraform.tfvars (NO lo subas a git)
# 3. Línea de comandos: terraform apply -var="aws_access_key_id=tu_access_key" 