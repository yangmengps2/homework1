resource "kubernetes_manifest" "argocd_app_helloapp_dev" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "helloapp-dev"
      namespace = "argocd"

      # 这些注解先放着：等我们装 image-updater 后就会生效
      annotations = {
        "argocd-image-updater.argoproj.io/image-list"                 = "helloapp=939503809934.dkr.ecr.ap-southeast-2.amazonaws.com/helloapp"
        "argocd-image-updater.argoproj.io/helloapp.update-strategy"   = "latest"
        "argocd-image-updater.argoproj.io/helloapp.allow-tags"        = "regexp:^sha-[0-9a-f]{7}$"
        "argocd-image-updater.argoproj.io/write-back-method"          = "git"
        "argocd-image-updater.argoproj.io/write-back-target"          = "kustomization"
        "argocd-image-updater.argoproj.io/git-branch"                 = "main"
      }
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/yangmengps2/helloapp-gitops.git"
        targetRevision = "main"
        path           = "apps/helloapp/overlays/dev"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "helloapp-dev"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }

  depends_on = [helm_release.argocd]
}
