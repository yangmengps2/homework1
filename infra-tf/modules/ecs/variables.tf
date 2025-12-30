variable "name_prefix" {
  type        = string
  description = "Prefix used for naming AWS resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region (for log config)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs used by the ECS service"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "container_image" {
  type        = string
  description = "Container image URI"
}

variable "container_port" {
  type        = number
  description = "Container port"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID (allowed ingress source)"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ECS execution role ARN"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "autoscaling_role_arn" {
  type        = string
  description = "Application Auto Scaling role ARN"
}

variable "desired_count" {
  type        = number
  description = "Desired task count"
  default     = 1
}