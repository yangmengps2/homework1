resource "kubernetes_manifest" "helloapp_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "helloapp-dev"
      namespace = "argocd"
    }

    spec = {
      # 在哪里找 Applications（通常就是 argocd）
      namespace = "argocd"

      # 全局默认设置
      commonUpdateSettings = {
        updateStrategy  = "latest"
        allowTags       = "regexp:^sha-[0-9a-f]{7,40}$"
        writeBackMethod = "git:secret:argocd/helloapp-gitops-write-creds"
        gitBranch       = "main:dev"
        writeBackTarget = "kustomization"
      }

      # 选择要管理的 Application
      applicationRefs = [
        {
          # 最简单：按名字精确匹配
          name = "helloapp-dev"
        }
      ]
    }
  }

  depends_on = [
    helm_release.argocd_image_updater
  ]
}
