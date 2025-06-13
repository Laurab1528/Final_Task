variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB and other resources"
  type        = list(string)
}

variable "api_key" {
  description = "API Key for the FastAPI application"
  type        = string
} 