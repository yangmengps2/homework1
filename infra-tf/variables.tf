variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming AWS resources"
  default     = "helloapp"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "ecs_cluster_name" {
  type    = string
  default = "app"
}

variable "container_image" {
  type        = string
  description = "ECR image URI"
  default     = "939503809934.dkr.ecr.ap-southeast-2.amazonaws.com/helloapp:latest"
}

variable "container_port" {
  type    = number
  default = 5000
}

variable "health_check_path" {
  type        = string
  description = "ALB target group health check path"
  default     = "/hello"
}

variable "desired_count" {
  type        = number
  description = "ECS service desired count"
  default     = 1
}
