provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Variables can be provided through:
# 1. Environment variables: export TF_VAR_aws_access_key_id="your_access_key"
# 2. terraform.tfvars file (DO NOT commit to git)
# 3. Command line: terraform apply -var="aws_access_key_id=your_access_key" 