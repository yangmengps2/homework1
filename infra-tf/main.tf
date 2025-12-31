module "network" {
  source = "./modules/network"

  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr

  public_subnet_cidrs = var.public_subnet_cidrs
}

module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
}

module "alb" {
  source = "./modules/alb"

  name_prefix       = var.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  target_port       = var.container_port
  health_check_path = var.health_check_path
}

module "ecs" {
  source = "./modules/ecs"

  depends_on = [module.alb]

  name_prefix       = var.name_prefix
  aws_region        = var.aws_region
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  ecs_cluster_name = var.ecs_cluster_name
  container_image  = var.container_image
  container_port   = var.container_port

  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  autoscaling_role_arn   = module.iam.autoscaling_role_arn

  desired_count = var.desired_count
}

module "eks" {
  source = "./modules/eks"

  name_prefix       = var.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  # 你也可以不传，用默认 helloapp-dev
  cluster_name = "helloapp-dev"
}
