variable "cluster_name" {
  type    = string
  default = "helloapp-dev"
}

variable "eks_version" {
  type    = string
  default = "1.29" # 你也可以后面再调
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "name_prefix" {
  type = string
}
