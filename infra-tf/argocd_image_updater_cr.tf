resource "kubernetes_manifest" "helloapp_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "helloapp-dev"
      namespace = "argocd"
    }
    spec = {
      # 目标 ArgoCD Application
      application = {
        name      = "helloapp-dev"
        namespace = "argocd"
      }

      # 镜像源（ECR）
      images = [
        {
          name     = "helloapp"
          image    = "939503809934.dkr.ecr.ap-southeast-2.amazonaws.com/helloapp"
          strategy = "latest"
          allowTags = {
            regexp = "^sha-[0-9a-f]{7,40}$"
          }
        }
      ]

      # 写回 Git（dev 分支 + secret）
      git = {
        branch = "main:dev"
        writeBack = {
          method = "secret"
          secretRef = {
            name      = "helloapp-gitops-write-creds"
            namespace = "argocd"
          }
        }
        # 让它更新 kustomization
        target = "kustomization"
      }
    }
  }

  depends_on = [
    helm_release.argocd_image_updater,
  ]
}
