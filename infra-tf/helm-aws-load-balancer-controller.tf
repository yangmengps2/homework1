resource "kubernetes_service_account" "lbc" {
  metadata {
    name      = local.lbc_sa_name
    namespace = local.lbc_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lbc.arn
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = local.lbc_namespace

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [yamlencode({
    clusterName = module.eks.cluster_name
    region      = var.aws_region

    serviceAccount = {
      create = false
      name   = local.lbc_sa_name
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [
    aws_iam_role_policy_attachment.lbc,
    kubernetes_service_account.lbc
  ]
}
