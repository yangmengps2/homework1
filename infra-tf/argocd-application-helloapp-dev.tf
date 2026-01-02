resource "kubernetes_manifest" "argocd_app_helloapp_dev" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "helloapp-dev"
      namespace = "argocd"

      # 这些注解先放着：等我们装 image-updater 后就会生效
      annotations = {
        "argocd-image-updater.argoproj.io/image-list"               = "helloapp=939503809934.dkr.ecr.ap-southeast-2.amazonaws.com/helloapp"
        "argocd-image-updater.argoproj.io/helloapp.update-strategy" = "latest"

        # 放宽到 7~40 位，避免以后 tag 变长就匹配不到
        "argocd-image-updater.argoproj.io/helloapp.allow-tags"      = "regexp:^sha-[0-9a-f]{7,40}$"

        # 关键：让 updater 基于 main 写到 dev 分支
        "argocd-image-updater.argoproj.io/git-branch"               = "main:dev"

        # 关键：用 secret 的 git 写权限（你后面会创建这个 secret）
        "argocd-image-updater.argoproj.io/write-back-method"        = "git:secret:argocd/helloapp-gitops-write-creds"

        "argocd-image-updater.argoproj.io/write-back-target"        = "kustomization"
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
