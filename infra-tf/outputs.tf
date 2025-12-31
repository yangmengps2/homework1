output "alb_dns_name" {
  value = try(module.alb[0].alb_dns_name, null)
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "ecs_cluster_name" {
  value = try(module.ecs[0].ecs_cluster_name, null)
}

output "eks_cluster_ca" {
  value = module.eks.cluster_ca
}
