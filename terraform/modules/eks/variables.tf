variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de subredes privadas"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Lista de IDs de subredes públicas"
  type        = list(string)
} 