# infra-tf/envs/dev.tfvars

# ===== 通用命名前缀（必须不同于 prod）=====
name_prefix = "helloapp-dev"

# ===== VPC 网络 =====
vpc_cidr = "10.10.0.0/16"

# ===== Public Subnets（至少 2 个，对应前 2 个 AZ）=====
public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

# ===== 可选：使用几个 AZ（默认 2，不写也行）=====
az_count = 2
