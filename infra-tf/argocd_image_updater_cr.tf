resource "kubernetes_manifest" "helloapp_image_updater" {
  manifest = {
    apiVersion = "argocd-image-updater.argoproj.io/v1alpha1"
    kind       = "ImageUpdater"
    metadata = {
      name      = "helloapp-dev"
      namespace = "argocd"
    }

    spec = {
      # Argo CD Application 所在 namespace
      namespace = "argocd"

      # 全局默认：怎么挑选新版本
      commonUpdateSettings = {
        updateStrategy = "latest"
        # 这里是“regex pattern”，不要写 allow-tags 的 regexp: 前缀，直接 regex 更稳
        allowTags      = "^sha-[0-9a-f]{7,40}$"
      }

      # 全局默认：怎么写回 Git（你要 PR flow，所以写 dev 分支）
      writeBackConfig = {
        method = "git:secret:argocd/helloapp-gitops-write-creds"
        gitConfig = {
          # 这里是目标分支名（建议就叫 dev）
          branch = "dev"

          # 写回目标：kustomization + 相对路径（就是你 application 的 spec.source.path）
          writeBackTarget = "kustomization:apps/helloapp/overlays/dev"

          # repository 可不填：CRD 说会从 Application.spec.source.repoURL 推断
          # repository = "https://github.com/yangmengps2/helloapp-gitops.git"
        }
      }

      # 选中要被管理的 Application，并定义要更新的镜像
      applicationRefs = [
        {
          namePattern = "helloapp-dev"

          images = [
            {
              alias     = "helloapp"
              # imageName 需要带上一个“当前/初始 tag”（随便给一个当前值即可）
              imageName = "939503809934.dkr.ecr.ap-southeast-2.amazonaws.com/helloapp:sha-a57ecb9"

              # 告诉它怎么改 manifests：Kustomize images 里的 name
              manifestTargets = {
                kustomize = {
                  name = "939503809934.dkr.ecr.ap-southeast-2.amazonaws.com/helloapp"
                }
              }
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    helm_release.argocd_image_updater
  ]
}
