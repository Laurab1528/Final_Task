variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "runner_ami" {
  description = "AMI for the GitHub Actions runner"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS
}

variable "runner_instance_type" {
  description = "Instance type for the GitHub Actions runner"
  type        = string
  default     = "t2.micro"
}

variable "github_pat" {
  description = "GitHub Personal Access Token for runner registration"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key for the application"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name for resource naming (used in S3 bucket and DynamoDB table)"
  type        = string
  default     = "epam-final"
} 