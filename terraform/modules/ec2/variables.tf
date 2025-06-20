variable "ami" {
  description = "AMI for the runner instance"
  type        = string
}

variable "runner_instance_type" {
  description = "Instance type for the runner"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the runner instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the runner instance"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for runner registration"
  type        = string
  sensitive   = true
} 