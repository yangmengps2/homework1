locals {
  image_updater_namespace = "argocd"
  image_updater_sa_name   = "argocd-image-updater"

  ecr_account_id = "939503809934"
  ecr_region     = "ap-southeast-2"
  ecr_registry   = "${local.ecr_account_id}.dkr.ecr.${local.ecr_region}.amazonaws.com"
}

########################################
# IAM Policy (ECR Read-only)
########################################
resource "aws_iam_policy" "argocd_image_updater_ecr" {
  name = "${module.eks.cluster_name}-argocd-image-updater-ecr-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRRead"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "*"
      }
    ]
  })
}

########################################
# IRSA AssumeRole policy doc (same pattern as your LBC)
########################################
data "aws_iam_policy_document" "argocd_image_updater_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.image_updater_namespace}:${local.image_updater_sa_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "argocd_image_updater" {
  name               = "${module.eks.cluster_name}-argocd-image-updater"
  assume_role_policy = data.aws_iam_policy_document.argocd_image_updater_assume_role.json
}

resource "aws_iam_role_policy_attachment" "argocd_image_updater" {
  role       = aws_iam_role.argocd_image_updater.name
  policy_arn = aws_iam_policy.argocd_image_updater_ecr.arn
}

########################################
# Kubernetes ServiceAccount with role-arn annotation
########################################
resource "kubernetes_service_account" "argocd_image_updater" {
  metadata {
    name      = local.image_updater_sa_name
    namespace = local.image_updater_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.argocd_image_updater.arn
    }
  }
}

########################################
# (Optional but recommended) RBAC for Applications
########################################
resource "kubernetes_cluster_role" "argocd_image_updater" {
  metadata { name = "argocd-image-updater" }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["applications"]
    verbs      = ["get", "list", "watch", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "argocd_image_updater" {
  metadata { name = "argocd-image-updater" }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_image_updater.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.argocd_image_updater.metadata[0].name
    namespace = local.image_updater_namespace
  }
}

########################################
# Helm install: argocd-image-updater
########################################
resource "helm_release" "argocd_image_updater" {
  name       = "argocd-image-updater"
  namespace  = local.image_updater_namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"

  # 使用我们自己创建的 SA（带 IRSA 注解）
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "rbac.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.argocd_image_updater.metadata[0].name
  }

  # 关键：ECR registry + auth script（script 输出 "user:pass"）
  values = [
    yamlencode({
      config = {
        registries = [
          {
            name        = "ecr"
            api_url     = "https://${local.ecr_registry}"
            prefix      = local.ecr_registry
            credentials = "ext:/scripts/ecr-login.sh"
          }
        ]
      }

      authScripts = {
        enabled = true
        scripts = {
          "ecr-login.sh" = <<-EOT
            #!/bin/sh
            aws ecr --region "${local.ecr_region}" get-authorization-token \
              --output text --query 'authorizationData[].authorizationToken' | base64 -d
          EOT
        }
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.argocd_image_updater,
    kubernetes_service_account.argocd_image_updater,
    kubernetes_cluster_role_binding.argocd_image_updater
  ]
}
