variable "name_prefix" {
  type        = string
  description = "Prefix used for naming AWS resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets (first N used)"
}

variable "az_count" {
  type        = number
  description = "How many availability zones to use (default 2)"
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "az_count must be at least 2 (ALB requires 2 AZs)."
  }
}
