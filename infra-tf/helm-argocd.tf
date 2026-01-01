resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  # 建议后面固定版本，避免未来 plan 漂移
  # version  = "6.x.x"

  # 先最小化：不暴露公网（ClusterIP）
  values = [yamlencode({
    server = {
      service = {
        type = "ClusterIP"
      }
    }
  })]

  wait    = true
  timeout = 600

  # 确保 EKS/节点组先就绪（保险写法）
  depends_on = [module.eks]
}
