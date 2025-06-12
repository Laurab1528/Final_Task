#!/bin/bash

# Crear bucket S3 si no existe
if ! aws s3api head-bucket --bucket epam-final-terraform-state 2>/dev/null; then
  aws s3api create-bucket --bucket epam-final-terraform-state --region us-east-1
  aws s3api put-bucket-versioning --bucket epam-final-terraform-state --versioning-configuration Status=Enabled
fi

# Crear tabla DynamoDB si no existe
if ! aws dynamodb describe-table --table-name epam-final-terraform-locks --region us-east-1 2>/dev/null; then
  aws dynamodb create-table \
    --table-name epam-final-terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
fi 