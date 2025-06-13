variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "api_key" {
  description = "API Key for the FastAPI application"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming (used in S3 bucket and DynamoDB table)"
  type        = string
  default     = "epam-final"
}

variable "runner_ami" {
  description = "AMI ID for the runner (Ubuntu 20.04 recommended)"
  type        = string
  default     = "ami-053b0d53c279acc00"
}

variable "runner_instance_type" {
  description = "Instance type for the runner"
  type        = string
  default     = "t3.small"
}

variable "github_pat" {
  description = "GitHub Personal Access Token to register the runner"
  type        = string
  sensitive   = true
} 