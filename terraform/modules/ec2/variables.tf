variable "ami" {
  description = "AMI ID for the runner (Ubuntu 20.04 recommended)"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the runner"
  type        = string
  default     = "t3.small"
}

variable "subnet_id" {
  description = "Subnet ID for the runner EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the runner EC2 instance"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token to register the runner"
  type        = string
  sensitive   = true
}

variable "runner_ami" {
  type = string
  default = "ami-053b0d53c279acc00"
}

variable "runner_instance_type" {
  type    = string
  default = "t3.small"
} 