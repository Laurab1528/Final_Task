provider "aws" {
  region = var.aws_region
}

# Variables pueden ser proporcionadas por:
# 1. Variables de entorno: export TF_VAR_aws_access_key_id="tu_access_key"
# 2. Archivo terraform.tfvars (NO lo subas a git)
# 3. Línea de comandos: terraform apply -var="aws_access_key_id=tu_access_key" 