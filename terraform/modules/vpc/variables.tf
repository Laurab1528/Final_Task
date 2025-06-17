variable "kms_key_arn" {
  description = "KMS key ARN for VPC flow logs"
  type        = string
}

variable "existing_igw_id" {
  description = "ID del Internet Gateway existente"
  type        = string
  default     = "igw-0fb57ccf6200364a5"
}

variable "existing_public_route_table_id" {
  description = "ID de la Route Table pública existente"
  type        = string
  default     = "rtb-059f084fedb6b0e1e"
} 