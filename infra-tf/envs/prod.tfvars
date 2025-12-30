workspace: dev
tfvars:
  name_prefix: helloapp-dev
  vpc_cidr: 10.10.0.0/16
  public_subnet_cidrs:
    - 10.10.1.0/24
    - 10.10.2.0/24
  az_count: 2
