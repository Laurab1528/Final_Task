terraform {
  backend "s3" {
    bucket         = "epam-final-terraform-state"
    key            = "global/sandbox/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "epam-final-terraform-locks"
    encrypt        = true
  }
} 