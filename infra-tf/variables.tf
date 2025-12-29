variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
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
