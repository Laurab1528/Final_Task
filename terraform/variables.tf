variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "api_key" {
  description = "API Key para la aplicación FastAPI"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming (used in S3 bucket and DynamoDB table)"
  type        = string
  default     = "epam-final"
} 