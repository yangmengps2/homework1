variable "name_prefix" {
  type        = string
  description = "Prefix used for naming AWS resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ALB"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB"
}

variable "target_port" {
  type        = number
  description = "Target group port (container port)"
}

variable "health_check_path" {
  type        = string
  description = "Target group health check path"
}